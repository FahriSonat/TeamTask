import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_center.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;

    final nError = Validators.validateName(name);
    final eError = Validators.validateEmail(email);
    final pError = Validators.validatePassword(password);
    String? cError;
    if (confirm.isEmpty) {
      cError = AppStrings.requiredField;
    } else if (confirm != password) {
      cError = AppStrings.passwordsDoNotMatch;
    }

    setState(() {
      _nameError = nError;
      _emailError = eError;
      _passwordError = pError;
      _confirmError = cError;
    });

    if (nError == null && eError == null && pError == null && cError == null) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(name: name, email: email, password: password),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/projects');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: ResponsiveCenter(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.formPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        AppSpacing.formPadding * 2,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.primaryTintColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.view_kanban_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.appBarTitle.copyWith(
                                color: context.isDark
                                    ? Colors.white
                                    : context.inkColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          AppStrings.registerTitle,
                          style: AppTextStyles.headline.copyWith(
                            color: context.isDark
                                ? Colors.white
                                : context.inkColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppStrings.registerSubtitle,
                          style: AppTextStyles.body.copyWith(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppTextField(
                          label: AppStrings.nameLabel,
                          hint: AppStrings.nameHint,
                          controller: _nameController,
                          errorText: _nameError,
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            color: context.isDark
                                ? Colors.white70
                                : context.inkMutedColor,
                          ),
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailHint,
                          controller: _emailController,
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: context.isDark
                                ? Colors.white70
                                : context.inkMutedColor,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordHint,
                          controller: _passwordController,
                          errorText: _passwordError,
                          obscureText: _obscurePassword,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: context.isDark
                                ? Colors.white70
                                : context.inkMutedColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: context.isDark
                                  ? Colors.white70
                                  : context.inkMutedColor,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: AppStrings.passwordConfirmLabel,
                          hint: AppStrings.passwordHint,
                          controller: _passwordConfirmController,
                          errorText: _confirmError,
                          obscureText: _obscurePassword,
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: context.isDark
                                ? Colors.white70
                                : context.inkMutedColor,
                          ),
                          onChanged: (_) {
                            if (_confirmError != null) {
                              setState(() => _confirmError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton(
                          text: AppStrings.registerButton,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              AppStrings.alreadyHaveAccount,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: context.isDark
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
