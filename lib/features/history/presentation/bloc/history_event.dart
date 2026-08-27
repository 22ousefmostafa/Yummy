import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

class HistoryTabChanged extends HistoryEvent {
  final int tab;

  const HistoryTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class HistoryRatingDeleteRequested extends HistoryEvent {
  final String ratingId;

  const HistoryRatingDeleteRequested(this.ratingId);

  @override
  List<Object?> get props => [ratingId];
}

/// Fired when a suggestion is submitted from the Suggest tab while History
/// is already loaded, so the Suggestions list stays in sync without a
/// manual refresh.
class HistorySuggestionsExternallyRefreshed extends HistoryEvent {
  const HistorySuggestionsExternallyRefreshed();
}
