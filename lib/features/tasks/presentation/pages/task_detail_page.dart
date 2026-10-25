import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/priority_badge.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_event.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class TaskDetailPage extends StatefulWidget {
  final String projectId;
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(TasksLoadRequested(widget.projectId));
    context.read<ProjectBloc>().add(ProjectSelectRequested(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        Task? task;
        if (state is TasksLoaded) {
          task = state.tasks.where((t) => t.id == widget.taskId).firstOrNull;
        }

        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.taskDetail)),
            body: const Center(child: Text('Görev bulunamadı')),
          );
        }

        final members = context.select<ProjectBloc, List<User>>((bloc) {
          final pState = bloc.state;
          return pState is ProjectsLoaded ? pState.members : [];
        });
        final assignee = members
            .where((m) => m.id == task?.assigneeId)
            .firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(task.code),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: AppStrings.editTask,
                onPressed: () {
                  context.push(
                    '/project/${widget.projectId}/task/${widget.taskId}/edit',
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                tooltip: AppStrings.deleteTask,
                onPressed: () async {
                  final confirm = await ConfirmDialog.show(
                    context,
                    title: AppStrings.deleteTaskConfirmTitle,
                    message: AppStrings.deleteTaskConfirmMessage,
                    confirmText: AppStrings.delete,
                    isDestructive: true,
                  );
                  if (confirm && context.mounted) {
                    context.read<TaskBloc>().add(TaskDeleted(widget.taskId));
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık Kartı
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PriorityBadge(priority: task.priority),
                            StatusBadge(status: task.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(task.title, style: AppTextStyles.title),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            task.description,
                            style: AppTextStyles.body.copyWith(
                              color: context.inkMutedColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Hızlı Durum Değiştirici (Erişilebilirlik ve Menü)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppStrings.statusLabel,
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SegmentedButton<TaskStatus>(
                          segments: const [
                            ButtonSegment(
                              value: TaskStatus.todo,
                              label: Text(
                                AppStrings.statusTodo,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment(
                              value: TaskStatus.inProgress,
                              label: Text(
                                AppStrings.statusInProgress,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            ButtonSegment(
                              value: TaskStatus.done,
                              label: Text(
                                AppStrings.statusDone,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          selected: {task.status},
                          onSelectionChanged: (newSelection) {
                            context.read<TaskBloc>().add(
                              TaskStatusChanged(
                                taskId: task!.id,
                                newStatus: newSelection.first,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Detay Bilgileri Kartı
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.person_outline_rounded,
                          label: AppStrings.assigneeLabel,
                          value: assignee?.name ?? AppStrings.unassigned,
                        ),
                        const Divider(height: AppSpacing.xl),
                        _DetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: AppStrings.dueDateLabel,
                          value: task.dueDate != null
                              ? DateFormatter.formatFullDate(task.dueDate)
                              : 'Belirtilmedi',
                          valueColor: task.isOverdue
                              ? context.dangerTextColor
                              : null,
                          trailing: task.isOverdue
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.dangerTintColor,
                                    borderRadius: AppSpacing.borderRadiusChip,
                                  ),
                                  child: Text(
                                    AppStrings.overdue,
                                    style: AppTextStyles.caption.copyWith(
                                      color: context.dangerTextColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const Divider(height: AppSpacing.xl),
                        _DetailRow(
                          icon: Icons.history_rounded,
                          label: 'Oluşturulma',
                          value: DateFormatter.formatFullDate(task.createdAt),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.inkMutedColor),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTextStyles.bodyMuted),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            color: valueColor ?? context.inkColor,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
