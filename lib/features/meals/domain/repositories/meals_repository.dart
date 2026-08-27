import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meal_entity.dart';
import '../../data/models/meal_model.dart';

abstract class MealsRepository {
  Future<Either<Failure, List<MealEntity>>> getMeals({
    String? categoryId,
    String sortBy,
    String filterBy,
  });
  Future<Either<Failure, MealDetailEntity>> getMealDetails(String mealId);
  Future<Either<Failure, List<MealCategoryModel>>> getCategories();
  Future<Either<Failure, Unit>> submitRating(SubmitRatingParams params);
  Future<Either<Failure, bool>> toggleFavorite(String mealId);
  Future<Either<Failure, Set<String>>> getFavoriteIds();
  Stream<({String mealId, bool isNowFavorite})> get favoriteChanges;
}
