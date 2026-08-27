import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yumup/core/theme/theme_bloc/theme_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth/auth_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  void _toggleTheme() {
    context.read<ThemeBloc>().add(const ToggleThemeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AuthScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Responsive.gapSM(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: textPrimary,
                        size: Responsive.iconSize(context),
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleTheme,
                      icon: Icon(
                        isDark
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        color: textPrimary,
                        size: Responsive.iconSize(context, base: 24),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.gapXL(context)),
                Center(
                  child: AppLogo(
                    height: Responsive.logoSize(context),
                  ),
                ),
                SizedBox(height: Responsive.gapXXL(context)),
                Text(
                  'Welcome Back! 👋',
                  style: AppTextStyles.h2(
                    color: textPrimary,
                  ).copyWith(
                    fontSize: Responsive.textScaleAware(context, 28),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.gapSM(context)),
                Text(
                  'Login to continue',
                  style: AppTextStyles.body1(
                    color: textSecondary,
                  ).copyWith(
                    fontSize: Responsive.textScaleAware(context, 16),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.gapSection(context)),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.gapLG(context)),
                AppTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  onSubmitted: (_) => _onLoginPressed(),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: textSecondary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.gapLG(context)),
                AppButton(
                  text: 'LOGIN',
                  isLoading: isLoading,
                  onPressed: _onLoginPressed,
                  height: Responsive.buttonHeight(context),
                ),
                SizedBox(height: Responsive.gapSection(context)),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.body1(color: textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.register),
                        child: Text(
                          'Register Now',
                          style: AppTextStyles.body1(
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.gapXL(context)),
              ],
            ),
          ),
        );
      },
    );
  }
}
