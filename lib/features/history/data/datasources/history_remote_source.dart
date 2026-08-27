import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_response_model.dart';

abstract class HistoryRemoteSource {
  Future<List<RatingHistoryModel>> getRatingHistory();
  Future<List<SuggestionHistoryModel>> getSuggestionHistory();
  Future<void> deleteRating(String ratingId);
}

class HistoryRemoteSourceImpl implements HistoryRemoteSource {
  final SupabaseClient client;

  HistoryRemoteSourceImpl(this.client);

  @override
  Future<List<RatingHistoryModel>> getRatingHistory() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await client
        .from('ratings')
        .select(
          'id, meal_id, taste_score, presentation_score, portion_score, '
          'value_score, overall_score, comment, created_at, '
          'meals(name, name_ar, image_url, categories(icon))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map(
          (e) =>
              RatingHistoryModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<List<SuggestionHistoryModel>> getSuggestionHistory() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await client
        .from('suggestions')
        .select('id, meal_id, type, content, priority, status, created_at, meals(name, name_ar)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map(
          (e) => SuggestionHistoryModel.fromMap(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteRating(String ratingId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client
        .from('ratings')
        .delete()
        .eq('id', ratingId)
        .eq('user_id', userId);
  }
}
