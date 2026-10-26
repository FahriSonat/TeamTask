// Dosya: lib/core/theme/theme_context_extension.dart
// BuildContext üzerine temaya duyarlı renk kısayolları.
// Örn. context.inkColor açık temada koyu, koyu temada açık renk verir.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Her ekranda "isDark ? a : b" yazmamak için kısayollar.
extension ThemeContextExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get backgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.background;
  Color get listBgColor => isDark ? AppColors.darkListBg : AppColors.listBg;
  Color get fieldBgColor => isDark ? AppColors.darkFieldBg : AppColors.fieldBg;
  Color get inkColor => isDark ? AppColors.darkInk : AppColors.ink;
  Color get inkMutedColor =>
      isDark ? AppColors.darkInkMuted : AppColors.inkMuted;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.border;
  Color get dividerColor => isDark ? AppColors.darkDivider : AppColors.divider;
  Color get primaryTintColor =>
      isDark ? AppColors.darkPrimaryTint : AppColors.primaryTint;
  Color get primaryTextColor =>
      isDark ? AppColors.darkPrimaryText : AppColors.primaryDark;
  Color get dangerTintColor =>
      isDark ? AppColors.darkDangerTint : AppColors.dangerTint;
  Color get dangerTextColor =>
      isDark ? AppColors.darkDangerText : AppColors.danger;
  Color get successTintColor =>
      isDark ? AppColors.darkSuccessTint : AppColors.successTint;
  Color get successTextColor =>
      isDark ? AppColors.darkSuccessText : AppColors.success;
  Color get warningTintColor =>
      isDark ? AppColors.darkWarningTint : AppColors.warningTint;
  Color get warningTextColor =>
      isDark ? AppColors.darkWarningText : AppColors.warning;
}
