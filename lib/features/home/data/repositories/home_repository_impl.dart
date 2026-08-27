import 'package:dartz/dartz.dart';
import '../../../../core/cache/cache_aside.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_source.dart';
import '../models/home_response_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteSource remoteSource;
  final HiveCacheService cache;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl(
    this.remoteSource, {
    required this.cache,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    final result = await fetchListWithCache<CategoryModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'home_categories',
      fetchRemote: remoteSource.getCategories,
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: CategoryModel.fromCacheMap,
    );
    return result.asEntities<CategoryEntity>();
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getPopularMeals({
    int limit = 4,
  }) async {
    final result = await fetchListWithCache<MealModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'home_popular_meals',
      fetchRemote: () => remoteSource.getPopularMeals(limit: limit),
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: MealModel.fromCacheMap,
    );
    return result.asEntities<MealEntity>();
  }

  @override
  Future<Either<Failure, List<MealEntity>>> getFeaturedMeals({
    int limit = 3,
  }) async {
    final result = await fetchListWithCache<MealModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'home_featured_meals',
      fetchRemote: () => remoteSource.getFeaturedMeals(limit: limit),
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: MealModel.fromCacheMap,
    );
    return result.asEntities<MealEntity>();
  }

  @override
  Future<Either<Failure, List<RecentRatingEntity>>> getRecentRatings({
    int limit = 5,
  }) async {
    final result = await fetchListWithCache<RecentRatingModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'home_recent_ratings',
      fetchRemote: () => remoteSource.getRecentRatings(limit: limit),
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: RecentRatingModel.fromCacheMap,
    );
    return result.asEntities<RecentRatingEntity>();
  }
}
