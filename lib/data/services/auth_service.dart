import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? message;
  final UserModel? user;

  AuthResult({required this.success, this.message, this.user});
}

/// Firebase Authentication Service
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create user with email and password
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (credential.user != null) {
        // Create user document in Firestore
        final userModel = UserModel(
          id: credential.user!.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toJson());

        // Update display name
        await credential.user!.updateDisplayName(name.trim());

        return AuthResult(
          success: true,
          message: 'Account created successfully!',
          user: userModel,
        );
      }

      return AuthResult(
        success: false,
        message: 'Failed to create account. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromJson({
            ...userDoc.data()!,
            'id': credential.user!.uid,
          });

          return AuthResult(
            success: true,
            message: 'Logged in successfully!',
            user: userModel,
          );
        }

        return AuthResult(success: true, message: 'Logged in successfully!');
      }

      return AuthResult(
        success: false,
        message: 'Failed to sign in. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Get user profile
  Future<UserModel?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson({...userDoc.data()!, 'id': currentUser!.uid});
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? profileImageUrl,
    String? clinicName,
    String? clinicAddress,
  }) async {
    try {
      if (currentUser == null) {
        return AuthResult(success: false, message: 'User not logged in.');
      }

      final updates = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (name != null) {
        updates['name'] = name.trim();
        await currentUser!.updateDisplayName(name.trim());
      }
      if (phone != null) updates['phone'] = phone.trim();
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (clinicName != null) updates['clinicName'] = clinicName.trim();
      if (clinicAddress != null)
        updates['clinicAddress'] = clinicAddress.trim();

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updates);

      return AuthResult(
        success: true,
        message: 'Profile updated successfully!',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to update profile. Please try again.',
      );
    }
  }

  /// Get error message from Firebase Auth error code
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
