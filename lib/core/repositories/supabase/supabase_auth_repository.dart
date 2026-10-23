import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../errors/failures.dart';
import '../../models/user_profile.dart';
import '../../utils/app_logger.dart';
import '../../utils/result.dart';
import '../auth_repository.dart';

/// Production implementation of [AuthRepository] interacting with Supabase Auth REST API.
///
/// Note on Verification Status:
/// Live behavior is marked IMPLEMENTED-UNVERIFIED in environments where
/// live backend credentials (SUPABASE_URL, SUPABASE_ANON_KEY) are absent.
class SupabaseAuthRepository implements AuthRepository {
  static const String _prefTokenKey = 'nuroved_supabase_access_token';
  static const String _prefRefreshKey = 'nuroved_supabase_refresh_token';
  static const String _prefUserKey = 'nuroved_supabase_user_cache';

  final StreamController<UserProfile?> _authStateController =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _currentUser;
  String? _accessToken;

  SupabaseAuthRepository();

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUser => _currentUser;

  Map<String, String> get _headers => {
    'apikey': AppConfig.supabaseAnonKey,
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
    }

    try {
      final url = Uri.parse(
        '${AppConfig.supabaseUrl}/auth/v1/token?grant_type=password',
      );
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _accessToken = data['access_token'] as String?;
        final userMap = data['user'] as Map<String, dynamic>;
        final user = _mapSupabaseUserToProfile(userMap);

        _currentUser = user;
        _authStateController.add(user);

        final prefs = await SharedPreferences.getInstance();
        if (_accessToken != null) {
          await prefs.setString(_prefTokenKey, _accessToken!);
        }
        if (data['refresh_token'] != null) {
          await prefs.setString(
            _prefRefreshKey,
            data['refresh_token'] as String,
          );
        }
        await prefs.setString(_prefUserKey, jsonEncode(user.toMap()));

        return Result.success(user);
      } else {
        final errorMsg =
            data['error_description'] ??
            data['msg'] ??
            data['message'] ??
            'Invalid email or password.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Supabase signIn network error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
    required bool acknowledgedTerms,
    String? phone,
    String? dateOfBirth,
    String? gender,
  }) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
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

    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/signup');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'data': {
            'name': name.trim(),
            'phone': phone ?? 'Not provided',
            'dob': dateOfBirth ?? 'Not provided',
            'gender': gender ?? 'Not provided',
          },
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userMap = data['user'] as Map<String, dynamic>? ?? data;
        final user = _mapSupabaseUserToProfile(userMap);
        _currentUser = user;
        _authStateController.add(user);

        if (data['access_token'] != null) {
          _accessToken = data['access_token'] as String;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefTokenKey, _accessToken!);
          await prefs.setString(_prefUserKey, jsonEncode(user.toMap()));
        }

        return Result.success(user);
      } else {
        final errorMsg =
            data['msg'] ??
            data['error_description'] ??
            data['message'] ??
            'Registration failed.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Supabase signUp network error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<void>> signOut() async {
    try {
      if (AppConfig.isBackendConfigured && _accessToken != null) {
        final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/logout');
        await http.post(url, headers: _headers);
      }
    } catch (e) {
      AppLogger.error('Supabase signOut request error', e);
    } finally {
      _currentUser = null;
      _accessToken = null;
      _authStateController.add(null);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefTokenKey);
      await prefs.remove(_prefRefreshKey);
      await prefs.remove(_prefUserKey);
    }

    return const Result.success(null);
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<UserProfile?>> getCurrentUser() async {
    return Result.success(_currentUser);
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<UserProfile?>> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_prefTokenKey);
      final userJson = prefs.getString(_prefUserKey);

      if (token == null || userJson == null) {
        return const Result.success(null);
      }

      _accessToken = token;

      // Verify token with Supabase /auth/v1/user
      if (AppConfig.isBackendConfigured) {
        final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/user');
        final response = await http.get(url, headers: _headers);

        if (response.statusCode == 200) {
          final userMap = jsonDecode(response.body) as Map<String, dynamic>;
          final user = _mapSupabaseUserToProfile(userMap);
          _currentUser = user;
          _authStateController.add(user);
          return Result.success(user);
        } else {
          // Token expired or invalid
          await signOut();
          return const Result.failure(
            AuthFailure(message: 'Session expired. Please log in again.'),
          );
        }
      } else {
        // Offline restore from local cache
        final user = UserProfile.fromMap(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        _currentUser = user;
        _authStateController.add(user);
        return Result.success(user);
      }
    } catch (e) {
      AppLogger.error('Session restoration error', e);
      await signOut();
      return const Result.success(null);
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<void>> resetPassword(String email) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
    }

    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/recover');
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'email': email.trim()}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Result.success(null);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg =
            data['msg'] ?? data['message'] ?? 'Password reset failed.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Password reset request error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
    }

    if (_currentUser == null || _accessToken == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    // First re-authenticate with current credentials
    final reAuthResult = await signIn(
      email: _currentUser!.email,
      password: currentPassword,
    );
    if (reAuthResult.isFailure) {
      return const Result.failure(
        AuthFailure(message: 'Current password verification failed.'),
      );
    }

    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/user');
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Result.success(null);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg =
            data['msg'] ?? data['message'] ?? 'Failed to update password.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Change password error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<void>> changeEmail({
    required String newEmail,
    required String password,
  }) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
    }

    if (_currentUser == null || _accessToken == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    // First re-authenticate with current credentials
    final reAuthResult = await signIn(
      email: _currentUser!.email,
      password: password,
    );
    if (reAuthResult.isFailure) {
      return const Result.failure(
        AuthFailure(message: 'Password verification failed.'),
      );
    }

    try {
      final url = Uri.parse('${AppConfig.supabaseUrl}/auth/v1/user');
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode({'email': newEmail.trim()}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const Result.success(null);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg =
            data['msg'] ?? data['message'] ?? 'Failed to update email.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Change email error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  @override
  // IMPLEMENTED-UNVERIFIED
  Future<Result<void>> deleteAccount({required String passwordConfirm}) async {
    if (!AppConfig.isBackendConfigured) {
      return const Result.failure(
        ConfigFailure(
          message:
              'Backend is not configured. Please supply SUPABASE_URL and SUPABASE_ANON_KEY.',
        ),
      );
    }

    if (_currentUser == null || _accessToken == null) {
      return const Result.failure(
        AuthFailure(message: 'User is not authenticated.'),
      );
    }

    // Re-verify password before executing irreversible deletion
    final reAuthResult = await signIn(
      email: _currentUser!.email,
      password: passwordConfirm,
    );
    if (reAuthResult.isFailure) {
      return const Result.failure(
        AuthFailure(message: 'Password confirmation failed.'),
      );
    }

    try {
      // Invoke the secure RPC delete_user_account() via Supabase PostgREST endpoint
      // Using caller's own JWT token. The RPC runs with SECURITY DEFINER on server.
      final url = Uri.parse(
        '${AppConfig.supabaseUrl}/rest/v1/rpc/delete_user_account',
      );
      final response = await http.post(url, headers: _headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await signOut();
        return const Result.success(null);
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg =
            data['message'] ?? data['details'] ?? 'Account deletion failed.';
        return Result.failure(AuthFailure(message: errorMsg.toString()));
      }
    } catch (e) {
      AppLogger.error('Account deletion error', e);
      return const Result.failure(
        NetworkFailure(message: 'Network error. Please check your connection.'),
      );
    }
  }

  UserProfile _mapSupabaseUserToProfile(Map<String, dynamic> userMap) {
    final metadata = (userMap['user_metadata'] as Map<String, dynamic>?) ?? {};
    return UserProfile(
      id: userMap['id']?.toString() ?? '',
      name: metadata['name']?.toString() ?? 'Patient',
      email: userMap['email']?.toString() ?? '',
      phone: metadata['phone']?.toString() ?? 'Not provided',
      dateOfBirth: metadata['dob']?.toString() ?? 'Not provided',
      gender: metadata['gender']?.toString() ?? 'Not provided',
      height: 'Not provided',
      weight: 'Not provided',
      bloodGroup: 'Not provided',
      allergies: const [],
      chronicConditions: const [],
      createdAt:
          DateTime.tryParse(userMap['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    _authStateController.close();
  }
}
