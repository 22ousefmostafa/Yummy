import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetRecentRatingsUseCase {
  final HomeRepository repository;

  GetRecentRatingsUseCase(this.repository);

  Future<Either<Failure, List<RecentRatingEntity>>> call() =>
      repository.getRecentRatings();
}
