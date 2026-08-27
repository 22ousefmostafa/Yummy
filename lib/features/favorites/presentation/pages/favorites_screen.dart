import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../meals/presentation/pages/meal_details_screen.dart';
import '../../domain/entities/favorite_entity.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FavoritesLoadRequested()),
      child: const _FavoritesContent(),
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  const _FavoritesContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: surface,
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      'My Favorites',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h4(color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const OfflineBanner(),

            Expanded(
              child: BlocConsumer<FavoritesBloc, FavoritesState>(
                listenWhen: (_, curr) =>
                    curr is FavoritesLoaded && curr.removeError != null,
                listener: (context, state) {
                  if (state is FavoritesLoaded && state.removeError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.removeError!)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is FavoritesLoading || state is FavoritesInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FavoritesError) {
                    return _ErrorView(
                      message: state.message,
                      isDark: isDark,
                      onRetry: () => context
                          .read<FavoritesBloc>()
                          .add(const FavoritesLoadRequested()),
                    );
                  }
                  if (state is FavoritesLoaded) {
                    if (state.favorites.isEmpty) {
                      return _EmptyView(isDark: isDark);
                    }
                    return _FavoritesList(
                      favorites: state.favorites,
                      isDark: isDark,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  final List<FavoriteEntity> favorites;
  final bool isDark;

  const _FavoritesList({required this.favorites, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: favorites.length,
      itemBuilder: (ctx, i) => _FavoriteCard(
        favorite: favorites[i],
        isDark: isDark,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MealDetailsScreen(mealId: favorites[i].mealId),
          ),
        ),
        onRemove: () => context
            .read<FavoritesBloc>()
            .add(FavoriteRemoveRequested(favorites[i].mealId)),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteEntity favorite;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.favorite,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: border, width: 1) : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: favorite.mealImageUrl != null
                        ? Image.network(
                            favorite.mealImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _PlaceholderImage(
                              icon: favorite.categoryIcon,
                              isDark: isDark,
                            ),
                          )
                        : _PlaceholderImage(
                            icon: favorite.categoryIcon,
                            isDark: isDark,
                          ),
                  ),
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.mealName,
                    style: AppTextStyles.smallBold(color: textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        favorite.categoryIcon,
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          favorite.categoryName,
                          style: AppTextStyles.caption(color: textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          color: AppColors.lightAccent, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        favorite.avgOverall.toStringAsFixed(1),
                        style: AppTextStyles.caption(color: textPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${favorite.totalRatings})',
                        style: AppTextStyles.caption(color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final String icon;
  final bool isDark;

  const _PlaceholderImage({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6);
    return Container(
      width: double.infinity,
      color: bg,
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 40)),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: AppTextStyles.h4(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any meal to save it here.',
              style: AppTextStyles.body2(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.body2(color: textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('Try again',
                style: AppTextStyles.smallBold(color: primary)),
          ),
        ],
      ),
    );
  }
}
