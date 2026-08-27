import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_featured_meals_usecase.dart';
import '../../domain/usecases/get_popular_meals_usecase.dart';
import '../../domain/usecases/get_recent_ratings_usecase.dart';
import '../../../meals/domain/repositories/meals_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetPopularMealsUseCase getPopularMealsUseCase;
  final GetFeaturedMealsUseCase getFeaturedMealsUseCase;
  final GetRecentRatingsUseCase getRecentRatingsUseCase;
  final MealsRepository mealsRepository;
  final SupabaseClient supabaseClient;
  late final StreamSubscription<({String mealId, bool isNowFavorite})> _favSub;

  HomeBloc({
    required this.getCategoriesUseCase,
    required this.getPopularMealsUseCase,
    required this.getFeaturedMealsUseCase,
    required this.getRecentRatingsUseCase,
    required this.mealsRepository,
    required this.supabaseClient,
  }) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeFavoriteToggled>(_onFavoriteToggled);
    on<HomeFavoriteExternallyChanged>(_onFavoriteExternallyChanged);

    _favSub = mealsRepository.favoriteChanges.listen((change) {
      add(HomeFavoriteExternallyChanged(change.mealId, change.isNowFavorite));
    });
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final rawName =
        supabaseClient.auth.currentUser?.userMetadata?['full_name']
            as String? ??
        'User';
    final firstName = rawName.split(' ').first;

    final results = await Future.wait([
      getCategoriesUseCase(),
      getPopularMealsUseCase(),
      getFeaturedMealsUseCase(),
      getRecentRatingsUseCase(),
    ]);

    for (final result in results) {
      final failed = result.fold((l) => l, (_) => null);
      if (failed != null) {
        emit(HomeError(failed.message));
        return;
      }
    }

    final categories =
        results[0].getOrElse(() => <CategoryEntity>[]) as List<CategoryEntity>;
    final popularMeals =
        results[1].getOrElse(() => <MealEntity>[]) as List<MealEntity>;
    final featuredMeals =
        results[2].getOrElse(() => <MealEntity>[]) as List<MealEntity>;
    final recentRatings =
        results[3].getOrElse(() => <RecentRatingEntity>[])
            as List<RecentRatingEntity>;

    final favResult = await mealsRepository.getFavoriteIds();
    final favoriteIds = favResult.fold((_) => <String>{}, (ids) => ids);

    final popularWithFav = popularMeals
        .map((m) => m.copyWith(isFavorite: favoriteIds.contains(m.id)))
        .toList();

    final banners = featuredMeals
        .map(
          (m) => PromoBannerEntity(
            id: m.id,
            label: "Today's Special",
            mealName: m.name,
            mealImageUrl: m.imageUrl,
            mealIcon: m.categoryIcon,
          ),
        )
        .toList();

    emit(HomeLoaded(
      userName: firstName,
      banners: banners,
      categories: categories,
      popularMeals: popularWithFav,
      recentRatings: recentRatings,
    ));
  }

  Future<void> _onFavoriteToggled(
    HomeFavoriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    // toggleFavorite broadcasts on stream → _onFavoriteExternallyChanged updates state
    await mealsRepository.toggleFavorite(event.mealId);
  }

  void _onFavoriteExternallyChanged(
    HomeFavoriteExternallyChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    final updated = current.popularMeals
        .map((m) =>
            m.id == event.mealId ? m.copyWith(isFavorite: event.isNowFavorite) : m)
        .toList();
    emit(current.copyWith(popularMeals: updated));
  }

  @override
  Future<void> close() {
    _favSub.cancel();
    return super.close();
  }
}
