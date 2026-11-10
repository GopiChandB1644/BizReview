import 'dart:async';
import 'package:bizreview/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot>? _ownerNotificationSubscription;
  DateTime? _listeningStartTime;

  static const String channelId = 'bizreview_high_importance_channel';
  static const String channelName = 'BizReview Notifications';
  static const String channelDesc =
      'High importance notifications for BizReview';

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.i('FCM Permission Status: ${settings.authorizationStatus}', tag: 'NOTIF');

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      AppLogger.data('FCM Device Token Retrieved', {'token': token}, tag: 'NOTIF');
      return token;
    } catch (e, stack) {
      AppLogger.e('Failed to get FCM device token', tag: 'NOTIF', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Save FCM device token to owner profile in Firestore
  Future<void> saveOwnerDeviceToken(String ownerId) async {
    try {
      final token = await getDeviceToken();
      if (token != null) {
        await _firestore.collection('business_owners').doc(ownerId).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        AppLogger.backend('SAVE_FCM_TOKEN', collection: 'business_owners', docId: ownerId, payload: {'fcmToken': token});
      }
    } catch (e, stack) {
      AppLogger.e('Error saving owner token', tag: 'NOTIF', error: e, stackTrace: stack);
    }
  }

  /// Subscribe owner to their personal FCM topic (`owner_{ownerId}`)
  Future<void> subscribeToOwnerTopic(String ownerId) async {
    try {
      await _messaging.subscribeToTopic('owner_$ownerId');
      AppLogger.i('Subscribed to FCM topic: owner_$ownerId', tag: 'FCM');
    } catch (e) {
      AppLogger.e('Error subscribing to owner topic', tag: 'FCM', error: e);
    }
  }

  /// Unsubscribe from owner FCM topic on logout
  Future<void> unsubscribeFromOwnerTopic(String ownerId) async {
    try {
      await _messaging.unsubscribeFromTopic('owner_$ownerId');
      AppLogger.i('Unsubscribed from FCM topic: owner_$ownerId', tag: 'FCM');
    } catch (e) {
      AppLogger.e('Error unsubscribing from owner topic', tag: 'FCM', error: e);
    }
  }

  /// Display a local notification with sound, heads-up banner and vibration
  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId =
        (title.hashCode ^ body.hashCode ^ DateTime.now().millisecondsSinceEpoch)
            .abs() %
        100000;

    AppLogger.i('Triggering Local Heads-Up Alert: "$title" - "$body"', tag: 'NOTIF');

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Real-time listener for owner notifications.
  void listenToOwnerNotifications(String ownerId) {
    _ownerNotificationSubscription?.cancel();
    _listeningStartTime = DateTime.now();

    AppLogger.backend(
      'LISTEN_NOTIFICATIONS',
      collection: 'business_owners/$ownerId/notifications',
      result: 'LISTENER_ACTIVE',
    );

    _ownerNotificationSubscription = _firestore
        .collection('business_owners')
        .doc(ownerId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final createdAt = data['createdAt'];
          DateTime? createdDate;
          if (createdAt is Timestamp) {
            createdDate = createdAt.toDate();
          }

          // Only alert for notifications arriving during this active session
          if (createdDate != null &&
              _listeningStartTime != null &&
              createdDate.isAfter(_listeningStartTime!.subtract(const Duration(seconds: 5)))) {
            final title = data['title'] as String? ?? 'New Review Received!';
            final body = data['body'] as String? ?? 'A customer reviewed your business.';

            AppLogger.backend(
              'REALTIME_REVIEW_ALERT_RECEIVED',
              collection: 'business_owners/$ownerId/notifications',
              docId: change.doc.id,
              payload: data,
            );

            showCustomNotification(
              title: title,
              body: body,
              payload: data['businessId'],
            );
          }
        }
      }
    }, onError: (err) {
      AppLogger.e('Error in owner notification listener', tag: 'NOTIF', error: err);
    });
  }

  void stopListeningToOwnerNotifications() {
    _ownerNotificationSubscription?.cancel();
    _ownerNotificationSubscription = null;
    AppLogger.i('Stopped owner notification listener', tag: 'NOTIF');
  }

  void initializeForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.data('Foreground FCM Message Received', {
        'title': message.notification?.title ?? message.data['title'],
        'body': message.notification?.body ?? message.data['body'],
        'data': message.data,
      }, tag: 'FCM');
      await showLocalNotification(message);
    });
  }

  void initializeNotificationTapHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('Notification tapped by user: ${message.messageId}', tag: 'NOTIF');
    });
  }

  Future<void> checkInitialMessage() async {
    final RemoteMessage? message = await _messaging.getInitialMessage();
    if (message != null) {
      AppLogger.i('App opened from terminated state notification: ${message.messageId}', tag: 'NOTIF');
    }
  }

  Future<void> initializeLocalNotificationSystem() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.i('Local notification response tapped: ${response.payload}', tag: 'NOTIF');
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final String? title = message.notification?.title ?? message.data['title'];
    final String? body = message.notification?.body ?? message.data['body'];

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId =
        (message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch)
            .abs() %
        100000;

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }
}
