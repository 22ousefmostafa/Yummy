import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../meals/domain/repositories/meals_repository.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final MealsRepository mealsRepository;
  late final StreamSubscription<({String mealId, bool isNowFavorite})> _favSub;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.mealsRepository,
  }) : super(const FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoad);
    on<FavoriteRemoveRequested>(_onRemove);
    on<FavoriteExternallyChanged>(_onExternalChange);

    _favSub = mealsRepository.favoriteChanges.listen((change) {
      add(FavoriteExternallyChanged(change.mealId, change.isNowFavorite));
    });
  }

  Future<void> _onLoad(
      FavoritesLoadRequested event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesLoading());
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) => emit(FavoritesLoaded(favorites: favorites)),
    );
  }

  Future<void> _onRemove(
      FavoriteRemoveRequested event, Emitter<FavoritesState> emit) async {
    if (state is! FavoritesLoaded) return;
    // toggleFavorite broadcasts on stream → _onExternalChange handles state update
    final result = await mealsRepository.toggleFavorite(event.mealId);
    result.fold(
      (failure) {
        final current = state as FavoritesLoaded;
        emit(current.copyWith(removeError: failure.message));
      },
      (_) {},
    );
  }

  void _onExternalChange(
      FavoriteExternallyChanged event, Emitter<FavoritesState> emit) {
    if (state is! FavoritesLoaded) return;
    final current = state as FavoritesLoaded;
    if (!event.isNowFavorite) {
      final updated =
          current.favorites.where((f) => f.mealId != event.mealId).toList();
      emit(current.copyWith(favorites: updated, clearError: true));
    }
  }

  @override
  Future<void> close() {
    _favSub.cancel();
    return super.close();
  }
}
