import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_photo_moderation_result.dart';

/// Calls the protected Edge Function that checks an image with SafeSearch.
class ReviewImageModerationDataSource {
  const ReviewImageModerationDataSource(this._client);

  final SupabaseClient _client;

  Future<ReviewPhotoModerationResult> moderate(ReviewPhoto photo) async {
    final bytes = photo.bytes;
    if (bytes == null || bytes.isEmpty) {
      return const ReviewPhotoModerationResult.rejected(
        'This photo could not be read. Please choose another image.',
      );
    }

    final response = await _client.functions.invoke(
      'review-image-moderation',
      body: <String, dynamic>{
        'image': base64Encode(bytes),
        'contentType': photo.contentType,
      },
    );
    final data = Map<String, dynamic>.from(response.data as Map);
    if (data['approved'] == true) {
      return const ReviewPhotoModerationResult.approved();
    }
    return ReviewPhotoModerationResult.rejected(
      data['message'] as String? ??
          'This photo cannot be attached to a review.',
    );
  }
}
