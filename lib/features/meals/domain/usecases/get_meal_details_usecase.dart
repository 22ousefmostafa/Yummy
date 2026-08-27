import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_entity.dart';
import '../repositories/meals_repository.dart';

class GetMealDetailsUseCase {
  final MealsRepository repository;
  GetMealDetailsUseCase(this.repository);

  Future<Either<Failure, MealDetailEntity>> call(String mealId) {
    return repository.getMealDetails(mealId);
  }
}
