import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<MealEntity>>> getPopularMeals({int limit = 4});
  Future<Either<Failure, List<MealEntity>>> getFeaturedMeals({int limit = 3});
  Future<Either<Failure, List<RecentRatingEntity>>> getRecentRatings({int limit = 5});
}
