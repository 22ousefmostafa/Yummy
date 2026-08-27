import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/meal_entity.dart';
import '../../data/models/meal_model.dart';
import '../../domain/usecases/get_meals_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/search_meals_usecase.dart';
import '../../domain/repositories/meals_repository.dart';
import 'meals_event.dart';
import 'meals_state.dart';

class MealsBloc extends Bloc<MealsEvent, MealsState> {
  final GetMealsUseCase getMealsUseCase;
  final GetMealCategoriesUseCase getCategoriesUseCase;
  final SearchMealsUseCase searchMealsUseCase;
  final MealsRepository repository;
  late final StreamSubscription<({String mealId, bool isNowFavorite})> _favSub;

  MealsBloc({
    required this.getMealsUseCase,
    required this.getCategoriesUseCase,
    required this.searchMealsUseCase,
    required this.repository,
  }) : super(const MealsInitial()) {
    on<MealsLoadRequested>(_onLoad);
    on<MealsSortChanged>(_onSortChanged);
    on<MealsFilterChanged>(_onFilterChanged);
    on<MealsCategoryChanged>(_onCategoryChanged);
    on<MealsSearchChanged>(_onSearchChanged);
    on<MealsViewToggled>(_onViewToggled);
    on<MealsFavoriteToggled>(_onFavoriteToggled);
    on<MealsFavoriteExternallyChanged>(_onFavoriteExternallyChanged);

    _favSub = repository.favoriteChanges.listen((change) {
      add(MealsFavoriteExternallyChanged(change.mealId, change.isNowFavorite));
    });
  }

  Future<void> _onLoad(MealsLoadRequested event, Emitter<MealsState> emit) async {
    emit(const MealsLoading());

    final catResult = await getCategoriesUseCase();
    final categories = catResult.fold((_) => <MealCategoryModel>[], (c) => c);

    final favResult = await repository.getFavoriteIds();
    final favoriteIds = favResult.fold((_) => <String>{}, (ids) => ids);

    final mealsResult = await getMealsUseCase(
      categoryId: event.categoryId,
      sortBy: 'popular',
      filterBy: 'all',
    );

    mealsResult.fold(
      (failure) => emit(MealsError(failure.message)),
      (meals) {
        final withFav = meals
            .map((m) => m.copyWith(isFavorite: favoriteIds.contains(m.id)))
            .toList();
        emit(MealsLoaded(
          allMeals: withFav,
          displayedMeals: withFav,
          categories: categories,
          selectedCategoryId: event.categoryId,
          favoriteIds: favoriteIds,
        ));
      },
    );
  }

  Future<void> _onSortChanged(MealsSortChanged event, Emitter<MealsState> emit) async {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    final updated = current.copyWith(sortBy: event.sortBy);
    emit(updated.copyWith(displayedMeals: _apply(updated)));
    await _reload(emit, updated.copyWith(sortBy: event.sortBy));
  }

  Future<void> _onFilterChanged(MealsFilterChanged event, Emitter<MealsState> emit) async {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    final updated = current.copyWith(filterBy: event.filterBy);
    await _reload(emit, updated);
  }

  Future<void> _onCategoryChanged(MealsCategoryChanged event, Emitter<MealsState> emit) async {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    final updated = event.categoryId == null
        ? current.copyWith(clearCategory: true)
        : current.copyWith(selectedCategoryId: event.categoryId);
    await _reload(emit, updated);
  }

  void _onSearchChanged(MealsSearchChanged event, Emitter<MealsState> emit) {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    final filtered = searchMealsUseCase(current.allMeals, event.query);
    emit(current.copyWith(
      searchQuery: event.query,
      displayedMeals: filtered,
    ));
  }

  void _onViewToggled(MealsViewToggled event, Emitter<MealsState> emit) {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    emit(current.copyWith(isGridView: !current.isGridView));
  }

  Future<void> _onFavoriteToggled(
      MealsFavoriteToggled event, Emitter<MealsState> emit) async {
    if (state is! MealsLoaded) return;
    // toggleFavorite broadcasts on stream → _onFavoriteExternallyChanged updates state
    await repository.toggleFavorite(event.mealId);
  }

  void _onFavoriteExternallyChanged(
      MealsFavoriteExternallyChanged event, Emitter<MealsState> emit) {
    if (state is! MealsLoaded) return;
    final current = state as MealsLoaded;
    final newFavIds = Set<String>.from(current.favoriteIds);
    if (event.isNowFavorite) {
      newFavIds.add(event.mealId);
    } else {
      newFavIds.remove(event.mealId);
    }
    final updatedAll = current.allMeals
        .map((m) => m.id == event.mealId
            ? m.copyWith(isFavorite: event.isNowFavorite)
            : m)
        .toList();
    final updatedDisplayed = current.displayedMeals
        .map((m) => m.id == event.mealId
            ? m.copyWith(isFavorite: event.isNowFavorite)
            : m)
        .toList();
    emit(current.copyWith(
      allMeals: updatedAll,
      displayedMeals: updatedDisplayed,
      favoriteIds: newFavIds,
    ));
  }

  Future<void> _reload(Emitter<MealsState> emit, MealsLoaded updated) async {
    final result = await getMealsUseCase(
      categoryId: updated.selectedCategoryId,
      sortBy: updated.sortBy,
      filterBy: updated.filterBy,
    );
    result.fold(
      (failure) => emit(MealsError(failure.message)),
      (meals) {
        final withFav = meals
            .map((m) =>
                m.copyWith(isFavorite: updated.favoriteIds.contains(m.id)))
            .toList();
        final displayed = searchMealsUseCase(withFav, updated.searchQuery);
        emit(updated.copyWith(
          allMeals: withFav,
          displayedMeals: displayed,
        ));
      },
    );
  }

  List<MealEntity> _apply(MealsLoaded state) {
    return searchMealsUseCase(state.allMeals, state.searchQuery);
  }

  @override
  Future<void> close() {
    _favSub.cancel();
    return super.close();
  }
}
