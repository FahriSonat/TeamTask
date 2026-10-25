import '../constants/app_strings.dart';

class Validators {
  const Validators._();

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

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

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

  static String? validateTaskDescription(String? value) {
    if (value != null && value.length > 500) {
      return AppStrings.descTooLong;
    }
    return null;
  }
}
