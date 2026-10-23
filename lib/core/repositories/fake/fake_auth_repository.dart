import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../errors/failures.dart';
import '../../models/user_profile.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../auth_repository.dart';

/// In-memory and SharedPreferences-backed fake implementation of [AuthRepository]
/// for automated tests and offline development without live backend dependencies.
class FakeAuthRepository implements AuthRepository {
  static const String _prefSessionKey = 'nuroved_fake_session_token';
  static const String _prefUserKey = 'nuroved_fake_session_user';

  final StreamController<UserProfile?> _authStateController =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _currentUser;
  bool shouldFail = false;
  Failure? customFailure;
  bool simulateExpiredSession = false;

  /// In-memory storage for registered accounts: email -> { 'password': ..., 'profile': UserProfile }
  final Map<String, Map<String, dynamic>> _registeredAccounts = {};

  FakeAuthRepository({UserProfile? initialUser}) {
    final defaultUser =
        initialUser ??
        UserProfile(
          id: 'test-user-uuid-1',
          name: 'Test Patient',
          email: 'test@example.com',
          phone: '+91 99999 00000',
          dateOfBirth: '01/01/1990',
          gender: 'male',
          height: '175',
          weight: '70',
          bloodGroup: 'O+',
          allergies: const [],
          chronicConditions: const [],
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

    _registeredAccounts[defaultUser.email.toLowerCase()] = {
      'password': 'password123',
      'profile': defaultUser,
    };

    if (initialUser != null) {
      _currentUser = initialUser;
    }
  }

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(
              message: 'Network error. Please check your connection.',
            ),
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    final account = _registeredAccounts[normalizedEmail];

    if (account == null || account['password'] != password) {
      return const Result.failure(
        AuthFailure(message: 'Invalid email or password. Please try again.'),
      );
    }

    final user = account['profile'] as UserProfile;
    _currentUser = user;
    _authStateController.add(user);

    // Persist session to SharedPreferences
    await _persistSession(user);

    return Result.success(user);
  }

  @override
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
    required bool acknowledgedTerms,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(
              message: 'Network error. Please check your connection.',
            ),
      );
    }

    if (!acknowledgedTerms) {
      return const Result.failure(
        ValidationFailure(
          message: 'You must acknowledge and accept the Terms of Service.',
        ),
      );
    }

    if (password.length < 8) {
      return const Result.failure(
        ValidationFailure(
          message: 'Password must be at least 8 characters long.',
        ),
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (_registeredAccounts.containsKey(normalizedEmail)) {
      return const Result.failure(
        AuthFailure(
          message: 'An account with this email address already exists.',
        ),
      );
    }

    final user = UserProfile(
      id: UuidGenerator.v4(),
      name: name.trim().isEmpty ? 'Test Patient' : name.trim(),
      email: normalizedEmail,
      phone: phone ?? 'Not provided',
      dateOfBirth: dateOfBirth ?? 'Not provided',
      gender: gender ?? 'Not provided',
      height: 'Not provided',
      weight: 'Not provided',
      bloodGroup: 'Not provided',
      allergies: const [],
      chronicConditions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _registeredAccounts[normalizedEmail] = {
      'password': password,
      'profile': user,
    };

    _currentUser = user;
    _authStateController.add(user);

    await _persistSession(user);

    return Result.success(user);
  }

  String? _fakeToken;
  String? _fakeUserJson;

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    _fakeToken = null;
    _fakeUserJson = null;
    _authStateController.add(null);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefSessionKey);
      await prefs.remove(_prefUserKey);
    } catch (_) {}

    return const Result.success(null);
  }

  @override
  Future<Result<UserProfile?>> getCurrentUser() async {
    return Result.success(_currentUser);
  }

  @override
  Future<Result<UserProfile?>> restoreSession() async {
    if (simulateExpiredSession) {
      await signOut();
      return const Result.failure(
        AuthFailure(message: 'Session expired. Please log in again.'),
      );
    }

    if (_fakeToken != null && _fakeUserJson != null) {
      final decoded = jsonDecode(_fakeUserJson!) as Map<String, dynamic>;
      final user = UserProfile.fromMap(decoded);
      _currentUser = user;
      _authStateController.add(user);
      return Result.success(user);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_prefSessionKey);
      final userJson = prefs.getString(_prefUserKey);

      if (token != null && userJson != null) {
        final decoded = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserProfile.fromMap(decoded);
        _currentUser = user;
        _authStateController.add(user);
        return Result.success(user);
      }
    } catch (_) {
      // Corrupt session data or no bindings, clear and return unauthenticated
      await signOut();
    }

    return const Result.success(null);
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(
              message: 'Failed to send password reset email.',
            ),
      );
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return const Result.failure(
        ValidationFailure(message: 'Please enter a valid email address.'),
      );
    }

    return const Result.success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(message: 'Failed to change password.'),
      );
    }

    if (_currentUser == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    final email = _currentUser!.email.toLowerCase();
    final account = _registeredAccounts[email];

    if (account == null || account['password'] != currentPassword) {
      return const Result.failure(
        AuthFailure(message: 'Current password is incorrect.'),
      );
    }

    if (newPassword.length < 8) {
      return const Result.failure(
        ValidationFailure(
          message: 'New password must be at least 8 characters long.',
        ),
      );
    }

    account['password'] = newPassword;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(message: 'Failed to update email address.'),
      );
    }

    if (_currentUser == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    final currentEmail = _currentUser!.email.toLowerCase();
    final account = _registeredAccounts[currentEmail];

    if (account == null || account['password'] != password) {
      return const Result.failure(
        AuthFailure(message: 'Password confirmation failed.'),
      );
    }

    final normalizedNewEmail = newEmail.trim().toLowerCase();
    if (_registeredAccounts.containsKey(normalizedNewEmail)) {
      return const Result.failure(
        AuthFailure(
          message: 'This email is already in use by another account.',
        ),
      );
    }

    // Update account entry
    _registeredAccounts.remove(currentEmail);
    final updatedProfile = _currentUser!.copyWith(
      email: normalizedNewEmail,
      updatedAt: DateTime.now(),
    );
    _registeredAccounts[normalizedNewEmail] = {
      'password': password,
      'profile': updatedProfile,
    };

    _currentUser = updatedProfile;
    _authStateController.add(updatedProfile);
    await _persistSession(updatedProfile);

    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteAccount({required String passwordConfirm}) async {
    if (shouldFail) {
      return Result.failure(
        customFailure ??
            const NetworkFailure(message: 'Failed to delete account.'),
      );
    }

    if (_currentUser == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    final email = _currentUser!.email.toLowerCase();
    final account = _registeredAccounts[email];

    if (account == null || account['password'] != passwordConfirm) {
      return const Result.failure(
        AuthFailure(message: 'Incorrect password. Account deletion cancelled.'),
      );
    }

    _registeredAccounts.remove(email);
    await signOut();

    return const Result.success(null);
  }

  Future<void> _persistSession(UserProfile user) async {
    _fakeToken = 'fake_jwt_token_${user.id}';
    _fakeUserJson = jsonEncode(user.toMap());

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefSessionKey, _fakeToken!);
      await prefs.setString(_prefUserKey, _fakeUserJson!);
    } catch (_) {}
  }

  void dispose() {
    _authStateController.close();
  }
}
