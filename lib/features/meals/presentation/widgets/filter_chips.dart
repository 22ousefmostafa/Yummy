import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MealsFilterChips extends StatelessWidget {
  final String selectedFilter;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const MealsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.isDark,
    required this.onChanged,
  });

  static const _filters = [
    _Filter(value: 'all', label: 'All'),
    _Filter(value: 'popular', label: '🔥 Popular'),
    _Filter(value: 'top_rated', label: '⭐ Top Rated'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final border = isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((f) {
          final isActive = f.value == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onChanged(f.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: isActive
                      ? null
                      : Border.all(color: border, width: 1),
                ),
                child: Text(
                  f.label,
                  style: AppTextStyles.caption(
                    color: isActive ? Colors.white : textSecondary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Filter {
  final String value;
  final String label;
  const _Filter({required this.value, required this.label});
}
