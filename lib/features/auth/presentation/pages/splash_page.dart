import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasStartedAuthCheck = false;

  @override
  void initState() {
    super.initState();
    _handleStartupFlow();
  }

  Future<void> _handleStartupFlow() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final hasSeenOnboarding = sl<AppPreferences>().getHasSeenOnboarding();

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go(AppRoutes.onboarding);
      return;
    }

    _hasStartedAuthCheck = true;
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  void _handleAuthState(AuthState state) {
    if (!mounted || !_hasStartedAuthCheck) return;

    if (state is Authenticated) {
      context.go(AppRoutes.home);
    } else if (state is Unauthenticated || state is AuthError) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final progressBackground =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final progressValueColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Center(
                child: AppLogo(height: 64),
              ),
              const SizedBox(height: 20),
              Text(
                'YumUp',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your Taste Matters',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                    ),
              ),
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    value: 0.72,
                    backgroundColor: progressBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressValueColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}