import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.isDark,
    required this.onChanged,
  });

  static const _priorities = [
    _PriorityOption(value: 'low', label: 'Low', dot: Color(0xFF10B981)),
    _PriorityOption(value: 'medium', label: 'Medium', dot: Color(0xFFF59E0B)),
    _PriorityOption(value: 'high', label: 'High', dot: Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _priorities.map((p) {
        final isActive = p.value == selectedPriority;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: p.value == 'high' ? 0 : 10,
            ),
            child: _PriorityPill(
              option: p,
              isActive: isActive,
              isDark: isDark,
              onTap: () => onChanged(p.value),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriorityOption {
  final String value;
  final String label;
  final Color dot;

  const _PriorityOption({
    required this.value,
    required this.label,
    required this.dot,
  });
}

class _PriorityPill extends StatelessWidget {
  final _PriorityOption option;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _PriorityPill({
    required this.option,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primary : surface,
          borderRadius: BorderRadius.circular(24),
          border: isActive ? null : Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : option.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                option.label,
                style: AppTextStyles.caption(
                  color: isActive ? Colors.white : textSecondary,
                ).copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
