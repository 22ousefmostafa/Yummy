import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/suggest_repository.dart';

abstract class SuggestRemoteSource {
  Future<List<Map<String, dynamic>>> getMeals();
  Future<void> submitSuggestion(SubmitSuggestionParams params);
}

class SuggestRemoteSourceImpl implements SuggestRemoteSource {
  final SupabaseClient client;

  SuggestRemoteSourceImpl(this.client);

  @override
  Future<List<Map<String, dynamic>>> getMeals() async {
    final data = await client
        .from('meals')
        .select('id, name')
        .eq('is_active', true)
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  @override
  Future<void> submitSuggestion(SubmitSuggestionParams params) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final payload = <String, dynamic>{
      'user_id': userId,
      'type': params.type,
      'content': params.content,
      'priority': params.priority,
      'status': 'pending',
    };
    if (params.mealId != null) payload['meal_id'] = params.mealId;

    await client.from('suggestions').insert(payload);
  }
}
