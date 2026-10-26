// Dosya: lib/features/auth/domain/repositories/auth_repository.dart
// Kimlik doğrulama sözleşmesi. Arayüz bu soyutlamayı kullanır; Hive'ı bilmez.

import '../../../../core/errors/result.dart';
import '../entities/user.dart';

/// Kayıt, giriş, oturum okuma ve çıkış işlemleri.
abstract interface class AuthRepository {
  /// Yeni kullanıcı oluşturur ve oturumu açar.
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// E-posta + parola ile giriş.
  Future<Result<User>> login({required String email, required String password});

  /// Kayıtlı oturum varsa kullanıcıyı döndürür, yoksa null.
  Future<Result<User?>> getCurrentUser();

  /// Oturumu kapatır.
  Future<Result<void>> logout();
}
