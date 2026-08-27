import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/home_entity.dart';
import 'food_image.dart';

class RecentRatingsSection extends StatelessWidget {
  final List<RecentRatingEntity> ratings;

  const RecentRatingsSection({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    if (ratings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                'Your Recent Ratings',
                style: AppTextStyles.h4(color: textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...ratings.map((r) => _RatingItem(rating: r, isDark: isDark)),
      ],
    );
  }
}

class _RatingItem extends StatelessWidget {
  final RecentRatingEntity rating;
  final bool isDark;

  const _RatingItem({required this.rating, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppColors.darkSurfaceBorder, width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF252550)
                  : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: FoodImage(
                imageUrl: rating.mealImageUrl,
                fallbackIcon: rating.mealIcon,
                iconSize: 22,
                width: 44,
                height: 44,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rating.mealName,
                  style: AppTextStyles.smallBold(color: textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  rating.timeAgo,
                  style: AppTextStyles.caption(color: textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFFFBA08),
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }
}
