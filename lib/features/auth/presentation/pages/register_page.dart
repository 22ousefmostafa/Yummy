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
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth/auth_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  void _toggleTheme() {
    context.read<ThemeBloc>().add(const ToggleThemeEvent());
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _onRegisterPressed() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  int get _passwordStrength {
    final password = _passwordController.text.trim();

    if (password.isEmpty) return 0;

    int score = 0;

    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) ||
        RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      score++;
    }

    return score.clamp(0, 3);
  }

  String get _passwordStrengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Weak Password';
      case 2:
        return 'Medium Password';
      case 3:
        return 'Strong Password';
      default:
        return '';
    }
  }

  Color _strengthColor(BuildContext context, int index, bool isDark) {
    if (_passwordStrength == 0) {
      return isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE9ECEF);
    }

    if (index >= _passwordStrength) {
      return isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE9ECEF);
    }

    if (_passwordStrength == 1) return AppColors.error;
    if (_passwordStrength == 2) return AppColors.warning;

    return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
  }

  Color _strengthTextColor(bool isDark) {
    if (_passwordStrength == 1) return AppColors.error;
    if (_passwordStrength == 2) return AppColors.warning;
    if (_passwordStrength == 3) {
      return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    }

    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
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
                      onPressed: () => context.pop(),
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
                Text(
                  'Create Account 🎉',
                  style: AppTextStyles.h2(
                    color: textPrimary,
                  ).copyWith(
                    fontSize: Responsive.textScaleAware(context, 28),
                  ),
                ),
                SizedBox(height: Responsive.gapSM(context)),
                Text(
                  'Join us today',
                  style: AppTextStyles.body1(
                    color: textSecondary,
                  ).copyWith(
                    fontSize: Responsive.textScaleAware(context, 16),
                  ),
                ),
                SizedBox(height: Responsive.gapXXL(context)),
                AppTextField(
                  controller: _fullNameController,
                  hintText: 'Full Name',
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Full name'),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.gapLG(context)),
                AppTextField(
                  controller: _emailController,
                  hintText: 'Email',
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
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
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
                SizedBox(height: Responsive.gapMD(context)),
                if (_passwordController.text.isNotEmpty) ...[
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index == 2 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: _strengthColor(context, index, isDark),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.gapSM(context)),
                  Text(
                    _passwordStrengthLabel,
                    style: AppTextStyles.body2(
                      color: _strengthTextColor(isDark),
                    ),
                  ),
                  SizedBox(height: Responsive.gapLG(context)),
                ],
                AppTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmPassword,
                  onSubmitted: (_) => _onRegisterPressed(),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: textSecondary,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.gapLG(context)),
                AppButton(
                  text: 'REGISTER',
                  isLoading: isLoading,
                  onPressed: _onRegisterPressed,
                  height: Responsive.buttonHeight(context),
                ),
                SizedBox(height: Responsive.gapXXL(context)),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body1(color: textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Login',
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
