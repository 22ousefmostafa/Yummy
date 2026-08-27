import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/history_entity.dart';
import '../../../home/presentation/widgets/food_image.dart';

class RatingHistoryCard extends StatelessWidget {
  final RatingHistoryEntity rating;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RatingHistoryCard({
    super.key,
    required this.rating,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image
            Container(
              width: 52,
              height: 52,
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
                  iconSize: 26,
                  width: 52,
                  height: 52,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rating.mealName,
                          style: AppTextStyles.smallBold(color: textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (rating.isEdited)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Edited',
                            style: AppTextStyles.caption(color: textSecondary)
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _StarRow(score: rating.overallScore),
                  if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      rating.comment!,
                      style: AppTextStyles.caption(color: textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _timeAgo(rating.createdAt),
                        style: AppTextStyles.caption(color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Actions
            Column(
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF60A5FA),
                  background: const Color(0xFFDBEAFE),
                  darkBackground: const Color(0xFF1E3A5F),
                  isDark: isDark,
                  onTap: onEdit,
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: const Color(0xFFF87171),
                  background: const Color(0xFFFEE2E2),
                  darkBackground: const Color(0xFF4A1515),
                  isDark: isDark,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min ago';
    return 'Just now';
  }
}

class _StarRow extends StatelessWidget {
  final double score;

  const _StarRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < score ? Icons.star_rounded : Icons.star_outline_rounded,
          color: const Color(0xFFFFBA08),
          size: 16,
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final Color darkBackground;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.darkBackground,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? darkBackground : background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}
