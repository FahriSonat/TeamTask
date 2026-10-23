import '../../../../core/errors/result.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<User>> login({required String email, required String password});

  Future<Result<User?>> getCurrentUser();

  Future<Result<void>> logout();
}
