import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../app_button.dart';

class OnboardingActionSection extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSkipPressed;
  final bool isDark;

  const OnboardingActionSection({
    super.key,
    required this.buttonText,
    required this.onPrimaryPressed,
    required this.onSkipPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final skipColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        AppButton(
          text: buttonText,
          onPressed: onPrimaryPressed,
          height: Responsive.buttonHeight(context),
        ),
        SizedBox(height: Responsive.gapLG(context)),
        GestureDetector(
          onTap: onSkipPressed,
          child: Text(
            'Skip',
            style: AppTextStyles.body1(color: skipColor),
          ),
        ),
      ],
    );
  }
}