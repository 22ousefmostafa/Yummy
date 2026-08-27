import 'package:equatable/equatable.dart';

abstract class MealsEvent extends Equatable {
  const MealsEvent();
  @override
  List<Object?> get props => [];
}

class MealsLoadRequested extends MealsEvent {
  final String? categoryId;
  const MealsLoadRequested({this.categoryId});
  @override
  List<Object?> get props => [categoryId];
}

class MealsSortChanged extends MealsEvent {
  final String sortBy;
  const MealsSortChanged(this.sortBy);
  @override
  List<Object?> get props => [sortBy];
}

class MealsFilterChanged extends MealsEvent {
  final String filterBy;
  const MealsFilterChanged(this.filterBy);
  @override
  List<Object?> get props => [filterBy];
}

class MealsCategoryChanged extends MealsEvent {
  final String? categoryId;
  const MealsCategoryChanged(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class MealsSearchChanged extends MealsEvent {
  final String query;
  const MealsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class MealsViewToggled extends MealsEvent {
  const MealsViewToggled();
}

class MealsFavoriteToggled extends MealsEvent {
  final String mealId;
  const MealsFavoriteToggled(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class MealsFavoriteExternallyChanged extends MealsEvent {
  final String mealId;
  final bool isNowFavorite;
  const MealsFavoriteExternallyChanged(this.mealId, this.isNowFavorite);
  @override
  List<Object?> get props => [mealId, isNowFavorite];
}
