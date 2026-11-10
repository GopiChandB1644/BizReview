import 'package:bizreview/core/utils/app_logger.dart';
import 'package:bizreview/features/auth/models/user_model.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email & password for a specific role
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    AppLogger.i('Initiating signup: $email as ${role.displayName}', tag: 'AUTH');
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('User creation failed');
      }

      await user.updateDisplayName(name.trim());

      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      );

      // Save directly to role collection (customers or business_owners)
      await _firestore
          .collection(role.collectionName)
          .doc(user.uid)
          .set(userModel.toMap());

      AppLogger.backend(
        'CREATE_PROFILE',
        collection: role.collectionName,
        docId: user.uid,
        payload: userModel.toMap(),
        result: 'SUCCESS',
      );

      if (role == UserRole.owner) {
        await _syncOwnerFcmToken(user.uid);
      }

      AppLogger.i('Signup completed successfully for ${user.uid}', tag: 'AUTH');
      return userModel;
    } on FirebaseAuthException catch (e) {
      final message = _handleAuthException(e);
      AppLogger.e('FirebaseAuth signup error: ${e.code}', tag: 'AUTH', error: message);
      throw Exception(message);
    } on FirebaseException catch (e, stack) {
      AppLogger.e('Firestore signup error: ${e.code}', tag: 'AUTH', error: e.message, stackTrace: stack);
      if (e.code == 'permission-denied') {
        throw Exception(
          'Firestore permission denied. Please publish the security rules in Firebase Console -> Firestore Database -> Rules.',
        );
      }
      throw Exception('Database error: ${e.message ?? e.code}');
    } catch (e, stack) {
      AppLogger.e('Unexpected signup error', tag: 'AUTH', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Login with email & password verifying role
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    AppLogger.i('Initiating login: $email as ${expectedRole.displayName}', tag: 'AUTH');
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed: user not found');
      }

      // Verify that this user belongs to the requested role collection
      final doc = await _firestore
          .collection(expectedRole.collectionName)
          .doc(user.uid)
          .get();

      AppLogger.backend(
        'VERIFY_ROLE',
        collection: expectedRole.collectionName,
        docId: user.uid,
        result: doc.exists ? 'EXISTS' : 'NOT_FOUND',
      );

      if (!doc.exists) {
        // Check if user is registered with opposite role
        final oppositeRole = expectedRole == UserRole.customer
            ? UserRole.owner
            : UserRole.customer;
        final oppositeDoc = await _firestore
            .collection(oppositeRole.collectionName)
            .doc(user.uid)
            .get();

        if (oppositeDoc.exists) {
          await _auth.signOut();
          final err =
              'This account is registered as a ${oppositeRole.displayName}. Please log in from the ${oppositeRole.displayName} portal.';
          AppLogger.w(err, tag: 'AUTH');
          throw Exception(err);
        }

        // Migration fallback: check legacy 'users' collection
        final legacyDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (legacyDoc.exists) {
          final data = legacyDoc.data() ?? {};
          final migratedUser = UserModel(
            uid: user.uid,
            name: data['username'] ?? data['displayName'] ?? user.displayName ?? '',
            email: user.email ?? '',
            profileImage: data['profileImage'],
            role: expectedRole,
          );
          await _firestore
              .collection(expectedRole.collectionName)
              .doc(user.uid)
              .set(migratedUser.toMap());
          AppLogger.backend(
            'MIGRATED_LEGACY_PROFILE',
            collection: expectedRole.collectionName,
            docId: user.uid,
            payload: migratedUser.toMap(),
          );
          return migratedUser;
        }

        // Auto-heal / initialize profile if missing (e.g., database was wiped)
        AppLogger.i('Creating missing profile document for ${user.uid} as ${expectedRole.displayName}');
        final newProfile = UserModel(
          uid: user.uid,
          name: user.displayName?.isNotEmpty == true
              ? user.displayName!
              : email.split('@').first,
          email: user.email ?? email,
          role: expectedRole,
        );
        await _firestore
            .collection(expectedRole.collectionName)
            .doc(user.uid)
            .set(newProfile.toMap());

        AppLogger.backend(
          'AUTO_CREATE_PROFILE',
          collection: expectedRole.collectionName,
          docId: user.uid,
          payload: newProfile.toMap(),
        );

        if (expectedRole == UserRole.owner) {
          await _syncOwnerFcmToken(user.uid);
        }

        return newProfile;
      }

      if (expectedRole == UserRole.owner) {
        await _syncOwnerFcmToken(user.uid);
      }

      final loggedInUser = UserModel.fromMap(doc.data()!, user.uid, expectedRole);
      AppLogger.data('User Profile Loaded', loggedInUser.toMap(), tag: 'AUTH');
      return loggedInUser;
    } on FirebaseAuthException catch (e) {
      final message = _handleAuthException(e);
      AppLogger.e('FirebaseAuth login error: ${e.code}', tag: 'AUTH', error: message);
      throw Exception(message);
    } on FirebaseException catch (e, stack) {
      AppLogger.e('Firestore login error: ${e.code}', tag: 'AUTH', error: e.message, stackTrace: stack);
      if (e.code == 'permission-denied') {
        throw Exception(
          'Firestore permission denied. Please publish the security rules in Firebase Console -> Firestore Database -> Rules.',
        );
      }
      throw Exception('Database error: ${e.message ?? e.code}');
    } catch (e, stack) {
      AppLogger.e('Unexpected login error', tag: 'AUTH', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Google Sign In
  Future<UserModel> signInWithGoogle({required UserRole role}) async {
    AppLogger.i('Initiating Google Sign-In for ${role.displayName}', tag: 'AUTH');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase authentication with Google failed');
      }

      // Check if user already exists in this role collection
      final doc = await _firestore
          .collection(role.collectionName)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        if (role == UserRole.owner) {
          await _syncOwnerFcmToken(user.uid);
        }
        AppLogger.backend('GOOGLE_SIGNIN_EXISTING', collection: role.collectionName, docId: user.uid);
        return UserModel.fromMap(doc.data()!, user.uid, role);
      }

      // Check opposite role
      final oppositeRole =
          role == UserRole.customer ? UserRole.owner : UserRole.customer;
      final oppositeDoc = await _firestore
          .collection(oppositeRole.collectionName)
          .doc(user.uid)
          .get();

      if (oppositeDoc.exists) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        final err =
            'This Google account is already registered as a ${oppositeRole.displayName}.';
        AppLogger.w(err, tag: 'AUTH');
        throw Exception(err);
      }

      // Create new profile for this role
      final newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        profileImage: null,
        role: role,
      );

      await _firestore
          .collection(role.collectionName)
          .doc(user.uid)
          .set(newUser.toMap());

      AppLogger.backend('CREATE_GOOGLE_PROFILE', collection: role.collectionName, docId: user.uid, payload: newUser.toMap());

      if (role == UserRole.owner) {
        await _syncOwnerFcmToken(user.uid);
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      final message = _handleAuthException(e);
      AppLogger.e('Google Auth error: ${e.code}', tag: 'AUTH', error: message);
      throw Exception(message);
    } catch (e, stack) {
      AppLogger.e('Unexpected Google sign in error', tag: 'AUTH', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get current user profile and role
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Check customer collection first
      final customerDoc =
          await _firestore.collection('customers').doc(user.uid).get();
      if (customerDoc.exists && customerDoc.data() != null) {
        AppLogger.backend('CHECK_SESSION_CUSTOMER', collection: 'customers', docId: user.uid, result: 'VALID');
        return UserModel.fromMap(
          customerDoc.data()!,
          user.uid,
          UserRole.customer,
        );
      }

      // Check business owner collection
      final ownerDoc =
          await _firestore.collection('business_owners').doc(user.uid).get();
      if (ownerDoc.exists && ownerDoc.data() != null) {
        _syncOwnerFcmToken(user.uid);
        AppLogger.backend('CHECK_SESSION_OWNER', collection: 'business_owners', docId: user.uid, result: 'VALID');
        return UserModel.fromMap(
          ownerDoc.data()!,
          user.uid,
          UserRole.owner,
        );
      }

      // Fallback check legacy users collection
      final legacyDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (legacyDoc.exists && legacyDoc.data() != null) {
        final data = legacyDoc.data()!;
        AppLogger.backend('CHECK_SESSION_LEGACY', collection: 'users', docId: user.uid, result: 'MIGRATING');
        return UserModel(
          uid: user.uid,
          name: data['username'] ?? data['displayName'] ?? user.displayName ?? '',
          email: user.email ?? '',
          profileImage: data['profileImage'],
          role: UserRole.customer,
        );
      }
    } catch (e) {
      AppLogger.w('Could not load profile from Firestore: $e', tag: 'AUTH');
      return null;
    }

    return null;
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    required String uid,
    required UserRole role,
    String? name,
    String? profileImage,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null && name.trim().isNotEmpty) {
      updates['name'] = name.trim();
      await _auth.currentUser?.updateDisplayName(name.trim());
    }
    if (profileImage != null) {
      updates['profileImage'] = profileImage;
    }

    if (updates.isNotEmpty) {
      await _firestore
          .collection(role.collectionName)
          .doc(uid)
          .set(updates, SetOptions(merge: true));

      AppLogger.backend(
        'UPDATE_PROFILE',
        collection: role.collectionName,
        docId: uid,
        payload: {'name': name, 'hasImage': profileImage != null},
        result: 'SUCCESS',
      );
    }

    final updatedDoc =
        await _firestore.collection(role.collectionName).doc(uid).get();
    return UserModel.fromMap(updatedDoc.data()!, uid, role);
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.i('Password reset email sent to $email', tag: 'AUTH');
    } on FirebaseAuthException catch (e) {
      final msg = _handleAuthException(e);
      AppLogger.e('Reset password error: ${e.code}', tag: 'AUTH', error: msg);
      throw Exception(msg);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    final current = _auth.currentUser;
    if (current != null) {
      try {
        await _messaging.unsubscribeFromTopic('owner_${current.uid}');
      } catch (_) {}
    }
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    AppLogger.i('Session signed out successfully', tag: 'AUTH');
  }

  Future<void> _syncOwnerFcmToken(String ownerId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('business_owners').doc(ownerId).set({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        AppLogger.backend('SYNC_FCM_TOKEN', collection: 'business_owners', docId: ownerId, payload: {'fcmToken': token});
      }
      await _messaging.subscribeToTopic('owner_$ownerId');
      AppLogger.i('Subscribed to owner_$ownerId FCM topic', tag: 'FCM');
    } catch (e) {
      AppLogger.e('Error syncing owner FCM token', tag: 'FCM', error: e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
