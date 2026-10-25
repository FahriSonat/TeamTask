import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_context_extension.dart';
import '../../features/tasks/domain/enums/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, text, icon) = switch (priority) {
      TaskPriority.urgent => (
        context.dangerTintColor,
        context.dangerTextColor,
        AppStrings.priorityUrgent,
        Icons.priority_high_rounded,
      ),
      TaskPriority.medium => (
        context.primaryTintColor,
        context.primaryTextColor,
        AppStrings.priorityMedium,
        Icons.remove_rounded,
      ),
      TaskPriority.low => (
        context.dividerColor,
        context.inkMutedColor,
        AppStrings.priorityLow,
        Icons.arrow_downward_rounded,
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
