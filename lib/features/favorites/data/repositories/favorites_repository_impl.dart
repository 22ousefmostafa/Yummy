import 'package:dartz/dartz.dart';
import '../../../../core/cache/cache_aside.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_source.dart';
import '../models/favorites_response_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteSource remoteSource;
  final HiveCacheService cache;
  final NetworkInfo networkInfo;

  FavoritesRepositoryImpl(
    this.remoteSource, {
    required this.cache,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    final result = await fetchListWithCache<FavoriteModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'favorites_list',
      fetchRemote: remoteSource.getFavorites,
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: FavoriteModel.fromCacheMap,
    );
    return result.asEntities<FavoriteEntity>();
  }
}
