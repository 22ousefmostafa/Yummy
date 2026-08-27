import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/suggest_repository.dart';
import '../../domain/usecases/get_meals_for_suggest_usecase.dart';
import '../../domain/usecases/submit_suggestion_usecase.dart';
import 'suggest_event.dart';
import 'suggest_state.dart';

class SuggestBloc extends Bloc<SuggestEvent, SuggestState> {
  final GetMealsForSuggestUseCase getMealsUseCase;
  final SubmitSuggestionUseCase submitSuggestionUseCase;

  SuggestBloc({
    required this.getMealsUseCase,
    required this.submitSuggestionUseCase,
  }) : super(const SuggestInitial()) {
    on<SuggestLoadRequested>(_onLoadRequested);
    on<SuggestTypeSelected>(_onTypeSelected);
    on<SuggestMealSelected>(_onMealSelected);
    on<SuggestMealCleared>(_onMealCleared);
    on<SuggestPriorityChanged>(_onPriorityChanged);
    on<SuggestSubmitRequested>(_onSubmitRequested);
    on<SuggestReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    SuggestLoadRequested event,
    Emitter<SuggestState> emit,
  ) async {
    emit(const SuggestLoading());
    final result = await getMealsUseCase();
    result.fold(
      (failure) => emit(SuggestError(failure.message)),
      (meals) => emit(SuggestLoaded(meals: meals)),
    );
  }

  void _onTypeSelected(SuggestTypeSelected event, Emitter<SuggestState> emit) {
    if (state is! SuggestLoaded) return;
    emit((state as SuggestLoaded).copyWith(
      selectedType: event.type,
      clearError: true,
    ));
  }

  void _onMealSelected(SuggestMealSelected event, Emitter<SuggestState> emit) {
    if (state is! SuggestLoaded) return;
    emit((state as SuggestLoaded).copyWith(
      selectedMealId: event.id,
      selectedMealName: event.name,
    ));
  }

  void _onMealCleared(SuggestMealCleared event, Emitter<SuggestState> emit) {
    if (state is! SuggestLoaded) return;
    emit((state as SuggestLoaded).copyWith(clearMeal: true));
  }

  void _onPriorityChanged(
      SuggestPriorityChanged event, Emitter<SuggestState> emit) {
    if (state is! SuggestLoaded) return;
    emit((state as SuggestLoaded).copyWith(priority: event.priority));
  }

  Future<void> _onSubmitRequested(
    SuggestSubmitRequested event,
    Emitter<SuggestState> emit,
  ) async {
    if (state is! SuggestLoaded) return;
    final current = state as SuggestLoaded;

    if (current.selectedType == null) {
      emit(current.copyWith(
          submitError: 'Please select a suggestion type first'));
      return;
    }
    if (event.content.trim().isEmpty) {
      emit(current.copyWith(submitError: 'Please write your suggestion'));
      return;
    }
    if (event.content.trim().length > 500) {
      emit(current.copyWith(
          submitError: 'Suggestion must be 500 characters or less'));
      return;
    }

    emit(current.copyWith(isSubmitting: true, clearError: true));

    final result = await submitSuggestionUseCase(SubmitSuggestionParams(
      type: current.selectedType!,
      content: event.content.trim(),
      priority: current.priority,
      mealId: current.selectedMealId,
    ));

    result.fold(
      (failure) => emit(current.copyWith(
        isSubmitting: false,
        submitError: failure.message,
      )),
      (_) => emit(current.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        clearError: true,
      )),
    );
  }

  void _onReset(SuggestReset event, Emitter<SuggestState> emit) {
    if (state is SuggestLoaded) {
      emit(SuggestLoaded(meals: (state as SuggestLoaded).meals));
    }
  }
}
