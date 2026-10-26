// Dosya: lib/features/tasks/presentation/pages/my_tasks_page.dart
// "Görevlerim" ekranı: bana atanan görevler ve durum filtreleri.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/my_tasks_cubit.dart';
import '../widgets/task_card.dart';
import '../../../../shared/widgets/responsive_center.dart';

/// Kişisel görev listesi.
class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// Oturumdaki kullanıcının görevlerini yükler.
  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<MyTasksCubit>().loadMyTasks(authState.user.id);
    }
  }

  /// Özet satırı, filtre chip'leri ve aşağı çekip yenilenebilen liste.
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName = authState is Authenticated ? authState.user.name : '';

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myTasksTitle)),
      body: ResponsiveCenter(
        child: BlocBuilder<MyTasksCubit, MyTasksState>(
          builder: (context, state) {
            if (state is MyTasksLoading || state is MyTasksInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MyTasksError) {
              return ErrorView(message: state.message, onRetry: _loadTasks);
            }

            if (state is MyTasksLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Özet Bilgi Kartı
                  Container(
                    color: context.surfaceColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePaddingMobile,
                      vertical: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$userName için görevler',
                            style: AppTextStyles.cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryTintColor,
                            borderRadius: AppSpacing.borderRadiusChip,
                          ),
                          child: Text(
                            '${state.openCount} açık / ${state.totalCount} toplam',
                            style: AppTextStyles.caption.copyWith(
                              color: context.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filtre Chipleri
                  Container(
                    color: context.surfaceColor,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(
                        left: AppSpacing.pagePaddingMobile,
                        right: AppSpacing.pagePaddingMobile,
                        bottom: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: AppStrings.filterAll,
                            isSelected: state.filter == MyTasksFilter.all,
                            onTap: () => context
                                .read<MyTasksCubit>()
                                .changeFilter(MyTasksFilter.all),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            label: AppStrings.statusTodo,
                            isSelected: state.filter == MyTasksFilter.todo,
                            onTap: () => context
                                .read<MyTasksCubit>()
                                .changeFilter(MyTasksFilter.todo),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            label: AppStrings.statusInProgress,
                            isSelected:
                                state.filter == MyTasksFilter.inProgress,
                            onTap: () => context
                                .read<MyTasksCubit>()
                                .changeFilter(MyTasksFilter.inProgress),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _FilterChip(
                            label: AppStrings.statusDone,
                            isSelected: state.filter == MyTasksFilter.done,
                            onTap: () => context
                                .read<MyTasksCubit>()
                                .changeFilter(MyTasksFilter.done),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Görev Listesi
                  Expanded(
                    child: state.filteredTasks.isEmpty
                        ? const EmptyView(
                            icon: Icons.task_alt_rounded,
                            title: AppStrings.noMyTasksTitle,
                            description: AppStrings.noMyTasksDesc,
                          )
                        : RefreshIndicator(
                            onRefresh: () async => _loadTasks(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(
                                AppSpacing.pagePaddingMobile,
                              ),
                              itemCount: state.filteredTasks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final task = state.filteredTasks[index];

                                return TaskCard(
                                  task: task,
                                  assigneeName: userName,
                                  onTap: () {
                                    context.push(
                                      '/project/${task.projectId}/task/${task.id}',
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Seçiliyken mavi dolgulu filtre chip'i.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: AppTextStyles.caption.copyWith(
        color: isSelected ? Colors.white : context.inkColor,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: context.fieldBgColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusChip,
        side: BorderSide(
          color: isSelected ? AppColors.primary : context.dividerColor,
        ),
      ),
      onSelected: (_) => onTap(),
    );
  }
}
