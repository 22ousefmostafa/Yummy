import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;
  final bool isDark;

  const OnboardingDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        isDark ? const Color(0xFF3A3570) : const Color(0xFFE5E7EB);

    final activeColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) {
          final isActive = index == currentIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 10,
            width: isActive ? 30 : 10,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}