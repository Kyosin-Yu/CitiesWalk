//to communicate to Supbase Storage
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStorageDataSource {
  final SupabaseClient _client;

  const ProfileStorageDataSource(this._client);

  static const String _bucketName = 'profile-images';

  Future<String> uploadProfileImage({
    required String userId,
    required String localImagePath,
  }) async {
    final imageFile = File(localImagePath);

    final extension = localImagePath.split('.').last.toLowerCase();

    final storagePath = '$userId/profile.$extension';

    await _client.storage
        .from(_bucketName)
        .upload(
          storagePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );

    return storagePath;
  }

  Future<String?> createSignedImageUrl(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return null;
    }

    return _client.storage.from(_bucketName).createSignedUrl(storagePath, 3600);
  }
}
