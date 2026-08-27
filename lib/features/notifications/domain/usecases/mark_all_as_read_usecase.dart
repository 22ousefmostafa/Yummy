import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notifications_repository.dart';

class MarkAllAsReadUseCase {
  final NotificationsRepository repository;

  MarkAllAsReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call() => repository.markAllAsRead();
}
