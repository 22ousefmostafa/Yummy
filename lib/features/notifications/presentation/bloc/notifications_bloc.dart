import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
  }) : super(const NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoadRequested);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onLoadRequested(
    NotificationsLoadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(failure.message)),
      (notifications) =>
          emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final current = state as NotificationsLoaded;

    final alreadyRead = current.notifications
        .any((n) => n.id == event.notificationId && n.isRead);
    if (alreadyRead) return;

    final updated = current.notifications
        .map((n) =>
            n.id == event.notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    emit(current.copyWith(notifications: updated));

    final result = await markAsReadUseCase(event.notificationId);
    result.fold(
      (failure) => emit(current.copyWith(actionError: failure.message)),
      (_) {},
    );
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;
    final current = state as NotificationsLoaded;
    if (current.unreadCount == 0) return;

    final updated =
        current.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(current.copyWith(notifications: updated));

    final result = await markAllAsReadUseCase();
    result.fold(
      (failure) => emit(current.copyWith(actionError: failure.message)),
      (_) {},
    );
  }
}
