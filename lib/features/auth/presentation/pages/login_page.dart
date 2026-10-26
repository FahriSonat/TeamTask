// Dosya: lib/features/auth/presentation/pages/login_page.dart
// Giriş ekranı (e-posta + parola).

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

/// Giriş formu.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Alanları doğrular; geçerliyse AuthBloc'a giriş olayı gönderir.
  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final eError = Validators.validateEmail(email);
    final pError = password.isEmpty ? AppStrings.requiredField : null;

    setState(() {
      _emailError = eError;
      _passwordError = pError;
    });

    if (eError == null && pError == null) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(email: email, password: password),
      );
    }
  }

  /// Başarılı girişte projelere geçer, hatada kırmızı SnackBar gösterir.
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
                // İçerik kısa olsa bile ekranı doldursun diye en az ekran yüksekliği verilir (alt bağlantı en altta durur).
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
                        const SizedBox(height: AppSpacing.xxl),
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
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          AppStrings.loginTitle,
                          style: AppTextStyles.headline.copyWith(
                            color: context.isDark
                                ? Colors.white
                                : context.inkColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppStrings.loginSubtitle,
                          style: AppTextStyles.body.copyWith(
                            color: context.isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
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
                        const SizedBox(height: AppSpacing.xxxl),
                        AppButton(
                          text: AppStrings.loginButton,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              AppStrings.dontHaveAccount,
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
