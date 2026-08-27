import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final String? actionError;

  const NotificationsLoaded({
    required this.notifications,
    this.actionError,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    String? actionError,
    bool clearActionError = false,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [notifications, actionError];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
