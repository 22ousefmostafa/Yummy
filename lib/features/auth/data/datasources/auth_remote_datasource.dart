import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  Future<UserModel> _fetchProfile(String userId) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final data = await client
            .from('profiles')
            .select('id, email, full_name, role')
            .eq('id', userId)
            .single();

        return UserModel.fromProfileMap(
          Map<String, dynamic>.from(data),
        );
      } catch (_) {
        if (attempt == 2) rethrow;

        await Future<void>.delayed(
          Duration(milliseconds: 250 * (attempt + 1)),
        );
      }
    }

    throw const AuthException('Profile was not found');
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Login failed');
    }

    return _fetchProfile(user.id);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': 'user',
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Registration failed');
    }

    return _fetchProfile(user.id);
  }

  @override
  Future<void> logout() async {
    await client.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    return _fetchProfile(user.id);
  }
}