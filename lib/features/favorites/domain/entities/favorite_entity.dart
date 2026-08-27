class FavoriteEntity {
  final String mealId;
  final String mealName;
  final String mealNameAr;
  final String? mealImageUrl;
  final double avgOverall;
  final int totalRatings;
  final String categoryName;
  final String categoryIcon;

  const FavoriteEntity({
    required this.mealId,
    required this.mealName,
    required this.mealNameAr,
    this.mealImageUrl,
    required this.avgOverall,
    required this.totalRatings,
    required this.categoryName,
    required this.categoryIcon,
  });
}
