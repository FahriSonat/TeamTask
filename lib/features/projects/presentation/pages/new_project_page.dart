import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../cubit/project_form_cubit.dart';

class NewProjectPage extends StatelessWidget {
  const NewProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectFormCubit(),
      child: const _NewProjectView(),
    );
  }
}

class _NewProjectView extends StatefulWidget {
  const _NewProjectView();

  @override
  State<_NewProjectView> createState() => _NewProjectViewState();
}

class _NewProjectViewState extends State<_NewProjectView> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final formCubit = context.read<ProjectFormCubit>();
    if (!formCubit.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final state = formCubit.state;
    context.read<ProjectBloc>().add(
      ProjectCreateRequested(
        name: state.name,
        description: state.description,
        ownerId: authState.user.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectsLoaded && state.activeProject != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${state.activeProject!.name} projesi oluşturuldu.',
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/project/${state.activeProject!.id}/board');
        } else if (state is ProjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.createProject)),
        body: SafeArea(
          child: BlocBuilder<ProjectFormCubit, ProjectFormState>(
            builder: (context, formState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.formPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: AppStrings.projectNameLabel,
                      hint: AppStrings.projectNameHint,
                      controller: _nameController,
                      errorText: formState.nameError,
                      maxLength: 60,
                      onChanged: (val) =>
                          context.read<ProjectFormCubit>().nameChanged(val),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AppStrings.projectDescLabel,
                      hint: AppStrings.projectDescHint,
                      controller: _descController,
                      maxLines: 4,
                      maxLength: 300,
                      onChanged: (val) => context
                          .read<ProjectFormCubit>()
                          .descriptionChanged(val),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.primaryTintColor.withValues(alpha: 0.4),
                        borderRadius: AppSpacing.borderRadiusCard,
                        border: Border.all(color: context.primaryTintColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              AppStrings.localDemoNotice,
                              style: AppTextStyles.caption.copyWith(
                                color: context.primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppButton(
                      text: AppStrings.createProject,
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
