import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      type: map['type'] as String? ?? 'general',
      title: map['title'] as String? ?? '',
      message: map['body'] as String? ?? '',
      isRead: map['is_read'] as bool? ?? false,
      createdAt: _parseUtc(map['created_at'] as String),
    );
  }

  /// The `notifications.created_at` column is `timestamp without time
  /// zone`, so PostgREST serializes it with no offset/'Z' suffix even
  /// though the value is stored in UTC. Without this, [DateTime.parse]
  /// would silently misinterpret it as local time.
  static DateTime _parseUtc(String value) {
    final hasOffset = value.endsWith('Z') || RegExp(r'[+-]\d\d:?\d\d$').hasMatch(value);
    return DateTime.parse(hasOffset ? value : '${value}Z');
  }
}
