import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/update_profile_model.dart';

abstract class ProfileRemoteSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(UpdateProfileModel model);
  Future<ProfileModel> updateAvatar(Uint8List bytes, String fileExtension);
}

class ProfileRemoteSourceImpl implements ProfileRemoteSource {
  final SupabaseClient client;

  ProfileRemoteSourceImpl(this.client);

  Future<ProfileModel> _buildProfile(User user) async {
    final ratings = await client
        .from('ratings')
        .select('id')
        .eq('user_id', user.id);

    final suggestions = await client
        .from('suggestions')
        .select('id')
        .eq('user_id', user.id);

    return ProfileModel.fromAuthUser(
      user,
      ratingsCount: (ratings as List).length,
      suggestionsCount: (suggestions as List).length,
    );
  }

  @override
  Future<ProfileModel> getProfile() async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return _buildProfile(user);
  }

  @override
  Future<ProfileModel> updateProfile(UpdateProfileModel model) async {
    final response = await client.auth.updateUser(
      UserAttributes(data: model.toAuthMetadata()),
    );

    final user = response.user ?? client.auth.currentUser;
    if (user == null) throw Exception('Update failed');
    return _buildProfile(user);
  }

  @override
  Future<ProfileModel> updateAvatar(Uint8List bytes, String fileExtension) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final ext = fileExtension.toLowerCase();
    final path = '$userId/avatar.$ext';

    await client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );

    // Cache-bust so Image widgets refetch after overwriting the same path.
    final publicUrl =
        '${client.storage.from('avatars').getPublicUrl(path)}?t=${DateTime.now().millisecondsSinceEpoch}';

    final response = await client.auth.updateUser(
      UserAttributes(data: {'avatar_url': publicUrl}),
    );

    final user = response.user ?? client.auth.currentUser;
    if (user == null) throw Exception('Update failed');
    return _buildProfile(user);
  }
}
