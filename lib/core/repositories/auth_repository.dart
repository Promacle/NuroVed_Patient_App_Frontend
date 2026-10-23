import '../models/user_profile.dart';
import '../utils/result.dart';

/// Abstract contract for authentication and session lifecycle management.
abstract class AuthRepository {
  /// Stream emitting the current authenticated [UserProfile] on login/logout/update.
  Stream<UserProfile?> get authStateChanges;

  /// Returns the cached active [UserProfile] synchronously, or null if unauthenticated.
  UserProfile? get currentUser;

  /// Authenticates using email and password.
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  });

  /// Registers a new patient account with terms acknowledgement.
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
    required bool acknowledgedTerms,
    String? phone,
    String? dateOfBirth,
    String? gender,
  });

  /// Terminates the current session and removes tokens.
  Future<Result<void>> signOut();

  /// Returns the current active [UserProfile], or null if unauthenticated.
  Future<Result<UserProfile?>> getCurrentUser();

  /// Restores a persistent session from secure storage across application restarts.
  Future<Result<UserProfile?>> restoreSession();

  /// Triggers a password reset email from the auth provider.
  Future<Result<void>> resetPassword(String email);

  /// Changes the user's password with re-authentication.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Updates the user's email address with password verification.
  Future<Result<void>> changeEmail({
    required String newEmail,
    required String password,
  });

  /// Permanently deletes the account and all patient data through a server-backed flow.
  Future<Result<void>> deleteAccount({required String passwordConfirm});
}
