class CategoryEntity {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.sortOrder,
  });
}

class MealEntity {
  final String id;
  final String name;
  final String nameAr;
  final String? imageUrl;
  final String categoryIcon;
  final double avgOverall;
  final int totalRatings;
  final bool isFeatured;
  final bool isFavorite;

  const MealEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    this.imageUrl,
    required this.categoryIcon,
    required this.avgOverall,
    required this.totalRatings,
    this.isFeatured = false,
    this.isFavorite = false,
  });

  MealEntity copyWith({bool? isFavorite}) => MealEntity(
        id: id,
        name: name,
        nameAr: nameAr,
        imageUrl: imageUrl,
        categoryIcon: categoryIcon,
        avgOverall: avgOverall,
        totalRatings: totalRatings,
        isFeatured: isFeatured,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

class RecentRatingEntity {
  final String id;
  final String mealId;
  final String mealName;
  final String? mealImageUrl;
  final String mealIcon;
  final double rating;
  final String timeAgo;

  const RecentRatingEntity({
    required this.id,
    required this.mealId,
    required this.mealName,
    this.mealImageUrl,
    required this.mealIcon,
    required this.rating,
    required this.timeAgo,
  });
}

class PromoBannerEntity {
  final String id;
  final String label;
  final String mealName;
  final String? mealImageUrl;
  final String mealIcon;

  const PromoBannerEntity({
    required this.id,
    required this.label,
    required this.mealName,
    this.mealImageUrl,
    required this.mealIcon,
  });
}
