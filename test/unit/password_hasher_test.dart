// Dosya: test/unit/password_hasher_test.dart
// PasswordHasher birim testleri: aynı girdi aynı özet, farklı girdi farklı özet.

import 'package:flutter_test/flutter_test.dart';
import 'package:team_task/core/utils/password_hasher.dart';

/// Test grubu.
void main() {
  group('PasswordHasher Test', () {
    test('same input produces identical hash', () {
      final hash1 = PasswordHasher.hash('secret123');
      final hash2 = PasswordHasher.hash('secret123');
      expect(hash1, equals(hash2));
    });

    test('different input produces different hash', () {
      final hash1 = PasswordHasher.hash('secret123');
      final hash2 = PasswordHasher.hash('secret124');
      expect(hash1, isNot(equals(hash2)));
    });

    test('verify returns true for matching password', () {
      final hash = PasswordHasher.hash('mypassword');
      expect(PasswordHasher.verify('mypassword', hash), isTrue);
      expect(PasswordHasher.verify('wrongpassword', hash), isFalse);
    });
  });
}
