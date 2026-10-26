// Dosya: test/unit/validators_test.dart
// Validators testleri: tüm uzunluk ve biçim sınırları.

import 'package:flutter_test/flutter_test.dart';
import 'package:team_task/core/constants/app_strings.dart';
import 'package:team_task/core/utils/validators.dart';

/// Test grubu.
void main() {
  group('Validators Test', () {
    test('validateEmail validates format', () {
      expect(Validators.validateEmail(''), AppStrings.requiredField);
      expect(
        Validators.validateEmail('invalid-email'),
        AppStrings.invalidEmail,
      );
      expect(Validators.validateEmail('test@test'), AppStrings.invalidEmail);
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('validatePassword checks minimum length', () {
      expect(Validators.validatePassword(''), AppStrings.requiredField);
      expect(Validators.validatePassword('123'), AppStrings.passwordTooShort);
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateName checks length boundaries (2-50)', () {
      expect(Validators.validateName(''), AppStrings.requiredField);
      expect(Validators.validateName('A'), AppStrings.nameLengthError);
      expect(Validators.validateName('Esra'), isNull);
      expect(Validators.validateName('A' * 51), AppStrings.nameLengthError);
    });

    test('validateProjectName checks length boundaries (2-60)', () {
      expect(Validators.validateProjectName(''), AppStrings.requiredField);
      expect(
        Validators.validateProjectName('P'),
        AppStrings.projectNameLengthError,
      );
      expect(Validators.validateProjectName('Bitirme Projesi'), isNull);
      expect(
        Validators.validateProjectName('P' * 61),
        AppStrings.projectNameLengthError,
      );
    });

    test('validateTaskTitle checks length boundaries (1-80)', () {
      expect(Validators.validateTaskTitle(''), AppStrings.requiredField);
      expect(Validators.validateTaskTitle('   '), AppStrings.requiredField);
      expect(Validators.validateTaskTitle('Görevi Tamamla'), isNull);
      expect(
        Validators.validateTaskTitle('T' * 81),
        AppStrings.taskTitleLengthError,
      );
    });

    test('validateTaskDescription checks max 500 characters', () {
      expect(Validators.validateTaskDescription('Kısa açıklama'), isNull);
      expect(
        Validators.validateTaskDescription('A' * 501),
        AppStrings.descTooLong,
      );
      expect(Validators.validateTaskDescription(null), isNull);
    });
  });
}
