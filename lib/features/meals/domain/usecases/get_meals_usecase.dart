import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_entity.dart';
import '../repositories/meals_repository.dart';

class GetMealsUseCase {
  final MealsRepository repository;
  GetMealsUseCase(this.repository);

  Future<Either<Failure, List<MealEntity>>> call({
    String? categoryId,
    String sortBy = 'popular',
    String filterBy = 'all',
  }) {
    return repository.getMeals(
      categoryId: categoryId,
      sortBy: sortBy,
      filterBy: filterBy,
    );
  }
}
