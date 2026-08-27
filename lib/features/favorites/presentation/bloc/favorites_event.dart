import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

class FavoriteRemoveRequested extends FavoritesEvent {
  final String mealId;
  const FavoriteRemoveRequested(this.mealId);
  @override
  List<Object?> get props => [mealId];
}

class FavoriteExternallyChanged extends FavoritesEvent {
  final String mealId;
  final bool isNowFavorite;
  const FavoriteExternallyChanged(this.mealId, this.isNowFavorite);
  @override
  List<Object?> get props => [mealId, isNowFavorite];
}
