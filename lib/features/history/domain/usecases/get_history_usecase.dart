import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

typedef HistoryResult = ({
  List<RatingHistoryEntity> ratings,
  List<SuggestionHistoryEntity> suggestions,
});

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<Failure, HistoryResult>> call() async {
    final ratingsResult = await repository.getRatingHistory();
    if (ratingsResult.isLeft()) {
      return Left(ratingsResult.fold((l) => l, (_) => const UnknownFailure('')));
    }

    final suggestionsResult = await repository.getSuggestionHistory();
    if (suggestionsResult.isLeft()) {
      return Left(
        suggestionsResult.fold((l) => l, (_) => const UnknownFailure('')),
      );
    }

    return Right((
      ratings: ratingsResult.getOrElse(() => []),
      suggestions: suggestionsResult.getOrElse(() => []),
    ));
  }
}
