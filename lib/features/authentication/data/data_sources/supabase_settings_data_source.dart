import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSettingsDataSource {
  const SupabaseSettingsDataSource(this._client);

  static const metadataKey = 'citieswalk_settings';

  final SupabaseClient _client;

  Map<String, dynamic>? load() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('No authenticated user found.');
    }
    final value = user.userMetadata?[metadataKey];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  Future<Map<String, dynamic>> save(Map<String, dynamic> settings) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: {metadataKey: settings}),
    );
    final saved = response.user?.userMetadata?[metadataKey];
    if (saved is! Map) {
      throw const AuthException('Unable to save settings.');
    }
    return Map<String, dynamic>.from(saved);
  }
}
