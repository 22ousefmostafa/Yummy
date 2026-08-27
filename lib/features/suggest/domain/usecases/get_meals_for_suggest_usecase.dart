import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_option.dart';
import '../repositories/suggest_repository.dart';

class GetMealsForSuggestUseCase {
  final SuggestRepository repository;

  const GetMealsForSuggestUseCase(this.repository);

  Future<Either<Failure, List<MealOption>>> call() => repository.getMeals();
}
