import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MealsSortDropdown extends StatelessWidget {
  final String sortBy;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const MealsSortDropdown({
    super.key,
    required this.sortBy,
    required this.isDark,
    required this.onChanged,
  });

  static const _options = [
    _SortOption(value: 'popular', label: 'Popular'),
    _SortOption(value: 'top_rated', label: 'Top Rated'),
    _SortOption(value: 'name', label: 'Name A-Z'),
  ];

  String get _currentLabel =>
      _options.firstWhere((o) => o.value == sortBy,
          orElse: () => _options.first).label;

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: () => _showPicker(context, surface, textPrimary, primary, border),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentLabel,
              style: AppTextStyles.caption(color: textPrimary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: primary),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, Color surface, Color textPrimary,
      Color primary, Color border) {
    final isDarkMode = isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkSurfaceBorder
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Sort By',
                    style: AppTextStyles.h4(color: textPrimary)),
              ),
              ..._options.map((opt) {
                final isSelected = opt.value == sortBy;
                return ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    onChanged(opt.value);
                  },
                  title: Text(opt.label,
                      style: AppTextStyles.body2(
                          color: isSelected ? primary : textPrimary)),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: primary, size: 20)
                      : null,
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption {
  final String value;
  final String label;
  const _SortOption({required this.value, required this.label});
}
