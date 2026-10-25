import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_event.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../../domain/enums/task_status.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/kanban_column.dart';

class BoardPage extends StatefulWidget {
  final String projectId;
  const BoardPage({super.key, required this.projectId});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<TaskBloc>().add(TasksLoadRequested(widget.projectId));
    context.read<ProjectBloc>().add(
      ProjectMembersLoadRequested(widget.projectId),
    );
  }

  void _showProjectSwitcher(BuildContext context, ProjectsLoaded projectState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSheet,
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.selectProject, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: projectState.projects.length,
                    itemBuilder: (context, index) {
                      final p = projectState.projects[index];
                      final isCurrent = p.id == widget.projectId;

                      return ListTile(
                        leading: Icon(
                          Icons.folder_outlined,
                          color: isCurrent
                              ? AppColors.primary
                              : context.inkMutedColor,
                        ),
                        title: Text(
                          p.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: isCurrent
                                ? AppColors.primary
                                : context.inkColor,
                          ),
                        ),
                        trailing: isCurrent
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          if (!isCurrent) {
                            context.read<ProjectBloc>().add(
                              ProjectSelectRequested(p.id),
                            );
                            context.go('/project/${p.id}/board');
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push('/projects/new');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(AppStrings.newProject),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth >= 600 ? 320.0 : (screenWidth - 72.0);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.pagePaddingMobile,
        title: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            final projectName = state is ProjectsLoaded
                ? (state.projects
                          .where((p) => p.id == widget.projectId)
                          .firstOrNull
                          ?.name ??
                      state.activeProject?.name ??
                      AppStrings.appName)
                : AppStrings.appName;

            return InkWell(
              onTap: state is ProjectsLoaded
                  ? () => _showProjectSwitcher(context, state)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        projectName,
                        style: AppTextStyles.appBarTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: context.inkMutedColor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'Proje Sohbeti',
            onPressed: () => context.push('/project/${widget.projectId}/chat'),
          ),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: isDark ? 'Aydınlık Mod' : 'Karanlık Mod',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_copy_outlined),
            tooltip: AppStrings.projectsTitle,
            onPressed: () => context.go('/projects'),
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, taskState) {
          if (taskState is TaskLoading || taskState is TaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskState is TaskError && taskState.previousTasks == null) {
            return ErrorView(message: taskState.message, onRetry: _loadData);
          }

          final tasksLoaded = taskState is TasksLoaded
              ? taskState
              : (taskState is TaskError && taskState.previousTasks != null
                    ? TasksLoaded(tasks: taskState.previousTasks!)
                    : const TasksLoaded(tasks: []));

          final members = context.select<ProjectBloc, List<User>>((bloc) {
            final state = bloc.state;
            return state is ProjectsLoaded ? state.members : [];
          });

          return Column(
            children: [
              // İlerleme Çubuğu ve Özet
              Container(
                color: context.surfaceColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePaddingMobile,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: tasksLoaded.progress,
                          backgroundColor: context.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.successTextColor,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${tasksLoaded.doneCount}/${tasksLoaded.totalCount} ${AppStrings.statusDone}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Yatay Kaydırılabilir Kanban Kolonları
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePaddingMobile / 2,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    KanbanColumn(
                      status: TaskStatus.todo,
                      title: AppStrings.statusTodo,
                      tasks: tasksLoaded.todoTasks,
                      members: members,
                      width: columnWidth,
                      onTaskTap: (task) {
                        context.push(
                          '/project/${widget.projectId}/task/${task.id}',
                        );
                      },
                      onTaskDropped: (task, newStatus) {
                        context.read<TaskBloc>().add(
                          TaskStatusChanged(
                            taskId: task.id,
                            newStatus: newStatus,
                          ),
                        );
                      },
                      onAddTask: () {
                        context.push(
                          '/project/${widget.projectId}/task/new?status=todo',
                        );
                      },
                    ),
                    KanbanColumn(
                      status: TaskStatus.inProgress,
                      title: AppStrings.statusInProgress,
                      tasks: tasksLoaded.inProgressTasks,
                      members: members,
                      width: columnWidth,
                      onTaskTap: (task) {
                        context.push(
                          '/project/${widget.projectId}/task/${task.id}',
                        );
                      },
                      onTaskDropped: (task, newStatus) {
                        context.read<TaskBloc>().add(
                          TaskStatusChanged(
                            taskId: task.id,
                            newStatus: newStatus,
                          ),
                        );
                      },
                      onAddTask: () {
                        context.push(
                          '/project/${widget.projectId}/task/new?status=in_progress',
                        );
                      },
                    ),
                    KanbanColumn(
                      status: TaskStatus.done,
                      title: AppStrings.statusDone,
                      tasks: tasksLoaded.doneTasks,
                      members: members,
                      width: columnWidth,
                      onTaskTap: (task) {
                        context.push(
                          '/project/${widget.projectId}/task/${task.id}',
                        );
                      },
                      onTaskDropped: (task, newStatus) {
                        context.read<TaskBloc>().add(
                          TaskStatusChanged(
                            taskId: task.id,
                            newStatus: newStatus,
                          ),
                        );
                      },
                      onAddTask: () {
                        context.push(
                          '/project/${widget.projectId}/task/new?status=done',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        elevation: 2,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.push('/project/${widget.projectId}/chat');
          } else if (index == 2) {
            context.push('/my-tasks');
          } else if (index == 3) {
            context.push('/project/${widget.projectId}/members');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.view_kanban_outlined),
            selectedIcon: Icon(
              Icons.view_kanban_rounded,
              color: AppColors.primary,
            ),
            label: AppStrings.navBoard,
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.primary,
            ),
            label: 'Sohbet',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(
              Icons.assignment_ind_rounded,
              color: AppColors.primary,
            ),
            label: AppStrings.navMyTasks,
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded, color: AppColors.primary),
            label: AppStrings.navProject,
          ),
        ],
      ),
    );
  }
}
