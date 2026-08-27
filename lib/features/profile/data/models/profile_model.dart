import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.avatarUrl,
    super.phone,
    required super.ratingsCount,
    required super.suggestionsCount,
  });

  factory ProfileModel.fromAuthUser(
    User user, {
    required int ratingsCount,
    required int suggestionsCount,
  }) {
    final meta = user.userMetadata ?? {};
    return ProfileModel(
      id: user.id,
      fullName: (meta['full_name'] as String?) ?? '',
      email: user.email ?? '',
      avatarUrl: meta['avatar_url'] as String?,
      phone: meta['phone'] as String? ?? user.phone,
      ratingsCount: ratingsCount,
      suggestionsCount: suggestionsCount,
    );
  }
}
