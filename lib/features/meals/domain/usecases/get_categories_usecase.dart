import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/meals_repository.dart';
import '../../data/models/meal_model.dart';

class GetMealCategoriesUseCase {
  final MealsRepository repository;
  GetMealCategoriesUseCase(this.repository);

  Future<Either<Failure, List<MealCategoryModel>>> call() {
    return repository.getCategories();
  }
}
