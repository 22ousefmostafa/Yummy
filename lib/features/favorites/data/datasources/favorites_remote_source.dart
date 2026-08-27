import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorites_response_model.dart';

abstract class FavoritesRemoteSource {
  Future<List<FavoriteModel>> getFavorites();
}

class FavoritesRemoteSourceImpl implements FavoritesRemoteSource {
  final SupabaseClient client;
  FavoritesRemoteSourceImpl(this.client);

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await client
        .from('favorites')
        .select(
          'meal_id, '
          'meals!inner('
          '  id, name, name_ar, image_url, avg_overall, total_ratings, '
          '  categories!inner(name, icon)'
          ')',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => FavoriteModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
