import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateAvatarUseCase {
  final ProfileRepository repository;

  const UpdateAvatarUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(
    Uint8List bytes,
    String fileExtension,
  ) =>
      repository.updateAvatar(bytes, fileExtension);
}
