import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/history_repository.dart';

class DeleteRatingUseCase {
  final HistoryRepository repository;

  DeleteRatingUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String ratingId) =>
      repository.deleteRating(ratingId);
}
