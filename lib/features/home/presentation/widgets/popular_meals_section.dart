import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/home_entity.dart';
import 'food_image.dart';

class PopularMealsSection extends StatelessWidget {
  final List<MealEntity> meals;
  final VoidCallback? onSeeAll;
  final void Function(String mealId)? onMealTap;
  final void Function(String mealId)? onFavoriteToggle;

  const PopularMealsSection({
    super.key,
    required this.meals,
    this.onSeeAll,
    this.onMealTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    'Popular Meals',
                    style: AppTextStyles.h4(color: textPrimary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: AppTextStyles.body2(color: primary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios, color: primary, size: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return _MealCard(
                meal: meal,
                isDark: isDark,
                onTap: () => onMealTap?.call(meal.id),
                onFavoriteToggle: () => onFavoriteToggle?.call(meal.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealEntity meal;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const _MealCard({
    required this.meal,
    required this.isDark,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: isDark
              ? Border.all(color: AppColors.darkSurfaceBorder, width: 1)
              : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FoodImage(
                      imageUrl: meal.imageUrl,
                      fallbackIcon: meal.categoryIcon,
                      iconSize: 52,
                      width: 72,
                      height: 72,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.name,
                    style: AppTextStyles.smallBold(color: textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFBA08),
                        size: 14,
                      ),
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
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    meal.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border,
                    color: meal.isFavorite
                        ? AppColors.error
                        : const Color(0xFFEF9A9A),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
