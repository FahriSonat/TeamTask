import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/priority_badge.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final String? assigneeName;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.assigneeName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isUpcoming =
        DateFormatter.isToday(task.dueDate) ||
        DateFormatter.isTomorrow(task.dueDate);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusCard,
        side: BorderSide(
          color: isOverdue
              ? AppColors.danger.withValues(alpha: 0.5)
              : context.borderColor,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: AppSpacing.borderRadiusCard,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Üst satır: Öncelik ve Kod
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriorityBadge(priority: task.priority),
                  Text(
                    task.code,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.inkMutedColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Başlık (max 3 satır)
              Text(
                task.title,
                style: AppTextStyles.cardTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              // Alt satır: Atanan kişi ve Teslim tarihi
              Row(
                children: [
                  // Atanan kişi avatarı / ismi
                  if (assigneeName != null && assigneeName!.isNotEmpty) ...[
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: context.primaryTintColor,
                      child: Text(
                        assigneeName![0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assigneeName!,
                        style: AppTextStyles.caption.copyWith(
                          color: context.inkColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: context.inkMutedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.unassigned,
                      style: AppTextStyles.caption.copyWith(
                        color: context.inkMutedColor,
                      ),
                    ),
                    const Spacer(),
                  ],
                  // Teslim tarihi rozeti
                  if (task.dueDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? context.dangerTintColor
                            : (isUpcoming
                                  ? context.warningTintColor
                                  : context.fieldBgColor),
                        borderRadius: AppSpacing.borderRadiusChip,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: isOverdue
                                ? context.dangerTextColor
                                : (isUpcoming
                                      ? context.warningTextColor
                                      : context.inkMutedColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? AppStrings.overdue
                                : DateFormatter.formatDate(task.dueDate),
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              fontWeight: isOverdue || isUpcoming
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isOverdue
                                  ? context.dangerTextColor
                                  : (isUpcoming
                                        ? context.warningTextColor
                                        : context.inkMutedColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
