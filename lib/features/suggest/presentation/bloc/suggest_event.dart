import 'package:equatable/equatable.dart';

abstract class SuggestEvent extends Equatable {
  const SuggestEvent();

  @override
  List<Object?> get props => [];
}

class SuggestLoadRequested extends SuggestEvent {
  const SuggestLoadRequested();
}

class SuggestTypeSelected extends SuggestEvent {
  final String type;

  const SuggestTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class SuggestMealSelected extends SuggestEvent {
  final String id;
  final String name;

  const SuggestMealSelected({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class SuggestMealCleared extends SuggestEvent {
  const SuggestMealCleared();
}

class SuggestPriorityChanged extends SuggestEvent {
  final String priority;

  const SuggestPriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class SuggestSubmitRequested extends SuggestEvent {
  final String content;

  const SuggestSubmitRequested({required this.content});

  @override
  List<Object?> get props => [content];
}

class SuggestReset extends SuggestEvent {
  const SuggestReset();
}
