import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../meals/presentation/pages/meal_details_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/categories_section.dart';
import '../widgets/greeting_header.dart';
import '../widgets/popular_meals_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/recent_ratings_section.dart';
import '../../../history/presentation/pages/history_screen.dart';
import '../../../meals/presentation/pages/meals_list_screen.dart';
import '../../../notifications/presentation/bloc/notifications_bloc.dart';
import '../../../notifications/presentation/bloc/notifications_event.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../notifications/presentation/pages/notifications_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../suggest/presentation/pages/suggest_screen.dart';
import '../../../../shared/widgets/offline_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _openMealsSearch = ValueNotifier<bool>(false);
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _HomeTab(
        onSwitchToTab: _switchToTab,
        onSwitchToMealsSearch: _openMealsSearch,
      ),
      MealsScreen(openSearchNotifier: _openMealsSearch),
      SuggestScreen(
        onGoHome: () => _switchToTab(0),
      ),
      const HistoryScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _openMealsSearch.dispose();
    super.dispose();
  }

  void _switchToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeLoadRequested()),
      child: BlocProvider(
        create: (_) => sl<NotificationsBloc>()
          ..add(const NotificationsLoadRequested()),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.go(AppRoutes.login);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: IndexedStack(
                index: _selectedIndex,
                children: _tabs,
              ),
            ),
            bottomNavigationBar: _HomeBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: _switchToTab,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final void Function(int) onSwitchToTab;
  final ValueNotifier<bool> onSwitchToMealsSearch;

  const _HomeTab({
    required this.onSwitchToTab,
    required this.onSwitchToMealsSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OfflineBanner(),
        Expanded(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return Center(child: Text(state.message));
              }
              if (state is HomeLoaded) {
                return _HomeBody(
                  state: state,
                  onSwitchToTab: onSwitchToTab,
                  onSwitchToMealsSearch: onSwitchToMealsSearch,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeLoaded state;
  final void Function(int) onSwitchToTab;
  final ValueNotifier<bool> onSwitchToMealsSearch;

  const _HomeBody({
    required this.state,
    required this.onSwitchToTab,
    required this.onSwitchToMealsSearch,
  });

  void _openMealsWithSearch(BuildContext context, int tabIndex) {
    onSwitchToMealsSearch.value = true;
    onSwitchToTab(tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textHint =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final notificationsState = context.watch<NotificationsBloc>().state;
    final unreadCount = notificationsState is NotificationsLoaded
        ? notificationsState.unreadCount
        : 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GreetingHeader(
              userName: state.userName,
              unreadCount: unreadCount,
              onNotificationsTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<NotificationsBloc>(),
                    child: const NotificationsScreen(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Search bar — tapping opens Meals tab with search focused
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => _openMealsWithSearch(context, 1),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(24),
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
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(Icons.search, color: textHint, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Search meals...',
                      style: AppTextStyles.body2(color: textHint),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Promo banner — tapping navigates to MealDetailsScreen
          PromoBannerSection(
            banners: state.banners,
            onRateNow: (mealId) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MealDetailsScreen(mealId: mealId),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Categories
          CategoriesSection(categories: state.categories),
          const SizedBox(height: 24),

          // Popular meals
          PopularMealsSection(
            meals: state.popularMeals,
            onSeeAll: () => onSwitchToTab(1),
            onMealTap: (mealId) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MealDetailsScreen(mealId: mealId),
              ),
            ),
            onFavoriteToggle: (mealId) =>
                context.read<HomeBloc>().add(HomeFavoriteToggled(mealId)),
          ),
          const SizedBox(height: 24),

          // Recent ratings
          RecentRatingsSection(ratings: state.recentRatings),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _HomeBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final unselected =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkSurfaceBorder
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                outlinedIcon: Icons.home_outlined,
                label: 'Home',
                index: 0,
                selectedIndex: selectedIndex,
                activeColor: primary,
                inactiveColor: unselected,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.restaurant,
                outlinedIcon: Icons.restaurant_outlined,
                label: 'Meals',
                index: 1,
                selectedIndex: selectedIndex,
                activeColor: primary,
                inactiveColor: unselected,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.add_comment,
                outlinedIcon: Icons.add_comment_outlined,
                label: 'Suggest',
                index: 2,
                selectedIndex: selectedIndex,
                activeColor: primary,
                inactiveColor: unselected,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.history,
                outlinedIcon: Icons.history,
                label: 'History',
                index: 3,
                selectedIndex: selectedIndex,
                activeColor: primary,
                inactiveColor: unselected,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                outlinedIcon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 4,
                selectedIndex: selectedIndex,
                activeColor: primary,
                inactiveColor: unselected,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? icon : outlinedIcon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
