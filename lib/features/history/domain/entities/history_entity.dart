class RatingHistoryEntity {
  final String id;
  final String mealId;
  final String mealName;
  final String? mealImageUrl;
  final String mealIcon;
  final int tasteScore;
  final int presentationScore;
  final int portionScore;
  final int valueScore;
  final double overallScore;
  final String? comment;
  final bool isEdited;
  final DateTime createdAt;

  const RatingHistoryEntity({
    required this.id,
    required this.mealId,
    required this.mealName,
    this.mealImageUrl,
    required this.mealIcon,
    required this.tasteScore,
    required this.presentationScore,
    required this.portionScore,
    required this.valueScore,
    required this.overallScore,
    this.comment,
    required this.isEdited,
    required this.createdAt,
  });
}

class SuggestionHistoryEntity {
  final String id;
  final String? mealId;
  final String? mealName;
  final String type;
  final String content;
  final String priority;
  final String status;
  final DateTime createdAt;

  const SuggestionHistoryEntity({
    required this.id,
    this.mealId,
    this.mealName,
    required this.type,
    required this.content,
    required this.priority,
    required this.status,
    required this.createdAt,
  });
}
