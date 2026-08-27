import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/meal_details_bloc.dart';
import '../bloc/meal_details_event.dart';
import '../bloc/meal_details_state.dart';
import '../widgets/rating_breakdown.dart';
import '../widgets/review_card.dart';
import 'rate_meal_screen.dart';

class MealDetailsScreen extends StatelessWidget {
  final String mealId;

  const MealDetailsScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MealDetailsBloc>()..add(MealDetailsLoadRequested(mealId)),
      child: const _MealDetailsContent(),
    );
  }
}

class _MealDetailsContent extends StatelessWidget {
  const _MealDetailsContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<MealDetailsBloc, MealDetailsState>(
      builder: (context, state) {
        if (state is MealDetailsLoading || state is MealDetailsInitial) {
          final bg =
              isDark ? AppColors.darkBackground : AppColors.lightBackground;
          return Scaffold(
            backgroundColor: bg,
            body:
                const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is MealDetailsError) {
          final bg =
              isDark ? AppColors.darkBackground : AppColors.lightBackground;
          return Scaffold(
            backgroundColor: bg,
            body: Center(child: Text(state.message)),
          );
        }
        if (state is MealDetailsLoaded) {
          return _MealDetailsBody(state: state, isDark: isDark);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MealDetailsBody extends StatefulWidget {
  final MealDetailsLoaded state;
  final bool isDark;

  const _MealDetailsBody({required this.state, required this.isDark});

  @override
  State<_MealDetailsBody> createState() => _MealDetailsBodyState();
}

class _MealDetailsBodyState extends State<_MealDetailsBody> {
  bool _descExpanded = false;

  @override
  Widget build(BuildContext context) {
    final meal = widget.state.meal;
    final isDark = widget.isDark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<MealDetailsBloc>(),
                    child: RateMealScreen(
                      mealId: meal.id,
                      mealName: meal.name,
                      categoryName: meal.categoryName,
                      imageUrl: meal.imageUrl,
                    ),
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('Rate This Meal',
                  style: AppTextStyles.button(color: Colors.white)),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero image header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bg,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => context
                      .read<MealDetailsBloc>()
                      .add(const MealDetailsFavoriteToggled()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.state.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: widget.state.isFavorite
                          ? Colors.red
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: meal.imageUrl != null
                  ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _EmojiPlaceholder(
                          icon: meal.categoryIcon, isDark: isDark),
                    )
                  : _EmojiPlaceholder(icon: meal.categoryIcon, isDark: isDark),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(meal.name, style: AppTextStyles.h3(color: textPrimary)),
                  const SizedBox(height: 8),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(meal.categoryIcon,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          meal.categoryName,
                          style: AppTextStyles.caption(color: primary)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: isDark
                          ? Border.all(color: border, width: 1)
                          : null,
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                    ),
                    child: Row(
                      children: [
                        _StatItem(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.lightAccent,
                          value: meal.avgOverall.toStringAsFixed(1),
                          label: 'Rating',
                          isDark: isDark,
                        ),
                        _VertDivider(isDark: isDark),
                        _StatItem(
                          icon: Icons.rate_review_rounded,
                          iconColor: primary,
                          value: '${meal.totalRatings}',
                          label: 'Ratings',
                          isDark: isDark,
                        ),
                        _VertDivider(isDark: isDark),
                        _StatItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: AppColors.lightSecondary,
                          value: '${meal.totalComments}',
                          label: 'Comments',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About
                  Text('About This Dish',
                      style: AppTextStyles.body1(color: textPrimary)
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (meal.description != null &&
                      meal.description!.isNotEmpty)
                    _ExpandableText(
                      text: meal.description!,
                      isDark: isDark,
                      isExpanded: _descExpanded,
                      onToggle: () =>
                          setState(() => _descExpanded = !_descExpanded),
                    )
                  else
                    Text('No description available.',
                        style: AppTextStyles.body2(color: textSecondary)),
                  const SizedBox(height: 24),

                  // Rating breakdown
                  RatingBreakdown(meal: meal, isDark: isDark),
                  const SizedBox(height: 24),

                  // Recent reviews
                  if (meal.recentReviews
                      .any((r) => r.comment != null &&
                          r.comment!.trim().isNotEmpty)) ...[
                    Text('Recent Reviews',
                        style: AppTextStyles.body1(color: textPrimary)
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    ...meal.recentReviews
                        .where((r) =>
                            r.comment != null &&
                            r.comment!.trim().isNotEmpty)
                        .take(5)
                        .map((r) => ReviewCard(review: r, isDark: isDark)),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiPlaceholder extends StatelessWidget {
  final String icon;
  final bool isDark;

  const _EmojiPlaceholder({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF252545) : const Color(0xFFF3F4F6),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 72)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.body1(color: textPrimary)
                  .copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.caption(color: textSecondary)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  final bool isDark;
  const _VertDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: isDark
          ? AppColors.darkSurfaceBorder
          : const Color(0xFFE5E7EB),
    );
  }
}

class _ExpandableText extends StatelessWidget {
  final String text;
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ExpandableText({
    required this.text,
    required this.isDark,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTextStyles.body2(color: textSecondary),
          maxLines: isExpanded ? null : 3,
          overflow:
              isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            isExpanded ? 'Show less ↑' : 'Read more →',
            style: AppTextStyles.caption(color: primary)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
