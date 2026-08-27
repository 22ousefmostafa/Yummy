import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_entity.dart';

abstract class MealDetailsEvent extends Equatable {
  const MealDetailsEvent();
  @override
  List<Object?> get props => [];
}

class MealDetailsLoadRequested extends MealDetailsEvent {
  final String mealId;
  const MealDetailsLoadRequested(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class MealDetailsRatingSubmitted extends MealDetailsEvent {
  final SubmitRatingParams params;
  const MealDetailsRatingSubmitted(this.params);
  @override
  List<Object?> get props => [params];
}

class MealDetailsFavoriteToggled extends MealDetailsEvent {
  const MealDetailsFavoriteToggled();
}

class MealDetailsFavoriteExternallyChanged extends MealDetailsEvent {
  final String mealId;
  final bool isNowFavorite;
  const MealDetailsFavoriteExternallyChanged(this.mealId, this.isNowFavorite);
  @override
  List<Object?> get props => [mealId, isNowFavorite];
}
