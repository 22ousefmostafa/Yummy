import '../../domain/entities/meal_entity.dart';

class MealCategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final int sortOrder;

  const MealCategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.sortOrder,
  });

  factory MealCategoryModel.fromMap(Map<String, dynamic> map) {
    return MealCategoryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      icon: map['icon'] as String? ?? '🍽️',
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}

class MealModel extends MealEntity {
  const MealModel({
    required super.id,
    required super.name,
    required super.nameAr,
    super.description,
    super.imageUrl,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.avgOverall,
    required super.totalRatings,
    required super.totalComments,
    required super.isPopular,
    super.isFavorite,
  });

  factory MealModel.fromMap(Map<String, dynamic> map) {
    final cat = map['categories'] as Map<String, dynamic>? ?? {};
    final ratings = map['ratings'] as List? ?? [];
    final withComment = ratings.where((r) {
      final c = (r as Map?)?['comment'];
      return c != null && (c as String).trim().isNotEmpty;
    }).length;

    return MealModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      categoryId: cat['id'] as String? ?? '',
      categoryName: cat['name'] as String? ?? '',
      categoryIcon: cat['icon'] as String? ?? '🍽️',
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      totalComments: withComment,
      isPopular: map['is_featured'] as bool? ?? false,
    );
  }

  // Flat shape (no nested Supabase joins) so it round-trips through Hive's
  // untyped box without relying on nested-map runtime casts.
  Map<String, dynamic> toCacheMap() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'description': description,
        'image_url': imageUrl,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_icon': categoryIcon,
        'avg_overall': avgOverall,
        'total_ratings': totalRatings,
        'total_comments': totalComments,
        'is_popular': isPopular,
      };

  factory MealModel.fromCacheMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      categoryId: map['category_id'] as String? ?? '',
      categoryName: map['category_name'] as String? ?? '',
      categoryIcon: map['category_icon'] as String? ?? '🍽️',
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      totalComments: map['total_comments'] as int? ?? 0,
      isPopular: map['is_popular'] as bool? ?? false,
    );
  }
}

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.reviewerName,
    required super.tasteScore,
    required super.presentationScore,
    required super.portionScore,
    required super.valueScore,
    required super.overallScore,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] as Map<String, dynamic>?;
    return ReviewModel(
      id: map['id'] as String? ?? '',
      reviewerName: profile?['full_name'] as String? ?? 'Anonymous',
      tasteScore: map['taste_score'] as int? ?? 0,
      presentationScore: map['presentation_score'] as int? ?? 0,
      portionScore: map['portion_score'] as int? ?? 0,
      valueScore: map['value_score'] as int? ?? 0,
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class MealDetailModel extends MealDetailEntity {
  const MealDetailModel({
    required super.id,
    required super.name,
    required super.nameAr,
    super.description,
    super.imageUrl,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.avgOverall,
    required super.totalRatings,
    required super.totalComments,
    required super.isPopular,
    super.isFavorite,
    required super.avgTaste,
    required super.avgPresentation,
    required super.avgPortion,
    required super.avgValue,
    required super.recentReviews,
  });

  factory MealDetailModel.fromMap(Map<String, dynamic> map) {
    final cat = map['categories'] as Map<String, dynamic>? ?? {};
    final ratingsRaw = map['ratings'] as List? ?? [];
    final ratings = ratingsRaw
        .map((e) => ReviewModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    double avg(double Function(ReviewModel) f) {
      if (ratings.isEmpty) return 0;
      return ratings.fold<double>(0, (s, r) => s + f(r)) / ratings.length;
    }

    final withComment =
        ratings.where((r) => r.comment != null && r.comment!.trim().isNotEmpty).length;

    return MealDetailModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameAr: map['name_ar'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      categoryId: cat['id'] as String? ?? '',
      categoryName: cat['name'] as String? ?? '',
      categoryIcon: cat['icon'] as String? ?? '🍽️',
      avgOverall: (map['avg_overall'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] as int? ?? 0,
      totalComments: withComment,
      isPopular: map['is_featured'] as bool? ?? false,
      avgTaste: avg((r) => r.tasteScore.toDouble()),
      avgPresentation: avg((r) => r.presentationScore.toDouble()),
      avgPortion: avg((r) => r.portionScore.toDouble()),
      avgValue: avg((r) => r.valueScore.toDouble()),
      recentReviews: ratings.take(10).toList(),
    );
  }
}
