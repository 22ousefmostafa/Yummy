import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HistoryTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const HistoryTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return Row(
      children: [
        _TabPill(
          label: 'Ratings',
          icon: Icons.star_rounded,
          isActive: activeTab == 0,
          activeColor: primary,
          surface: surface,
          border: border,
          onTap: () => onTabChanged(0),
        ),
        const SizedBox(width: 12),
        _TabPill(
          label: 'Suggestions',
          icon: Icons.chat_bubble_outline,
          isActive: activeTab == 1,
          activeColor: primary,
          surface: surface,
          border: border,
          onTap: () => onTabChanged(1),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color surface;
  final Color border;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.surface,
    required this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor : surface,
          borderRadius: BorderRadius.circular(24),
          border: isActive ? null : Border.all(color: border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : activeColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.smallBold(
                color: isActive ? Colors.white : activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
