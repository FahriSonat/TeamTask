// Dosya: lib/features/auth/data/repositories/auth_repository_impl.dart
// AuthRepository'nin yerel (Hive) gerçeklemesi.
// Doğrulama, e-posta tekilliği, parola özeti kontrolü ve oturum yönetimi burada.

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/utils/password_hasher.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Kimlik doğrulama iş kuralları.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final Uuid _uuid;

  AuthRepositoryImpl({required this.localDataSource, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  /// Alanları doğrular, e-posta kayıtlıysa reddeder, özetlenmiş parolayla kaydeder.
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final nameError = Validators.validateName(name);
    if (nameError != null) {
      return Result.failure(ValidationFailure(nameError));
    }
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Result.failure(ValidationFailure(emailError));
    }
    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) {
      return Result.failure(ValidationFailure(passwordError));
    }

    try {
      final existing = await localDataSource.getUserByEmail(email);
      if (existing != null) {
        return const Result.failure(
          ValidationFailure(AppStrings.emailAlreadyExists),
        );
      }

      final now = DateTime.now().toUtc();
      final user = User(
        id: _uuid.v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: now,
      );

      final userModel = UserModel.fromEntity(
        user,
        passwordHash: PasswordHasher.hash(password),
      );

      await localDataSource.saveUser(userModel);
      await localDataSource.setCurrentUserId(user.id);

      return Result.success(user);
    } catch (e) {
      return Result.failure(CacheFailure('Kayıt yapılamadı: $e'));
    }
  }

  /// Kullanıcıyı bulur ve parola özetini karşılaştırır.
  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      return Result.failure(ValidationFailure(emailError));
    }
    if (password.isEmpty) {
      return const Result.failure(ValidationFailure(AppStrings.requiredField));
    }

    try {
      final userModel = await localDataSource.getUserByEmail(email);
      if (userModel == null) {
        return const Result.failure(AuthFailure(AppStrings.invalidCredentials));
      }

      final isMatch = PasswordHasher.verify(password, userModel.passwordHash);
      if (!isMatch) {
        return const Result.failure(AuthFailure(AppStrings.invalidCredentials));
      }

      await localDataSource.setCurrentUserId(userModel.id);
      return Result.success(userModel.toEntity());
    } catch (e) {
      return Result.failure(CacheFailure('Giriş yapılamadı: $e'));
    }
  }

  /// Oturumdaki kullanıcı silinmişse oturumu da temizler.
  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final userId = await localDataSource.getCurrentUserId();
      if (userId == null) {
        return const Result.success(null);
      }

      final userModel = await localDataSource.getUserById(userId);
      if (userModel == null) {
        await localDataSource.setCurrentUserId(null);
        return const Result.success(null);
      }

      return Result.success(userModel.toEntity());
    } catch (e) {
      return Result.failure(CacheFailure('Oturum bilgisi okunamadı: $e'));
    }
  }

  /// Oturum kaydını siler.
  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.setCurrentUserId(null);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure('Çıkış yapılamadı: $e'));
    }
  }
}
