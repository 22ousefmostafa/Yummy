import '../../domain/entities/history_entity.dart';

class RatingHistoryModel extends RatingHistoryEntity {
  const RatingHistoryModel({
    required super.id,
    required super.mealId,
    required super.mealName,
    super.mealImageUrl,
    required super.mealIcon,
    required super.tasteScore,
    required super.presentationScore,
    required super.portionScore,
    required super.valueScore,
    required super.overallScore,
    super.comment,
    required super.isEdited,
    required super.createdAt,
  });

  factory RatingHistoryModel.fromMap(Map<String, dynamic> map) {
    final meal = map['meals'] as Map<String, dynamic>?;
    final categories = meal?['categories'] as Map<String, dynamic>?;
    return RatingHistoryModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String? ?? '',
      mealName: meal?['name'] as String? ?? '',
      mealImageUrl: meal?['image_url'] as String?,
      mealIcon: categories?['icon'] as String? ?? '🍽️',
      tasteScore: map['taste_score'] as int? ?? 0,
      presentationScore: map['presentation_score'] as int? ?? 0,
      portionScore: map['portion_score'] as int? ?? 0,
      valueScore: map['value_score'] as int? ?? 0,
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String?,
      isEdited: false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'meal_id': mealId,
        'meal_name': mealName,
        'meal_image_url': mealImageUrl,
        'meal_icon': mealIcon,
        'taste_score': tasteScore,
        'presentation_score': presentationScore,
        'portion_score': portionScore,
        'value_score': valueScore,
        'overall_score': overallScore,
        'comment': comment,
        'is_edited': isEdited,
        'created_at': createdAt.toIso8601String(),
      };

  factory RatingHistoryModel.fromCacheMap(Map<String, dynamic> map) {
    return RatingHistoryModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String? ?? '',
      mealName: map['meal_name'] as String? ?? '',
      mealImageUrl: map['meal_image_url'] as String?,
      mealIcon: map['meal_icon'] as String? ?? '🍽️',
      tasteScore: map['taste_score'] as int? ?? 0,
      presentationScore: map['presentation_score'] as int? ?? 0,
      portionScore: map['portion_score'] as int? ?? 0,
      valueScore: map['value_score'] as int? ?? 0,
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String?,
      isEdited: map['is_edited'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SuggestionHistoryModel extends SuggestionHistoryEntity {
  const SuggestionHistoryModel({
    required super.id,
    super.mealId,
    super.mealName,
    required super.type,
    required super.content,
    required super.priority,
    required super.status,
    required super.createdAt,
  });

  factory SuggestionHistoryModel.fromMap(Map<String, dynamic> map) {
    final meal = map['meals'] as Map<String, dynamic>?;
    return SuggestionHistoryModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String?,
      mealName: meal?['name'] as String?,
      type: map['type'] as String? ?? 'other',
      content: map['content'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'meal_id': mealId,
        'meal_name': mealName,
        'type': type,
        'content': content,
        'priority': priority,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  factory SuggestionHistoryModel.fromCacheMap(Map<String, dynamic> map) {
    return SuggestionHistoryModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String?,
      mealName: map['meal_name'] as String?,
      type: map['type'] as String? ?? 'other',
      content: map['content'] as String? ?? '',
      priority: map['priority'] as String? ?? 'medium',
      status: map['status'] as String? ?? 'pending',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
