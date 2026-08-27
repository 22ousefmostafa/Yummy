import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/meal_option.dart';
import '../../domain/repositories/suggest_repository.dart';
import '../datasources/suggest_remote_source.dart';

class SuggestRepositoryImpl implements SuggestRepository {
  final SuggestRemoteSource remoteSource;
  final _submittedController = StreamController<void>.broadcast();

  SuggestRepositoryImpl(this.remoteSource);

  @override
  Stream<void> get suggestionSubmitted => _submittedController.stream;

  @override
  Future<Either<Failure, List<MealOption>>> getMeals() async {
    try {
      final data = await remoteSource.getMeals();
      final meals = data
          .map((m) => MealOption(
                id: m['id'] as String,
                name: m['name'] as String,
              ))
          .toList();
      return Right(meals);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitSuggestion(
      SubmitSuggestionParams params) async {
    try {
      await remoteSource.submitSuggestion(params);
      _submittedController.add(null);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
