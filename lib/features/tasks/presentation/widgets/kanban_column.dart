// Dosya: lib/features/tasks/presentation/widgets/kanban_column.dart
// Panodaki tek bir kolon: başlık, sayaç, sürüklenebilir kartlar, "Görev ekle" düğmesi.

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import 'task_card.dart';

/// Hem bırakma hedefi (DragTarget) hem kart listesidir.
class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final String title;
  final List<Task> tasks;
  final List<User> members;
  final double width;
  final ValueChanged<Task> onTaskTap;
  final Function(Task task, TaskStatus newStatus) onTaskDropped;
  final VoidCallback onAddTask;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.title,
    required this.tasks,
    required this.members,
    required this.width,
    required this.onTaskTap,
    required this.onTaskDropped,
    required this.onAddTask,
  });

  /// Atanan kullanıcı ID'sini ada çevirir.
  String _getAssigneeName(String? assigneeId) {
    if (assigneeId == null) return '';
    final member = members.where((m) => m.id == assigneeId).firstOrNull;
    return member?.name ?? '';
  }

  /// Kart üzerine gelinince kolon vurgulanır; bırakılınca onTaskDropped çağrılır.
  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      // Kart zaten bu kolondaysa bırakma kabul edilmez.
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        onTaskDropped(details.data, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? context.primaryTintColor.withValues(alpha: 0.3)
                : context.listBgColor,
            borderRadius: AppSpacing.borderRadiusColumn,
            border: Border.all(
              color: isHovered ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kolon Başlığı
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.inkColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Görev Listesi
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            AppStrings.noColumnTasks,
                            style: AppTextStyles.caption.copyWith(
                              color: context.inkMutedColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final assigneeName = _getAssigneeName(
                            task.assigneeId,
                          );

                          // Karta uzun basınca sürükleme başlar.
                          return LongPressDraggable<Task>(
                            data: task,
                            feedback: Material(
                              elevation: 6,
                              borderRadius: AppSpacing.borderRadiusCard,
                              child: SizedBox(
                                width: width - 16,
                                child: TaskCard(
                                  task: task,
                                  assigneeName: assigneeName,
                                ),
                              ),
                            ),
                            childWhenDragging: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Opacity(
                                opacity: 0.3,
                                child: TaskCard(
                                  task: task,
                                  assigneeName: assigneeName,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: TaskCard(
                                task: task,
                                assigneeName: assigneeName,
                                onTap: () => onTaskTap(task),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Kolon Altı Butonu
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: TextButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(AppStrings.addTask),
                  style: TextButton.styleFrom(
                    backgroundColor: context.surfaceColor,
                    foregroundColor: context.inkColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusCard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
