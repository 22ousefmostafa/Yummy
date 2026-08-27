import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/cache/cache_aside.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/meals_repository.dart';
import '../datasources/meals_remote_source.dart';
import '../models/meal_model.dart';

class MealsRepositoryImpl implements MealsRepository {
  final MealsRemoteSource remoteSource;
  final HiveCacheService cache;
  final NetworkInfo networkInfo;
  final _favoriteController =
      StreamController<({String mealId, bool isNowFavorite})>.broadcast();

  MealsRepositoryImpl(
    this.remoteSource, {
    required this.cache,
    required this.networkInfo,
  });

  @override
  Stream<({String mealId, bool isNowFavorite})> get favoriteChanges =>
      _favoriteController.stream;

  @override
  Future<Either<Failure, List<MealEntity>>> getMeals({
    String? categoryId,
    String sortBy = 'popular',
    String filterBy = 'all',
  }) async {
    final result = await fetchListWithCache<MealModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'meals_list_${categoryId ?? 'all'}_${sortBy}_$filterBy',
      fetchRemote: () => remoteSource.getMeals(
        categoryId: categoryId,
        sortBy: sortBy,
        filterBy: filterBy,
      ),
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: MealModel.fromCacheMap,
    );
    return result.asEntities<MealEntity>();
  }

  @override
  Future<Either<Failure, MealDetailEntity>> getMealDetails(String mealId) async {
    try {
      final detail = await remoteSource.getMealDetails(mealId);
      return Right(detail);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealCategoryModel>>> getCategories() async {
    try {
      final categories = await remoteSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitRating(SubmitRatingParams params) async {
    try {
      await remoteSource.submitRating(params);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String mealId) async {
    try {
      final isNowFav = await remoteSource.toggleFavorite(mealId);
      _favoriteController.add((mealId: mealId, isNowFavorite: isNowFav));
      return Right(isNowFav);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getFavoriteIds() async {
    try {
      final ids = await remoteSource.getFavoriteIds();
      return Right(ids);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
