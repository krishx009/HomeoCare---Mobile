import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

/// Authentication state enum
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Authentication Provider for managing auth state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Alias for user
  UserModel? get userModel => _user; // Another alias for user
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state
  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getUserProfile();
        _state = AuthState.authenticated;
      } else {
        _user = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Sign up
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signUp(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (result.success) {
      _user = result.user;
      _state = AuthState.authenticated;
    } else {
      _errorMessage = result.message;
      _state = AuthState.error;
    }

    notifyListeners();
    return result.success;
  }

  /// Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signIn(email: email, password: password);

    if (result.success) {
      _user = result.user;
      _state = AuthState.authenticated;
    } else {
      _errorMessage = result.message;
      _state = AuthState.error;
    }

    notifyListeners();
    return result.success;
  }

  /// Sign in with email - alias for signIn
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return signIn(email: email, password: password);
  }

  /// Sign up with email - alias for signUp
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    return signUp(
      name: name,
      email: email,
      phone: phone ?? '',
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.signOut();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.resetPassword(email);

    if (!result.success) {
      _errorMessage = result.message;
      _state = AuthState.error;
    } else {
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
    return result.success;
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
    String? clinicName,
    String? clinicAddress,
  }) async {
    final result = await _authService.updateProfile(
      name: name,
      phone: phone,
      profileImageUrl: profileImageUrl,
      clinicName: clinicName,
      clinicAddress: clinicAddress,
    );

    if (result.success) {
      _user = await _authService.getUserProfile();
      notifyListeners();
    }

    return result.success;
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null || firebaseUser.email == null) {
        return false;
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: firebaseUser.email!,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(credential);

      // Update to new password
      await firebaseUser.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
