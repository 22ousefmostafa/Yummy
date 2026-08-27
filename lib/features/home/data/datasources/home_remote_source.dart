import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/home_response_model.dart';

abstract class HomeRemoteSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<MealModel>> getPopularMeals({int limit = 4});
  Future<List<MealModel>> getFeaturedMeals({int limit = 3});
  Future<List<RecentRatingModel>> getRecentRatings({int limit = 5});
}

class HomeRemoteSourceImpl implements HomeRemoteSource {
  final SupabaseClient client;

  HomeRemoteSourceImpl(this.client);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final data = await client
        .from('categories')
        .select('id, name, name_ar, icon, sort_order')
        .order('sort_order', ascending: true);

    return (data as List)
        .map((e) => CategoryModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<MealModel>> getPopularMeals({int limit = 4}) async {
    final data = await client
        .from('meals')
        .select(
          'id, name, name_ar, image_url, avg_overall, total_ratings, is_featured, categories(icon)',
        )
        .eq('is_active', true)
        .order('avg_overall', ascending: false)
        .limit(limit);

    return (data as List)
        .map((e) => MealModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<MealModel>> getFeaturedMeals({int limit = 3}) async {
    final data = await client
        .from('meals')
        .select(
          'id, name, name_ar, image_url, avg_overall, total_ratings, is_featured, categories(icon)',
        )
        .eq('is_active', true)
        .eq('is_featured', true)
        .limit(limit);

    return (data as List)
        .map((e) => MealModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<RecentRatingModel>> getRecentRatings({int limit = 5}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await client
        .from('ratings')
        .select(
          'id, meal_id, overall_score, created_at, meals(name, name_ar, image_url, categories(icon))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map(
          (e) => RecentRatingModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }
}
