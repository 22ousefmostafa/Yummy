import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedMealsUseCase {
  final HomeRepository repository;

  GetFeaturedMealsUseCase(this.repository);

  Future<Either<Failure, List<MealEntity>>> call() =>
      repository.getFeaturedMeals();
}
