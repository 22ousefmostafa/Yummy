import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../bloc/meals_bloc.dart';
import '../bloc/meals_event.dart';
import '../bloc/meals_state.dart';
import '../widgets/filter_chips.dart';
import '../widgets/meal_grid_card.dart';
import '../widgets/meal_list_card.dart';
import '../widgets/sort_dropdown.dart';
import 'meal_details_screen.dart';

class MealsScreen extends StatelessWidget {
  final ValueNotifier<bool>? openSearchNotifier;

  const MealsScreen({super.key, this.openSearchNotifier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MealsBloc>()..add(const MealsLoadRequested()),
      child: _MealsContent(openSearchNotifier: openSearchNotifier),
    );
  }
}

class _MealsContent extends StatefulWidget {
  final ValueNotifier<bool>? openSearchNotifier;

  const _MealsContent({this.openSearchNotifier});

  @override
  State<_MealsContent> createState() => _MealsContentState();
}

class _MealsContentState extends State<_MealsContent> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    widget.openSearchNotifier?.addListener(_onOpenSearchRequested);
  }

  void _onOpenSearchRequested() {
    if (widget.openSearchNotifier?.value == true) {
      setState(() => _showSearch = true);
      widget.openSearchNotifier?.value = false;
    }
  }

  @override
  void dispose() {
    widget.openSearchNotifier?.removeListener(_onOpenSearchRequested);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return BlocBuilder<MealsBloc, MealsState>(
      builder: (context, state) {
        final isLoaded = state is MealsLoaded;
        final isGrid = isLoaded ? state.isGridView : false;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineBanner(),
                // App bar
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Meals',
                        style: AppTextStyles.h4(color: textPrimary),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchController.clear();
                            context
                                .read<MealsBloc>()
                                .add(const MealsSearchChanged(''));
                          }
                        }),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _showSearch ? primary : surface,
                            shape: BoxShape.circle,
                            border: _showSearch
                                ? null
                                : Border.all(color: border, width: 1),
                          ),
                          child: Icon(
                            _showSearch ? Icons.close : Icons.search,
                            size: 20,
                            color: _showSearch ? Colors.white : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                if (_showSearch)
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (q) => context
                          .read<MealsBloc>()
                          .add(MealsSearchChanged(q)),
                      style: TextStyle(
                          color: textPrimary,
                          fontFamily: 'poppins',
                          fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search meals...',
                        hintStyle:
                            TextStyle(color: textSecondary, fontSize: 14),
                        prefixIcon:
                            Icon(Icons.search, color: textSecondary, size: 20),
                        filled: true,
                        fillColor: surface,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primary),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Sort + filter row
                if (!_showSearch)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (isLoaded)
                          MealsSortDropdown(
                            sortBy: state.sortBy,
                            isDark: isDark,
                            onChanged: (s) => context
                                .read<MealsBloc>()
                                .add(MealsSortChanged(s)),
                          ),
                        const SizedBox(width: 10),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: border, width: 1),
                          ),
                          child: Icon(Icons.tune_rounded,
                              size: 18, color: textSecondary),
                        ),
                        const Spacer(),
                        // View toggle
                        _ViewToggleButton(
                          isGrid: isGrid,
                          isDark: isDark,
                          onToggle: () => context
                              .read<MealsBloc>()
                              .add(const MealsViewToggled()),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Filter chips
                if (isLoaded && !_showSearch)
                  MealsFilterChips(
                    selectedFilter: state.filterBy,
                    isDark: isDark,
                    onChanged: (f) => context
                        .read<MealsBloc>()
                        .add(MealsFilterChanged(f)),
                  ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: _buildBody(context, state, isDark, isGrid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, MealsState state, bool isDark, bool isGrid) {
    if (state is MealsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MealsError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(state.message,
                style: AppTextStyles.body2(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context
                  .read<MealsBloc>()
                  .add(const MealsLoadRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is MealsLoaded) {
      if (state.displayedMeals.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'No meals found',
                style: AppTextStyles.body2(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ],
          ),
        );
      }
      if (isGrid) {
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: state.displayedMeals.length,
          itemBuilder: (ctx, i) {
            final meal = state.displayedMeals[i];
            return MealGridCard(
              meal: meal,
              isDark: isDark,
              onTap: () => _openDetail(context, meal.id),
              onFavoriteTap: () => context
                  .read<MealsBloc>()
                  .add(MealsFavoriteToggled(meal.id)),
            );
          },
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        itemCount: state.displayedMeals.length,
        itemBuilder: (ctx, i) {
          final meal = state.displayedMeals[i];
          return MealListCard(
            meal: meal,
            isDark: isDark,
            onTap: () => _openDetail(context, meal.id),
            onFavoriteTap: () => context
                .read<MealsBloc>()
                .add(MealsFavoriteToggled(meal.id)),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  void _openDetail(BuildContext context, String mealId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealDetailsScreen(mealId: mealId),
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final bool isGrid;
  final bool isDark;
  final VoidCallback onToggle;

  const _ViewToggleButton({
    required this.isGrid,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.darkSurfaceBorder : const Color(0xFFE5E7EB);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            icon: Icons.list_rounded,
            isActive: !isGrid,
            activeColor: primary,
            inactiveColor: textSecondary,
            onTap: isGrid ? onToggle : null,
          ),
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            isActive: isGrid,
            activeColor: primary,
            inactiveColor: textSecondary,
            onTap: isGrid ? null : onToggle,
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback? onTap;

  const _ToggleBtn({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : inactiveColor,
        ),
      ),
    );
  }
}
