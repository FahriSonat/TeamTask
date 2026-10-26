// Dosya: lib/shared/widgets/status_badge.dart
// Durum rozeti (Yapılacak / Devam ediyor / Tamamlandı).

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_context_extension.dart';
import '../../features/tasks/domain/enums/task_status.dart';

/// Duruma göre renk ve metin.
class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({super.key, required this.status});

  /// Renkler açık/koyu temaya göre seçilir.
  @override
  Widget build(BuildContext context) {
    final (bg, fg, text, icon) = switch (status) {
      TaskStatus.todo => (
        context.dividerColor,
        context.inkColor,
        AppStrings.statusTodo,
        Icons.circle_outlined,
      ),
      TaskStatus.inProgress => (
        context.primaryTintColor,
        context.primaryTextColor,
        AppStrings.statusInProgress,
        Icons.timelapse_rounded,
      ),
      TaskStatus.done => (
        context.successTintColor,
        context.successTextColor,
        AppStrings.statusDone,
        Icons.check_circle_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppSpacing.borderRadiusChip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
