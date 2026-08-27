import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import 'hive_cache_service.dart';

/// Shared cache-aside strategy used by every repository that backs an
/// offline-capable screen:
///  - online  -> fetch from remote, persist to Hive, return it
///  - online but remote call throws -> fall back to a fresh cache entry
///  - offline -> serve from Hive if the entry is still fresh (< 24h)
///  - offline with no usable cache -> [CacheFailure]
Future<Either<Failure, List<T>>> fetchListWithCache<T>({
  required NetworkInfo networkInfo,
  required HiveCacheService cache,
  required String cacheKey,
  required Future<List<T>> Function() fetchRemote,
  required Map<String, dynamic> Function(T item) toCacheMap,
  required T Function(Map<String, dynamic> map) fromCacheMap,
}) async {
  Right<Failure, List<T>>? readCache() {
    final raw = cache.read(cacheKey);
    if (raw == null) return null;
    final items = (raw as List)
        .map((e) => fromCacheMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return Right(items);
  }

  final isOnline = await networkInfo.isConnected;

  if (isOnline) {
    try {
      final remote = await fetchRemote();
      await cache.save(cacheKey, remote.map(toCacheMap).toList());
      return Right(remote);
    } catch (e) {
      final cached = readCache();
      if (cached != null) return cached;
      return Left(ServerFailure(e.toString()));
    }
  }

  final cached = readCache();
  if (cached != null) return cached;
  return const Left(
    CacheFailure("You're offline and no saved data is available yet."),
  );
}

/// dartz's [Either] keeps the concrete generic type it was constructed
/// with at runtime — a `List<CategoryModel>` Right does NOT become a
/// `List<CategoryEntity>` Right just because it's returned from a function
/// declared to return the latter. Callers that invoke type-parameter-aware
/// methods (e.g. `getOrElse(() => <CategoryEntity>[])`) then hit a runtime
/// TypeError instead of the widened static type. Repositories must call
/// this right before returning a [fetchListWithCache] result through an
/// entity-typed interface, so the Right value is freshly reified as
/// `List<E>`.
extension ReifyAsEntities<M> on Either<Failure, List<M>> {
  Either<Failure, List<E>> asEntities<E>() {
    return fold<Either<Failure, List<E>>>(
      (failure) => Left<Failure, List<E>>(failure),
      (models) => Right<Failure, List<E>>(List<E>.from(models)),
    );
  }
}
