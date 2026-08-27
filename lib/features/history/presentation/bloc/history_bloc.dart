import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../suggest/domain/repositories/suggest_repository.dart';
import '../../domain/usecases/delete_rating_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final DeleteRatingUseCase deleteRatingUseCase;
  final SuggestRepository suggestRepository;
  late final StreamSubscription<void> _suggestionSub;

  HistoryBloc({
    required this.getHistoryUseCase,
    required this.deleteRatingUseCase,
    required this.suggestRepository,
  }) : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryTabChanged>(_onTabChanged);
    on<HistoryRatingDeleteRequested>(_onDeleteRating);
    on<HistorySuggestionsExternallyRefreshed>(_onSuggestionsExternallyRefreshed);

    _suggestionSub = suggestRepository.suggestionSubmitted.listen((_) {
      add(const HistorySuggestionsExternallyRefreshed());
    });
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    final result = await getHistoryUseCase();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (data) => emit(HistoryLoaded(
        ratings: data.ratings,
        suggestions: data.suggestions,
      )),
    );
  }

  void _onTabChanged(HistoryTabChanged event, Emitter<HistoryState> emit) {
    if (state is HistoryLoaded) {
      emit((state as HistoryLoaded).copyWith(activeTab: event.tab));
    }
  }

  Future<void> _onDeleteRating(
    HistoryRatingDeleteRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) return;
    final current = state as HistoryLoaded;

    final result = await deleteRatingUseCase(event.ratingId);
    result.fold(
      (failure) => emit(current.copyWith(deleteError: failure.message)),
      (_) {
        final updated =
            current.ratings.where((r) => r.id != event.ratingId).toList();
        emit(current.copyWith(ratings: updated, clearDeleteError: true));
      },
    );
  }

  Future<void> _onSuggestionsExternallyRefreshed(
    HistorySuggestionsExternallyRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    // Refetch silently (no loading spinner) so a suggestion submitted from
    // the Suggest tab shows up immediately if History is already loaded.
    final result = await getHistoryUseCase();
    result.fold(
      (_) {},
      (data) {
        if (state is HistoryLoaded) {
          emit((state as HistoryLoaded).copyWith(
            ratings: data.ratings,
            suggestions: data.suggestions,
          ));
        } else {
          emit(HistoryLoaded(ratings: data.ratings, suggestions: data.suggestions));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _suggestionSub.cancel();
    return super.close();
  }
}
