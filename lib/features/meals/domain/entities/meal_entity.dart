class MealEntity {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? imageUrl;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final double avgOverall;
  final int totalRatings;
  final int totalComments;
  final bool isPopular;
  final bool isFavorite;

  const MealEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.avgOverall,
    required this.totalRatings,
    required this.totalComments,
    required this.isPopular,
    this.isFavorite = false,
  });

  MealEntity copyWith({bool? isFavorite}) {
    return MealEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      description: description,
      imageUrl: imageUrl,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      avgOverall: avgOverall,
      totalRatings: totalRatings,
      totalComments: totalComments,
      isPopular: isPopular,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ReviewEntity {
  final String id;
  final String reviewerName;
  final int tasteScore;
  final int presentationScore;
  final int portionScore;
  final int valueScore;
  final double overallScore;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.reviewerName,
    required this.tasteScore,
    required this.presentationScore,
    required this.portionScore,
    required this.valueScore,
    required this.overallScore,
    this.comment,
    required this.createdAt,
  });

  String get initials {
    final parts = reviewerName.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

class MealDetailEntity extends MealEntity {
  final double avgTaste;
  final double avgPresentation;
  final double avgPortion;
  final double avgValue;
  final List<ReviewEntity> recentReviews;

  const MealDetailEntity({
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
    required this.avgTaste,
    required this.avgPresentation,
    required this.avgPortion,
    required this.avgValue,
    required this.recentReviews,
  });
}

class SubmitRatingParams {
  final String mealId;
  final int tasteScore;
  final int presentationScore;
  final int portionScore;
  final int valueScore;
  final String? comment;
  final String reviewerName;

  const SubmitRatingParams({
    required this.mealId,
    required this.tasteScore,
    required this.presentationScore,
    required this.portionScore,
    required this.valueScore,
    this.comment,
    required this.reviewerName,
  });

  double get overallScore =>
      (tasteScore + presentationScore + portionScore + valueScore) / 4.0;
}
