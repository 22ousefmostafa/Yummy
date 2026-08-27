import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/cache/cache_aside.dart';
import '../../../../core/cache/hive_cache_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_source.dart';
import '../models/history_response_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteSource remoteSource;
  final HiveCacheService cache;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl(
    this.remoteSource, {
    required this.cache,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RatingHistoryEntity>>> getRatingHistory() async {
    final result = await fetchListWithCache<RatingHistoryModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'history_ratings',
      fetchRemote: remoteSource.getRatingHistory,
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: RatingHistoryModel.fromCacheMap,
    );
    return result.asEntities<RatingHistoryEntity>();
  }

  @override
  Future<Either<Failure, List<SuggestionHistoryEntity>>>
      getSuggestionHistory() async {
    final result = await fetchListWithCache<SuggestionHistoryModel>(
      networkInfo: networkInfo,
      cache: cache,
      cacheKey: 'history_suggestions',
      fetchRemote: remoteSource.getSuggestionHistory,
      toCacheMap: (item) => item.toCacheMap(),
      fromCacheMap: SuggestionHistoryModel.fromCacheMap,
    );
    return result.asEntities<SuggestionHistoryEntity>();
  }

  @override
  Future<Either<Failure, Unit>> deleteRating(String ratingId) async {
    try {
      await remoteSource.deleteRating(ratingId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
