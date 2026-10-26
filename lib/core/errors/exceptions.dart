// Dosya: lib/core/errors/exceptions.dart
// Data katmanında fırlatılan istisnalar.
// Repository bunları yakalayıp Failure'a çevirir; arayüze istisna sızmaz.

/// Tüm uygulama istisnalarının temel sınıfı.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Hive okuma/yazma hatası.
class CacheException extends AppException {
  const CacheException([super.message = 'Veri tabanı hatası oluştu']);
}

/// Kimlik doğrulama hatası.
class AuthException extends AppException {
  const AuthException([super.message = 'Kimlik doğrulama hatası']);
}

/// Kurallara uymayan girdi.
class ValidationException extends AppException {
  const ValidationException([super.message = 'Doğrulama hatası']);
}

/// Aranan kayıt yok.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Kayıt bulunamadı']);
}
