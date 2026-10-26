// Dosya: lib/core/errors/failures.dart
// Domain katmanı hata tipleri.
// Repository'ler başarısızlığı bu sınıflarla, kullanıcıya gösterilecek mesajla döndürür.

import 'package:equatable/equatable.dart';

/// Tüm hata tiplerinin ortak atası; message alanı ekranda gösterilir.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Yerel veritabanı hatası.
final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Veri kaydedilirken veya okunurken bir sorun oluştu.',
  ]);
}

/// Hatalı e-posta / şifre.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'E-posta veya şifre hatalı.']);
}

/// Form doğrulama hatası.
final class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'Girdi bilgileri kurallara uymuyor.',
  ]);
}

/// Kayıt bulunamadı.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'İstenen kayıt bulunamadı.']);
}

/// Beklenmeyen diğer hatalar.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmeyen bir hata oluştu.']);
}
