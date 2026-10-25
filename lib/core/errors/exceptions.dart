class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class CacheException extends AppException {
  const CacheException([super.message = 'Veri tabanı hatası oluştu']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Kimlik doğrulama hatası']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Doğrulama hatası']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Kayıt bulunamadı']);
}
