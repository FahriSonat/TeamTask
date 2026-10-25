import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_context_extension.dart';
import 'app_button.dart';

class ConfirmDialog {
  const ConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = AppStrings.delete,
    String cancelText = AppStrings.cancel,
    bool isDestructive = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSheet,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  text: confirmText,
                  backgroundColor: isDestructive
                      ? AppColors.danger
                      : AppColors.primary,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  text: cancelText,
                  isOutlined: true,
                  textColor: ctx.inkMutedColor,
                  backgroundColor: ctx.borderColor,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}
