import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_meal_details_usecase.dart';
import '../../domain/repositories/meals_repository.dart';
import 'meal_details_event.dart';
import 'meal_details_state.dart';

class MealDetailsBloc extends Bloc<MealDetailsEvent, MealDetailsState> {
  final GetMealDetailsUseCase getMealDetailsUseCase;
  final MealsRepository repository;
  late final StreamSubscription<({String mealId, bool isNowFavorite})> _favSub;

  MealDetailsBloc({
    required this.getMealDetailsUseCase,
    required this.repository,
  }) : super(const MealDetailsInitial()) {
    on<MealDetailsLoadRequested>(_onLoad);
    on<MealDetailsRatingSubmitted>(_onSubmit);
    on<MealDetailsFavoriteToggled>(_onFavoriteToggled);
    on<MealDetailsFavoriteExternallyChanged>(_onFavoriteExternallyChanged);

    _favSub = repository.favoriteChanges.listen((change) {
      add(MealDetailsFavoriteExternallyChanged(
          change.mealId, change.isNowFavorite));
    });
  }

  Future<void> _onLoad(
      MealDetailsLoadRequested event, Emitter<MealDetailsState> emit) async {
    emit(const MealDetailsLoading());

    final result = await getMealDetailsUseCase(event.mealId);
    if (result.isLeft()) {
      result.fold((f) => emit(MealDetailsError(f.message)), (_) {});
      return;
    }

    final meal = result.getOrElse(() => throw Exception());
    final favResult = await repository.getFavoriteIds();
    final favoriteIds = favResult.fold((_) => <String>{}, (ids) => ids);

    emit(MealDetailsLoaded(
      meal: meal,
      isFavorite: favoriteIds.contains(meal.id),
    ));
  }

  Future<void> _onSubmit(
      MealDetailsRatingSubmitted event, Emitter<MealDetailsState> emit) async {
    if (state is! MealDetailsLoaded) return;
    final current = state as MealDetailsLoaded;
    emit(current.copyWith(isSubmitting: true, clearError: true));

    final result = await repository.submitRating(event.params);
    if (result.isLeft()) {
      result.fold(
        (f) => emit(current.copyWith(isSubmitting: false, submitError: f.message)),
        (_) {},
      );
      return;
    }

    emit(current.copyWith(isSubmitting: false, submitSuccess: true));
    final reloaded = await getMealDetailsUseCase(event.params.mealId);
    reloaded.fold(
      (_) {},
      (meal) => emit(MealDetailsLoaded(
        meal: meal,
        isFavorite: current.isFavorite,
        submitSuccess: true,
      )),
    );
  }

  Future<void> _onFavoriteToggled(
      MealDetailsFavoriteToggled event, Emitter<MealDetailsState> emit) async {
    if (state is! MealDetailsLoaded) return;
    // toggleFavorite broadcasts on stream → _onFavoriteExternallyChanged updates state
    await repository.toggleFavorite((state as MealDetailsLoaded).meal.id);
  }

  void _onFavoriteExternallyChanged(
      MealDetailsFavoriteExternallyChanged event,
      Emitter<MealDetailsState> emit) {
    if (state is! MealDetailsLoaded) return;
    final current = state as MealDetailsLoaded;
    if (current.meal.id == event.mealId) {
      emit(current.copyWith(isFavorite: event.isNowFavorite));
    }
  }

  @override
  Future<void> close() {
    _favSub.cancel();
    return super.close();
  }
}
