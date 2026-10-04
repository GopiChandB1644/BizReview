import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'bizreview_high_importance_channel';
  static const String channelName = 'BizReview Notifications';
  static const String channelDesc =
      'High importance notifications for BizReview';

  Future<void> requestPermission() async {
    // 1. Firebase Messaging Permission (iOS, macOS, web, Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permission: ${settings.authorizationStatus}');

    // 2. Android 13+ (API 33+) Local Notification Runtime Permission
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool? androidGranted =
        await androidImplementation?.requestNotificationsPermission();
    print('Android POST_NOTIFICATIONS granted: $androidGranted');

    // 3. iOS/macOS Foreground Presentation Options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getDeviceToken() async {
    final token = await _messaging.getToken();
    print('FCM TOKEN: $token');
    return token;
  }

  void initializeForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('========== FOREGROUND MESSAGE ==========');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title ?? message.data['title']}');
      print('Body: ${message.notification?.body ?? message.data['body']}');
      print('Data: ${message.data}');
      print('========================================');

      await showLocalNotification(message);
    });
  }

  void initializeNotificationTapHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('========== NOTIFICATION TAPPED ==========');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title ?? message.data['title']}');
      print('Body: ${message.notification?.body ?? message.data['body']}');
      print('Data: ${message.data}');
      print('==========================================');
    });
  }

  Future<void> checkInitialMessage() async {
    final RemoteMessage? message = await _messaging.getInitialMessage();

    if (message != null) {
      print('========== APP OPENED FROM NOTIFICATION ==========');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title ?? message.data['title']}');
      print('Body: ${message.notification?.body ?? message.data['body']}');
      print('Data: ${message.data}');
      print('==================================================');
    }
  }

  Future<void> initializeLocalNotifications() async {
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
        print('========== LOCAL NOTIFICATION TAPPED ==========');
        print('Payload: ${response.payload}');
        print('===============================================');
      },
    );
  }

  Future<void> createNotificationChannel() async {
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

  Future<void> initializeLocalNotificationSystem() async {
    await initializeLocalNotifications();
    await createNotificationChannel();
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      final String? title =
          message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];

      // If neither title nor body is present, skip
      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        print('Foreground message has no title or body to display.');
        return;
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Safe non-negative 32-bit ID
      final int notificationId =
          (message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch)
              .abs() %
          100000;

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );

      print('Local notification displayed (ID: $notificationId)');
    } catch (e) {
      print('Error displaying foreground local notification: $e');
    }
  }
}