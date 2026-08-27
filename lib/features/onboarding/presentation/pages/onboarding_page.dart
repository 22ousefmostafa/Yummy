import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../../../shared/widgets/auth/auth_scaffold.dart';
import '../../../../shared/widgets/onboarding/onboarding_action_section.dart';
import '../../../../shared/widgets/onboarding/onboarding_dots_indicator.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/app_preferences.dart';
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  int _currentIndex = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'Rate Your Favorites',
      subtitle: 'Share your experience and help us improve every dish',
      lightImage: 'assets/images/onboarding1light.png',
      darkImage: 'assets/images/onboarding1dark.png',
      primaryButtonText: 'Next',
    ),
    OnboardingItem(
      title: 'Share Your Ideas',
      subtitle: 'Got a new dish idea? We\'d love to hear it',
      lightImage: 'assets/images/onboarding1light.png',
      darkImage: 'assets/images/onboarding1dark.png',
      primaryButtonText: 'Next',
    ),
    OnboardingItem(
      title: 'Track Everything',
      subtitle: 'Monitor your ratings and suggestion status anytime',
      lightImage: 'assets/images/onboarding2light.png',
      darkImage: 'assets/images/onboarding2dark.png',
      primaryButtonText: 'Get Started 🚀',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

Future<void> _completeOnboarding() async {
  await sl<AppPreferences>().setHasSeenOnboarding(true);

  if (!mounted) return;
  context.go(AppRoutes.login);
}

void _onNextPressed() {
  if (_currentIndex < _items.length - 1) {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  } else {
    _completeOnboarding();
  }
}

void _onSkipPressed() {
  _completeOnboarding();
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AuthScaffold(
      centerContent: true,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final imagePath =
                      isDark ? item.darkImage : item.lightImage;

                  return Column(
                    children: [
                      SizedBox(height: Responsive.gapXXL(context)),

                      Expanded(
                        flex: 5,
                        child: Center(
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.gapXL(context)),

                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2(
                          color: textPrimary,
                        ).copyWith(
                          fontSize: Responsive.textScaleAware(context, 28),
                        ),
                      ),

                      SizedBox(height: Responsive.gapLG(context)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.gapXXL(context),
                        ),
                        child: Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body1(
                            color: textSecondary,
                          ).copyWith(
                            fontSize: Responsive.textScaleAware(context, 16),
                            height: 1.55,
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.gapSection(context)),

                      OnboardingDotsIndicator(
                        currentIndex: _currentIndex,
                        count: _items.length,
                        isDark: isDark,
                      ),

                      SizedBox(height: Responsive.gapSection(context)),
                    ],
                  );
                },
              ),
            ),

            OnboardingActionSection(
              buttonText: _items[_currentIndex].primaryButtonText,
              onPrimaryPressed: _onNextPressed,
              onSkipPressed: _onSkipPressed,
              isDark: isDark,
            ),

            SizedBox(height: Responsive.gapLG(context)),
          ],
        ),
      ),
    );
  }
}