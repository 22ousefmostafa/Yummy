import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_source.dart';
import '../models/update_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteSource remoteSource;

  ProfileRepositoryImpl(this.remoteSource);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final model = await remoteSource.getProfile();
      return Right(model);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
      UpdateProfileParams params) async {
    try {
      final model = await remoteSource.updateProfile(
        UpdateProfileModel(fullName: params.fullName, phone: params.phone),
      );
      return Right(model);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateAvatar(
    Uint8List bytes,
    String fileExtension,
  ) async {
    try {
      final model = await remoteSource.updateAvatar(bytes, fileExtension);
      return Right(model);
    } on StorageException catch (e) {
      return Left(ServerFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
