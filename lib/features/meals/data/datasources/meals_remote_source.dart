import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meal_model.dart';
import '../../domain/entities/meal_entity.dart';

abstract class MealsRemoteSource {
  Future<List<MealModel>> getMeals({
    String? categoryId,
    String sortBy,
    String filterBy,
  });
  Future<MealDetailModel> getMealDetails(String mealId);
  Future<List<MealCategoryModel>> getCategories();
  Future<void> submitRating(SubmitRatingParams params);
  Future<bool> toggleFavorite(String mealId);
  Future<Set<String>> getFavoriteIds();
}

class MealsRemoteSourceImpl implements MealsRemoteSource {
  final SupabaseClient client;
  MealsRemoteSourceImpl(this.client);

  @override
  Future<List<MealCategoryModel>> getCategories() async {
    final data = await client
        .from('categories')
        .select('id, name, name_ar, icon, sort_order')
        .order('sort_order', ascending: true);
    return (data as List)
        .map((e) => MealCategoryModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<MealModel>> getMeals({
    String? categoryId,
    String sortBy = 'popular',
    String filterBy = 'all',
  }) async {
    var query = client
        .from('meals')
        .select(
          'id, name, name_ar, description, image_url, avg_overall, total_ratings, '
          'is_featured, is_active, categories(id, name, icon), '
          'ratings(comment)',
        )
        .eq('is_active', true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }
    if (filterBy == 'popular') {
      query = query.eq('is_featured', true);
    } else if (filterBy == 'top_rated') {
      query = query.gte('avg_overall', 4.0);
    }

    final ordered = sortBy == 'top_rated'
        ? query.order('avg_overall', ascending: false)
        : sortBy == 'name'
            ? query.order('name', ascending: true)
            : query.order('is_featured', ascending: false);

    final data = await ordered;
    return (data as List)
        .map((e) => MealModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<MealDetailModel> getMealDetails(String mealId) async {
    final data = await client
        .from('meals')
        .select(
          'id, name, name_ar, description, image_url, avg_overall, total_ratings, '
          'is_featured, categories(id, name, icon), '
          'ratings(id, taste_score, presentation_score, portion_score, '
                   'value_score, overall_score, comment, created_at, '
                   'profiles!ratings_user_id_fkey(full_name))',
        )
        .eq('id', mealId)
        .single();
    return MealDetailModel.fromMap(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<void> submitRating(SubmitRatingParams params) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await client.from('ratings').upsert({
      'user_id': userId,
      'meal_id': params.mealId,
      'taste_score': params.tasteScore,
      'presentation_score': params.presentationScore,
      'portion_score': params.portionScore,
      'value_score': params.valueScore,
      'comment': params.comment,
    }, onConflict: 'user_id,meal_id');
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return {};
    final data = await client
        .from('favorites')
        .select('meal_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['meal_id'] as String).toSet();
  }

  @override
  Future<bool> toggleFavorite(String mealId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final existing = await client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('meal_id', mealId)
        .maybeSingle();

    if (existing != null) {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('meal_id', mealId);
      return false;
    } else {
      await client.from('favorites').insert({
        'user_id': userId,
        'meal_id': mealId,
      });
      return true;
    }
  }
}
