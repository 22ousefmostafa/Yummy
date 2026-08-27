import '../entities/meal_entity.dart';

class SearchMealsUseCase {
  List<MealEntity> call(List<MealEntity> meals, String query) {
    if (query.trim().isEmpty) return meals;
    final q = query.toLowerCase();
    return meals
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.nameAr.toLowerCase().contains(q))
        .toList();
  }
}
