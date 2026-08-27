import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_option.dart';

class SubmitSuggestionParams {
  final String type;
  final String content;
  final String priority;
  final String? mealId;

  const SubmitSuggestionParams({
    required this.type,
    required this.content,
    required this.priority,
    this.mealId,
  });
}

abstract class SuggestRepository {
  Future<Either<Failure, List<MealOption>>> getMeals();
  Future<Either<Failure, Unit>> submitSuggestion(SubmitSuggestionParams params);

  /// Emits whenever a suggestion is successfully submitted, so other
  /// screens (e.g. History) can refresh without a manual pull-to-refresh.
  Stream<void> get suggestionSubmitted;
}
