import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_entity.dart';
import '../../data/models/meal_model.dart';

abstract class MealsState extends Equatable {
  const MealsState();
  @override
  List<Object?> get props => [];
}

class MealsInitial extends MealsState {
  const MealsInitial();
}

class MealsLoading extends MealsState {
  const MealsLoading();
}

class MealsLoaded extends MealsState {
  final List<MealEntity> allMeals;
  final List<MealEntity> displayedMeals;
  final List<MealCategoryModel> categories;
  final String? selectedCategoryId;
  final String sortBy;
  final String filterBy;
  final String searchQuery;
  final bool isGridView;
  final Set<String> favoriteIds;

  const MealsLoaded({
    required this.allMeals,
    required this.displayedMeals,
    required this.categories,
    this.selectedCategoryId,
    this.sortBy = 'popular',
    this.filterBy = 'all',
    this.searchQuery = '',
    this.isGridView = false,
    this.favoriteIds = const {},
  });

  MealsLoaded copyWith({
    List<MealEntity>? allMeals,
    List<MealEntity>? displayedMeals,
    List<MealCategoryModel>? categories,
    String? selectedCategoryId,
    bool clearCategory = false,
    String? sortBy,
    String? filterBy,
    String? searchQuery,
    bool? isGridView,
    Set<String>? favoriteIds,
  }) {
    return MealsLoaded(
      allMeals: allMeals ?? this.allMeals,
      displayedMeals: displayedMeals ?? this.displayedMeals,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      sortBy: sortBy ?? this.sortBy,
      filterBy: filterBy ?? this.filterBy,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }

  @override
  List<Object?> get props => [
        displayedMeals,
        categories,
        selectedCategoryId,
        sortBy,
        filterBy,
        searchQuery,
        isGridView,
        favoriteIds,
      ];
}

class MealsError extends MealsState {
  final String message;
  const MealsError(this.message);
  @override
  List<Object?> get props => [message];
}
