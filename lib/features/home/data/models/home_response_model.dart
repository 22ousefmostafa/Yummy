import '../../domain/entities/home_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.icon,
    required super.sortOrder,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      icon: map['icon'] as String? ?? '🍽️',
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'icon': icon,
        'sort_order': sortOrder,
      };

  factory CategoryModel.fromCacheMap(Map<String, dynamic> map) =>
      CategoryModel.fromMap(map);
}

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.name,
    required super.nameAr,
    super.imageUrl,
    required super.categoryIcon,
    required super.avgOverall,
    required super.totalRatings,
    super.isFeatured,
    super.isFavorite,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    final categories = map['categories'] as Map<String, dynamic>?;
    return MealModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      categoryIcon: categories?['icon'] as String? ?? '🍽️',
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }

  // Flat shape (no nested Supabase joins) so it round-trips through Hive's
  // untyped box without relying on nested-map runtime casts.
  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'image_url': imageUrl,
        'avg_overall': avgOverall,
        'total_ratings': totalRatings,
        'is_featured': isFeatured,
        'category_icon': categoryIcon,
      };

  factory MealModel.fromCacheMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      categoryIcon: map['category_icon'] as String? ?? '🍽️',
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      isFeatured: map['is_featured'] as bool? ?? false,
    );
  }
}

class RecentRatingModel extends RecentRatingEntity {
  const RecentRatingModel({
    required super.id,
    required super.mealId,
    required super.mealName,
    super.mealImageUrl,
    required super.mealIcon,
    required super.rating,
    required super.timeAgo,
  });

  factory RecentRatingModel.fromMap(Map<String, dynamic> map) {
    final meal = map['meals'] as Map<String, dynamic>?;
    final categories = meal?['categories'] as Map<String, dynamic>?;
    final createdAt =
        DateTime.tryParse(map['created_at'] as String? ?? '') ??
            DateTime.now();

    return RecentRatingModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String? ?? '',
      mealName: meal?['name'] as String? ?? '',
      mealImageUrl: meal?['image_url'] as String?,
      mealIcon: categories?['icon'] as String? ?? '🍽️',
      rating: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      timeAgo: _timeAgo(createdAt),
    );
  }

  static String _timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    }
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'meal_id': mealId,
        'meal_name': mealName,
        'meal_image_url': mealImageUrl,
        'meal_icon': mealIcon,
        'rating': rating,
        'time_ago': timeAgo,
      };

  factory RecentRatingModel.fromCacheMap(Map<String, dynamic> map) {
    return RecentRatingModel(
      id: map['id'] as String? ?? '',
      mealId: map['meal_id'] as String? ?? '',
      mealName: map['meal_name'] as String? ?? '',
      mealImageUrl: map['meal_image_url'] as String?,
      mealIcon: map['meal_icon'] as String? ?? '🍽️',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      timeAgo: map['time_ago'] as String? ?? '',
    );
  }
}
