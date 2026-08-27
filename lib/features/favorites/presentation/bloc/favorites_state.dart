import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_entity.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteEntity> favorites;
  final String? removeError;

  const FavoritesLoaded({required this.favorites, this.removeError});

  FavoritesLoaded copyWith({
    List<FavoriteEntity>? favorites,
    String? removeError,
    bool clearError = false,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      removeError: clearError ? null : removeError ?? this.removeError,
    );
  }

  @override
  List<Object?> get props => [favorites, removeError];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError(this.message);
  @override
  List<Object?> get props => [message];
}
