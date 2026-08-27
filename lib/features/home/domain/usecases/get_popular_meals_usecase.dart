import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetPopularMealsUseCase {
  final HomeRepository repository;

  GetPopularMealsUseCase(this.repository);

  Future<Either<Failure, List<MealEntity>>> call() =>
      repository.getPopularMeals();
}
