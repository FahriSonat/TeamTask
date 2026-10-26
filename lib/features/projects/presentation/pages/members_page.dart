import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../../../../shared/widgets/responsive_center.dart';

class MembersPage extends StatefulWidget {
  final String projectId;
  const MembersPage({super.key, required this.projectId});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  @override
  void initState() {
    super.initState();
    final pBloc = context.read<ProjectBloc>();
    final authState = context.read<AuthBloc>().state;
    if (pBloc.state is! ProjectsLoaded && authState is Authenticated) {
      pBloc.add(ProjectsLoadRequested(authState.user.id));
    }
    pBloc.add(ProjectMembersLoadRequested(widget.projectId));
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSheet,
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.formPadding,
            right: AppSpacing.formPadding,
            top: AppSpacing.xxl,
            bottom:
                MediaQuery.of(bottomSheetContext).viewInsets.bottom +
                AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.addMemberTitle, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.nameLabel,
                hint: 'Örn: Ahmet Can',
                controller: nameCtrl,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: AppStrings.emailLabel,
                hint: 'ahmet@ekip.com',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: AppStrings.addLocalMember,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  if (name.isNotEmpty && email.isNotEmpty) {
                    final newUser = User(
                      id: const Uuid().v4(),
                      name: name,
                      email: email.toLowerCase(),
                      createdAt: DateTime.now().toUtc(),
                    );
                    context.read<ProjectBloc>().add(
                      ProjectMemberAddRequested(
                        projectId: widget.projectId,
                        user: newUser,
                      ),
                    );
                    Navigator.of(bottomSheetContext).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.membersTitle)),
      body: ResponsiveCenter(
        child: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is! ProjectsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final project = state.projects.firstWhere(
              (p) => p.id == widget.projectId,
              orElse: () => state.activeProject ?? state.projects.first,
            );

            final members = state.members;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePaddingMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Proje Bilgi Kartı
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.name, style: AppTextStyles.title),
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              project.description,
                              style: AppTextStyles.bodyMuted,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.inviteCodeLabel,
                                      style: AppTextStyles.caption,
                                    ),
                                    Text(
                                      project.inviteCode,
                                      style: AppTextStyles.headline.copyWith(
                                        color: AppColors.primary,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: project.inviteCode),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        AppStrings.inviteCodeCopied,
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: const Text(AppStrings.copyInviteCode),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(
                                    0,
                                    AppSpacing.minTouchTarget,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${AppStrings.membersTitle} (${members.length})',
                          style: AppTextStyles.sectionTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddMemberDialog(context),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text(AppStrings.addLocalMember),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isOwner = member.id == project.ownerId;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isOwner
                                ? AppColors.primary
                                : context.primaryTintColor,
                            foregroundColor: isOwner
                                ? Colors.white
                                : context.primaryTextColor,
                            child: Text(
                              member.name.isNotEmpty
                                  ? member.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(
                            member.name,
                            style: AppTextStyles.cardTitle,
                          ),
                          subtitle: Text(
                            member.email,
                            style: AppTextStyles.caption,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isOwner
                                  ? context.primaryTintColor
                                  : context.dividerColor,
                              borderRadius: AppSpacing.borderRadiusChip,
                            ),
                            child: Text(
                              isOwner ? 'Yönetici' : 'Üye',
                              style: AppTextStyles.caption.copyWith(
                                color: isOwner
                                    ? context.primaryTextColor
                                    : context.inkMutedColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
