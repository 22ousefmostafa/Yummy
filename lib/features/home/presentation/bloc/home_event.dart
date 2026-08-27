import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class HomeFavoriteToggled extends HomeEvent {
  final String mealId;
  const HomeFavoriteToggled(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class HomeFavoriteExternallyChanged extends HomeEvent {
  final String mealId;
  final bool isNowFavorite;
  const HomeFavoriteExternallyChanged(this.mealId, this.isNowFavorite);
  @override
  List<Object?> get props => [mealId, isNowFavorite];
}
