import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

class UpdateProfileParams {
  final String fullName;
  final String? phone;

  const UpdateProfileParams({required this.fullName, this.phone});
}

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile(UpdateProfileParams params);
  Future<Either<Failure, ProfileEntity>> updateAvatar(
    Uint8List bytes,
    String fileExtension,
  );
}
