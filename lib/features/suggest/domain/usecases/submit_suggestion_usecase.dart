import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/suggest_repository.dart';

class SubmitSuggestionUseCase {
  final SuggestRepository repository;

  const SubmitSuggestionUseCase(this.repository);

  Future<Either<Failure, Unit>> call(SubmitSuggestionParams params) =>
      repository.submitSuggestion(params);
}
