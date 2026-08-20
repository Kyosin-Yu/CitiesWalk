//to communicate with Supbase Database

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProfileDataSource {
  final SupabaseClient _client;

  const ProfileDataSource(this._client);

  Future<void> createProfile({
    required String id,
    required String fullName,
    String? phoneNumber,
  }) async {
    debugPrint('========== CREATE PROFILE ==========');
    debugPrint('id: $id');
    debugPrint('fullName: $fullName');
    debugPrint('phone: $phoneNumber');

    await _client.from('profiles').insert({
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
    });

    debugPrint('========== PROFILE INSERT SUCCESS ==========');
  }

  Future<Map<String, dynamic>?> getProfile(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile({
    required String id,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? bio,
    bool? publicProfile,
  }) async {
    final updates = <String, dynamic>{};

    if (fullName != null) {
      updates['full_name'] = fullName;
    }

    if (phoneNumber != null) {
      updates['phone_number'] = phoneNumber;
    }

    if (profileImage != null) {
      updates['profile_image'] = profileImage;
    }

    if (bio != null) {
      updates['bio'] = bio;
    }

    if (publicProfile != null) {
      updates['public_profile'] = publicProfile;
    }

    updates['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('profiles').update(updates).eq('id', id);
  }
}
