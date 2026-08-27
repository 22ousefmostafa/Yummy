import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  const FavoriteModel({
    required super.mealId,
    required super.mealName,
    required super.mealNameAr,
    super.mealImageUrl,
    required super.avgOverall,
    required super.totalRatings,
    required super.categoryName,
    required super.categoryIcon,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    final meal = Map<String, dynamic>.from(map['meals'] as Map);
    final category = Map<String, dynamic>.from(meal['categories'] as Map);
    return FavoriteModel(
      mealId: map['meal_id'] as String,
      mealName: meal['name'] as String,
      mealNameAr: (meal['name_ar'] as String?) ?? '',
      mealImageUrl: meal['image_url'] as String?,
      avgOverall: (meal['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (meal['total_ratings'] as int?) ?? 0,
      categoryName: category['name'] as String,
      categoryIcon: (category['icon'] as String?) ?? '🍽️',
    );
  }

  Map<String, dynamic> toCacheMap() => {
        'meal_id': mealId,
        'meal_name': mealName,
        'meal_name_ar': mealNameAr,
        'meal_image_url': mealImageUrl,
        'avg_overall': avgOverall,
        'total_ratings': totalRatings,
        'category_name': categoryName,
        'category_icon': categoryIcon,
      };

  factory FavoriteModel.fromCacheMap(Map<String, dynamic> map) {
    return FavoriteModel(
      mealId: map['meal_id'] as String? ?? '',
      mealName: map['meal_name'] as String? ?? '',
      mealNameAr: map['meal_name_ar'] as String? ?? '',
      mealImageUrl: map['meal_image_url'] as String?,
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      categoryName: map['category_name'] as String? ?? '',
      categoryIcon: map['category_icon'] as String? ?? '🍽️',
    );
  }
}
