// Dosya: lib/core/utils/password_hasher.dart
// Parolaların SHA-256 özetini alır; parolalar düz metin saklanmaz.

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Parola özetleme yardımcıları.
class PasswordHasher {
  const PasswordHasher._();

  /// Parolanın (baş/son boşluklar atılarak) SHA-256 özetini döndürür.
  static String hash(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Girilen parola kayıtlı özetle eşleşiyor mu?
  static bool verify(String password, String hash) {
    return PasswordHasher.hash(password) == hash;
  }
}
