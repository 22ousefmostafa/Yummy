import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal_entity.dart';

class MealListCard extends StatelessWidget {
  final MealEntity meal;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const MealListCard({
    super.key,
    required this.meal,
    required this.isDark,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final imgBg = isDark ? const Color(0xFF252545) : const Color(0xFFF3F4F6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: border, width: 1) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: imgBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: meal.imageUrl != null
                    ? Image.network(
                        meal.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(meal.categoryIcon,
                              style: const TextStyle(fontSize: 32)),
                        ),
                      )
                    : Center(
                        child: Text(meal.categoryIcon,
                            style: const TextStyle(fontSize: 32)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTextStyles.body1(color: textPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 14, color: AppColors.lightAccent),
                      const SizedBox(width: 3),
                      Text(
                        meal.avgOverall.toStringAsFixed(1),
                        style: AppTextStyles.caption(color: textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${meal.totalRatings})',
                        style: AppTextStyles.caption(color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meal.categoryName,
                      style: AppTextStyles.caption(color: primary)
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Favorite
            GestureDetector(
              onTap: onFavoriteTap,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meal.isFavorite
                      ? primary.withAlpha(20)
                      : (isDark
                          ? const Color(0xFF252545)
                          : const Color(0xFFF3F4F6)),
                ),
                child: Icon(
                  meal.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: meal.isFavorite ? primary : textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
