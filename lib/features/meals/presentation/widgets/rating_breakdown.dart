import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entity.dart';

class RatingBreakdown extends StatelessWidget {
  final MealDetailEntity meal;
  final bool isDark;

  const RatingBreakdown({super.key, required this.meal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final rows = [
      _Row(icon: '🍴', label: 'Taste', value: meal.avgTaste),
      _Row(icon: '🎨', label: 'Presentation', value: meal.avgPresentation),
      _Row(icon: '🍽️', label: 'Portion', value: meal.avgPortion),
      _Row(icon: '💰', label: 'Value', value: meal.avgValue),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating Breakdown',
            style: AppTextStyles.body1(color: textPrimary)
                .copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BreakdownRow(row: r, isDark: isDark, primary: primary),
            )),
      ],
    );
  }
}

class _Row {
  final String icon;
  final String label;
  final double value;
  const _Row({required this.icon, required this.label, required this.value});
}

class _BreakdownRow extends StatelessWidget {
  final _Row row;
  final bool isDark;
  final Color primary;

  const _BreakdownRow({
    required this.row,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final barBg = isDark ? const Color(0xFF252545) : const Color(0xFFE5E7EB);

    return Row(
      children: [
        Text(row.icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            row.label,
            style: AppTextStyles.caption(color: textPrimary)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: row.value / 5.0,
              minHeight: 6,
              backgroundColor: barBg,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 28,
          child: Text(
            row.value.toStringAsFixed(1),
            style: AppTextStyles.caption(color: primary)
                .copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
