import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAsReadUseCase {
  final NotificationsRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String notificationId) =>
      repository.markAsRead(notificationId);
}
