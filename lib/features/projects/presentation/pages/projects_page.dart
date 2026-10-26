// Dosya: lib/features/projects/presentation/pages/projects_page.dart
// Projeler listesi: kullanıcının projeleri, aktif proje vurgusu, tema ve çıkış.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../../../../shared/widgets/responsive_center.dart';

/// Giriş sonrası ilk ekran.
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  /// Oturumdaki kullanıcının projelerini yükler.
  void _loadProjects() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProjectBloc>().add(ProjectsLoadRequested(authState.user.id));
    }
  }

  /// Çıkış yapılınca login'e döner; proje kartına dokununca panosu açılır.
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.projectsTitle),
          actions: [
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
              icon: const Icon(Icons.logout_rounded),
              tooltip: AppStrings.logout,
              onPressed: () async {
                final confirm = await ConfirmDialog.show(
                  context,
                  title: AppStrings.logoutConfirmTitle,
                  message: AppStrings.logoutConfirmMessage,
                  confirmText: AppStrings.logout,
                  isDestructive: true,
                );
                if (confirm && context.mounted) {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                }
              },
            ),
          ],
        ),
        body: ResponsiveCenter(
          child: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading || state is ProjectInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProjectError) {
                return ErrorView(
                  message: state.message,
                  onRetry: _loadProjects,
                );
              }

              if (state is ProjectsLoaded) {
                if (state.projects.isEmpty) {
                  return EmptyView(
                    icon: Icons.folder_open_rounded,
                    title: AppStrings.noProjectsTitle,
                    description: AppStrings.noProjectsDesc,
                    actionText: AppStrings.newProject,
                    onAction: () => context.push('/projects/new'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadProjects(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
                    itemCount: state.projects.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      final isActive = state.activeProject?.id == project.id;

                      return Card(
                        elevation: isActive ? 1.5 : 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusCard,
                          side: BorderSide(
                            color: isActive
                                ? AppColors.primary
                                : context.borderColor,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: AppSpacing.borderRadiusCard,
                          onTap: () {
                            context.read<ProjectBloc>().add(
                              ProjectSelectRequested(project.id),
                            );
                            context.go('/project/${project.id}/board');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        project.name,
                                        style: AppTextStyles.cardTitle.copyWith(
                                          color: isActive
                                              ? context.primaryTextColor
                                              : context.inkColor,
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context.primaryTintColor,
                                          borderRadius:
                                              AppSpacing.borderRadiusChip,
                                        ),
                                        child: Text(
                                          'Aktif',
                                          style: AppTextStyles.caption.copyWith(
                                            color: context.primaryTextColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (project.description.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    project.description,
                                    style: AppTextStyles.bodyMuted,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.vpn_key_outlined,
                                      size: 14,
                                      color: context.inkMutedColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${AppStrings.inviteCodeLabel}: ${project.inviteCode}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: context.inkMutedColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: context.inkMutedColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(AppStrings.newProject),
          onPressed: () => context.push('/projects/new'),
        ),
      ),
    );
  }
}
