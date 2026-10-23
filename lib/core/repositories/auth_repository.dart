import '../models/user_profile.dart';
import '../utils/result.dart';

abstract class AuthRepository {
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  });

  Future<Result<UserProfile>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Result<void>> signOut();

  Future<Result<UserProfile?>> getCurrentUser();

  Future<Result<void>> resetPassword(String email);
}
