import 'dart:async';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/features/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AuthCubit(this._repository) : super(AuthInitial());

  /// Check existing session on startup
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  /// Signup
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signup(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Login
  Future<void> login({
    required String email,
    required String password,
    required UserRole expectedRole,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(
        email: email,
        password: password,
        expectedRole: expectedRole,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Google Sign In
  Future<void> signInWithGoogle({required UserRole role}) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signInWithGoogle(role: role);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  /// Update Profile
  Future<void> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    final currentState = state;
    if (currentState is! Authenticated) return;

    try {
      final updatedUser = await _repository.updateProfile(
        uid: currentState.user.uid,
        role: currentState.user.role,
        name: name,
        profileImage: profileImage,
      );
      emit(Authenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(Authenticated(currentState.user));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    final previousState = state;
    emit(AuthLoading());
    try {
      await _repository.sendPasswordResetEmail(email);
      emit(PasswordResetSent(email));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      if (state is PasswordResetSent || state is AuthError) {
        // Revert to previous state if unauthenticated after notifying
        if (previousState is Unauthenticated) {
          emit(Unauthenticated());
        }
      }
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _repository.signOut();
    } finally {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
