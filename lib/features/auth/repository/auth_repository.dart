import 'package:bizreview/features/auth/models/user_model.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/features/auth/services/auth_firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  });
  Future<UserModel> signInWithGoogle({required UserRole role});
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    required String uid,
    required UserRole role,
    String? name,
    String? profileImage,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseService _service;

  AuthRepositoryImpl(this._service);

  @override
  Stream<User?> get authStateChanges => _service.authStateChanges;

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _service.signup(
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) {
    return _service.login(
      email: email,
      password: password,
      expectedRole: expectedRole,
    );
  }

  @override
  Future<UserModel> signInWithGoogle({required UserRole role}) {
    return _service.signInWithGoogle(role: role);
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return _service.getCurrentUser();
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required UserRole role,
    String? name,
    String? profileImage,
  }) {
    return _service.updateProfile(
      uid: uid,
      role: role,
      name: name,
      profileImage: profileImage,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _service.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() {
    return _service.signOut();
  }
}
