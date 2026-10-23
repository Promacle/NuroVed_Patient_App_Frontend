import '../../errors/failures.dart';
import '../../models/user_profile.dart';
import '../../utils/result.dart';
import '../../utils/uuid_generator.dart';
import '../auth_repository.dart';

/// In-memory fake implementation of [AuthRepository] for unit tests and local demonstrations.
class FakeAuthRepository implements AuthRepository {
  UserProfile? _currentUser;
  bool shouldFail = false;
  Failure? customFailure;

  FakeAuthRepository({UserProfile? initialUser}) : _currentUser = initialUser;

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      return Result.failure(customFailure ?? const AuthFailure(message: 'Invalid credentials.'));
    }
    final user = UserProfile(
      id: UuidGenerator.v4(),
      name: 'Test Patient',
      email: email,
      phone: '+91 99999 00000',
      dateOfBirth: '01/01/1990',
      gender: 'male',
      height: '175',
      weight: '70',
      bloodGroup: 'O+',
      allergies: const [],
      chronicConditions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Result.success(user);
  }

  @override
  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (shouldFail) {
      return Result.failure(customFailure ?? const AuthFailure(message: 'Sign up failed.'));
    }
    final user = UserProfile(
      id: UuidGenerator.v4(),
      name: name,
      email: email,
      phone: 'Not provided',
      dateOfBirth: 'Not provided',
      gender: 'Not provided',
      height: 'Not provided',
      weight: 'Not provided',
      bloodGroup: 'Not provided',
      allergies: const [],
      chronicConditions: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _currentUser = user;
    return Result.success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    return const Result.success(null);
  }

  @override
  Future<Result<UserProfile?>> getCurrentUser() async {
    return Result.success(_currentUser);
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    if (shouldFail) {
      return Result.failure(customFailure ?? const AuthFailure(message: 'Reset password failed.'));
    }
    return const Result.success(null);
  }
}
