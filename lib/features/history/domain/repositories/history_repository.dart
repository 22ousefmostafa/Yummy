import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_entity.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<RatingHistoryEntity>>> getRatingHistory();
  Future<Either<Failure, List<SuggestionHistoryEntity>>> getSuggestionHistory();
  Future<Either<Failure, Unit>> deleteRating(String ratingId);
}
