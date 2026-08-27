import 'package:equatable/equatable.dart';
import '../../domain/entities/history_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<RatingHistoryEntity> ratings;
  final List<SuggestionHistoryEntity> suggestions;
  final int activeTab;
  final String? deleteError;

  const HistoryLoaded({
    required this.ratings,
    required this.suggestions,
    this.activeTab = 0,
    this.deleteError,
  });

  HistoryLoaded copyWith({
    List<RatingHistoryEntity>? ratings,
    List<SuggestionHistoryEntity>? suggestions,
    int? activeTab,
    String? deleteError,
    bool clearDeleteError = false,
  }) {
    return HistoryLoaded(
      ratings: ratings ?? this.ratings,
      suggestions: suggestions ?? this.suggestions,
      activeTab: activeTab ?? this.activeTab,
      deleteError: clearDeleteError ? null : (deleteError ?? this.deleteError),
    );
  }

  @override
  List<Object?> get props => [ratings, suggestions, activeTab, deleteError];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
