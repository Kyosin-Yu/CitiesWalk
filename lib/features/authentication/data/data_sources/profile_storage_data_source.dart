//to communicate to Supbase Storage
import 'dart:io';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';

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
    await _ensureImageIsApproved(imageFile, extension);

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

  Future<void> _ensureImageIsApproved(File imageFile, String extension) async {
    final contentType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw const AppException('Only JPEG, PNG, or WebP images are allowed.'),
    };
    final bytes = await imageFile.readAsBytes();
    final response = await _client.functions.invoke(
      'image-moderation',
      body: <String, dynamic>{
        'image': base64Encode(bytes),
        'contentType': contentType,
      },
    );
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : const <String, dynamic>{};
    if (data['approved'] == true) return;

    throw AppException(
      data['message'] as String? ??
          'This profile image cannot be used. Please choose another image.',
    );
  }

  Future<String?> createSignedImageUrl(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return null;
    }

    return _client.storage.from(_bucketName).createSignedUrl(storagePath, 3600);
  }
}
