import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_priority.dart';
import '../../domain/enums/task_status.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../cubit/task_form_cubit.dart';
import '../../../../shared/widgets/responsive_center.dart';

class TaskFormPage extends StatelessWidget {
  final String projectId;
  final String? taskId;
  final String? initialStatus;

  const TaskFormPage({
    super.key,
    required this.projectId,
    this.taskId,
    this.initialStatus,
  });

  @override
  Widget build(BuildContext context) {
    Task? initialTask;
    if (taskId != null) {
      final taskState = context.read<TaskBloc>().state;
      if (taskState is TasksLoaded) {
        initialTask = taskState.tasks.where((t) => t.id == taskId).firstOrNull;
      }
    }

    final defaultStatus = switch (initialStatus) {
      'in_progress' => TaskStatus.inProgress,
      'done' => TaskStatus.done,
      _ => TaskStatus.todo,
    };

    return BlocProvider(
      create: (_) =>
          TaskFormCubit(initialTask: initialTask, defaultStatus: defaultStatus),
      child: _TaskFormView(projectId: projectId, initialTask: initialTask),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  final String projectId;
  final Task? initialTask;

  const _TaskFormView({required this.projectId, this.initialTask});

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final formState = context.read<TaskFormCubit>().state;
    _titleController = TextEditingController(text: formState.title);
    _descController = TextEditingController(text: formState.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate(BuildContext context, DateTime? currentDue) async {
    final now = DateTime.now();
    final initialDate = currentDue ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: AppStrings.selectDueDate,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.save,
    );

    if (picked != null && context.mounted) {
      context.read<TaskFormCubit>().dueDateChanged(picked);
    }
  }

  /// Sayfa doğrudan bağlantıyla açıldıysa geri yığını boş olabilir.
  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/project/${widget.projectId}/board');
    }
  }

  void _submit() {
    final cubit = context.read<TaskFormCubit>();
    if (!cubit.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final formState = cubit.state;

    if (widget.initialTask != null) {
      // Düzenleme
      final updated = widget.initialTask!.copyWith(
        title: formState.title,
        description: formState.description,
        status: formState.status,
        priority: formState.priority,
        assigneeId: formState.assigneeId,
        clearAssignee: formState.assigneeId == null,
        dueDate: formState.dueDate,
        clearDueDate: formState.dueDate == null,
      );
      context.read<TaskBloc>().add(TaskUpdated(updated));
    } else {
      // Yeni Görev
      final newTask = Task(
        id: '',
        projectId: widget.projectId,
        number: 0,
        title: formState.title,
        description: formState.description,
        status: formState.status,
        priority: formState.priority,
        assigneeId: formState.assigneeId,
        dueDate: formState.dueDate,
        createdBy: authState.user.id,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
      context.read<TaskBloc>().add(TaskAdded(newTask));
    }

    _close();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTask != null;
    final projectState = context.watch<ProjectBloc>().state;
    final members = projectState is ProjectsLoaded ? projectState.members : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editTask : AppStrings.addTask),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: AppStrings.cancel,
          onPressed: _close,
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              isEdit ? AppStrings.save : AppStrings.save,
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: SafeArea(
          child: BlocBuilder<TaskFormCubit, TaskFormState>(
            builder: (context, formState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.formPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Durum Seçici
                    const Text(
                      AppStrings.statusLabel,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
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
                      selected: {formState.status},
                      onSelectionChanged: (set) => context
                          .read<TaskFormCubit>()
                          .statusChanged(set.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Başlık Alanı
                    AppTextField(
                      label: AppStrings.taskTitleLabel,
                      hint: AppStrings.taskTitleHint,
                      controller: _titleController,
                      errorText: formState.titleError,
                      maxLength: 80,
                      onChanged: (val) =>
                          context.read<TaskFormCubit>().titleChanged(val),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Açıklama Alanı
                    AppTextField(
                      label: AppStrings.taskDescLabel,
                      hint: AppStrings.taskDescHint,
                      controller: _descController,
                      errorText: formState.descError,
                      maxLines: 4,
                      maxLength: 500,
                      onChanged: (val) =>
                          context.read<TaskFormCubit>().descriptionChanged(val),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Öncelik Seçici
                    const Text(
                      AppStrings.priorityLabel,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SegmentedButton<TaskPriority>(
                      showSelectedIcon: false,
                      expandedInsets: EdgeInsets.zero,
                      segments: const [
                        ButtonSegment(
                          value: TaskPriority.low,
                          label: Text(
                            AppStrings.priorityLow,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ButtonSegment(
                          value: TaskPriority.medium,
                          label: Text(
                            AppStrings.priorityMedium,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ButtonSegment(
                          value: TaskPriority.urgent,
                          label: Text(
                            AppStrings.priorityUrgent,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      selected: {formState.priority},
                      onSelectionChanged: (set) => context
                          .read<TaskFormCubit>()
                          .priorityChanged(set.first),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Atanan Kişi Seçimi
                    const Text(
                      AppStrings.assigneeLabel,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      // Üyeler sonradan yüklenirse alan yeniden kurulsun.
                      key: ValueKey(members.length),
                      initialValue:
                          members.any((m) => m.id == formState.assigneeId)
                          ? formState.assigneeId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: context.inkMutedColor,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(AppStrings.unassigned),
                        ),
                        ...members.map((m) {
                          return DropdownMenuItem<String?>(
                            value: m.id,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) =>
                          context.read<TaskFormCubit>().assigneeChanged(val),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Teslim Tarihi
                    const Text(
                      AppStrings.dueDateLabel,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    InkWell(
                      onTap: () => _pickDueDate(context, formState.dueDate),
                      borderRadius: AppSpacing.borderRadiusField,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: context.fieldBgColor,
                          borderRadius: AppSpacing.borderRadiusField,
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: context.inkMutedColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                formState.dueDate != null
                                    ? DateFormatter.formatFullDate(
                                        formState.dueDate,
                                      )
                                    : AppStrings.selectDueDate,
                                style: AppTextStyles.body.copyWith(
                                  color: formState.dueDate != null
                                      ? context.inkColor
                                      : context.inkMutedColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (formState.dueDate != null)
                              IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: context.inkMutedColor,
                                ),
                                tooltip: AppStrings.clearDate,
                                onPressed: () => context
                                    .read<TaskFormCubit>()
                                    .dueDateChanged(null),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppButton(
                      text: isEdit ? AppStrings.save : AppStrings.addTask,
                      onPressed: _submit,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
