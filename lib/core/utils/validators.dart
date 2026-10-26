// Dosya: lib/core/utils/validators.dart
// Form doğrulama kuralları. Hata varsa mesaj, yoksa null döner.

import '../constants/app_strings.dart';

/// Hem formlarda hem repository'lerde kullanılan ortak kurallar.
class Validators {
  const Validators._();

  /// Boş olmamalı ve ad@alan.uzanti biçiminde olmalı.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  /// En az 6 karakter.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Ad soyad 2-50 karakter.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 50) {
      return AppStrings.nameLengthError;
    }
    return null;
  }

  /// Proje adı 2-60 karakter.
  static String? validateProjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 60) {
      return AppStrings.projectNameLengthError;
    }
    return null;
  }

  /// Görev başlığı 1-80 karakter.
  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 80) {
      return AppStrings.taskTitleLengthError;
    }
    return null;
  }

  /// Açıklama en fazla 500 karakter (boş olabilir).
  static String? validateTaskDescription(String? value) {
    if (value != null && value.length > 500) {
      return AppStrings.descTooLong;
    }
    return null;
  }
}
