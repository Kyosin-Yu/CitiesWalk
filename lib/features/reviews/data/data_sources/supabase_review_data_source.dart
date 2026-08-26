import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../business_logic/entities/place_review.dart';
import '../../business_logic/entities/review_destination.dart';
import '../../business_logic/repositories/review_repository.dart';
import '../models/review_remote_model.dart';
import '../../../../core/models/destination_review_summary.dart';

/// Supabase-only access for Community Reviews. Presentation and business logic
/// use the repository contract instead of accessing this class directly.
class SupabaseReviewDataSource {
  SupabaseReviewDataSource(this._client);

  static const _photosBucket = 'review-photos';
  static const _photoUrlLifetimeSeconds = 60 * 60;

  final SupabaseClient _client;

  Future<List<PlaceReview>> fetchReviews(String destinationId) async {
    final rows = await _client
        .from('destination_reviews')
        .select()
        .eq('destination_id', destinationId)
        .order('created_at', ascending: false);
    final reviewRows = (rows as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    final markedReviewIds = await _fetchMarkedReviewIds(
      reviewRows.map((row) => row['id'] as String).toList(),
    );
    return Future.wait(
      reviewRows.map(
        (row) => _mapReview(
          row,
          isMarkedHelpful: markedReviewIds.contains(row['id'] as String),
        ),
      ),
    );
  }

  Future<DestinationReviewSummary> fetchRatingSummary(
    String destinationId,
  ) async {
    final rows = await _client
        .from('destination_reviews')
        .select('rating')
        .eq('destination_id', destinationId);
    final ratings = (rows as List<dynamic>)
        .map((row) => (row as Map)['rating'] as int)
        .toList();
    if (ratings.isEmpty) return DestinationReviewSummary.empty;
    return DestinationReviewSummary(
      averageRating:
          ratings.reduce((sum, rating) => sum + rating) / ratings.length,
      reviewCount: ratings.length,
    );
  }

  Future<PlaceReview> createReview({
    required ReviewDestination destination,
    required PlaceReview review,
  }) async {
    _ensureAuthenticatedOwner(review.userId);
    // A new review needs its destination identity as well as the editable
    // review fields. `updatePayload` deliberately excludes these required
    // destination columns and therefore cannot be used for inserts.
    final payload = {
      ...ReviewRemoteModel.insertPayload(review),
      'destination_id': destination.id,
      'destination_name': destination.name,
      'destination_category': destination.category,
    };
    final inserted = await _client
        .from('destination_reviews')
        .insert(payload)
        .select()
        .single();
    final reviewId = inserted['id'] as String;
    await _replaceLocalPhotos(
      reviewId: reviewId,
      userId: review.userId,
      photos: review.photos,
      existingPhotos: const [],
    );
    return _fetchReview(reviewId);
  }

  Future<PlaceReview> updateReview({required PlaceReview review}) async {
    _ensureAuthenticatedOwner(review.userId);
    final existing = await _fetchReview(review.id);
    // Destination identity is immutable after creation. Including it here
    // violates the owner-only database grants and makes every edit fail.
    final payload = ReviewRemoteModel.updatePayload(review);
    await _client
        .from('destination_reviews')
        .update(payload)
        .eq('id', review.id);
    await _replaceLocalPhotos(
      reviewId: review.id,
      userId: review.userId,
      photos: review.photos,
      existingPhotos: existing.photos,
    );
    return _fetchReview(review.id);
  }

  Future<void> deleteReview({
    required String reviewId,
    required String userId,
  }) async {
    _ensureAuthenticatedOwner(userId);
    final existing = await _fetchReview(reviewId);
    final storedPaths = existing.photos
        .map((photo) => photo.storagePath)
        .whereType<String>()
        .toList();
    if (storedPaths.isNotEmpty) {
      await _client.storage.from(_photosBucket).remove(storedPaths);
    }
    await _client.from('destination_reviews').delete().eq('id', reviewId);
  }

  Future<PlaceReview> toggleHelpful({
    required String reviewId,
    required String userId,
  }) async {
    _ensureAuthenticatedOwner(userId);
    final review = await _fetchReview(reviewId);
    if (review.userId == userId) {
      throw StateError('You cannot mark your own review as helpful.');
    }

    final existing = await _client
        .from('review_helpful_marks')
        .select('review_id')
        .eq('review_id', reviewId)
        .eq('user_id', userId);
    if ((existing as List<dynamic>).isEmpty) {
      await _client.from('review_helpful_marks').insert({
        'review_id': reviewId,
        'user_id': userId,
      });
    } else {
      await _client
          .from('review_helpful_marks')
          .delete()
          .eq('review_id', reviewId)
          .eq('user_id', userId);
    }
    return _fetchReview(reviewId);
  }

  Future<PlaceReview> _fetchReview(String reviewId) async {
    final row = await _client
        .from('destination_reviews')
        .select()
        .eq('id', reviewId)
        .single();
    return _mapReview(
      Map<String, dynamic>.from(row as Map),
      isMarkedHelpful: (await _fetchMarkedReviewIds([
        reviewId,
      ])).contains(reviewId),
    );
  }

  Future<Set<String>> _fetchMarkedReviewIds(List<String> reviewIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || reviewIds.isEmpty) return const {};
    final rows = await _client
        .from('review_helpful_marks')
        .select('review_id')
        .eq('user_id', userId)
        .inFilter('review_id', reviewIds);
    return (rows as List<dynamic>)
        .map((row) => (row as Map)['review_id'] as String)
        .toSet();
  }

  Future<PlaceReview> _mapReview(
    Map<String, dynamic> row, {
    required bool isMarkedHelpful,
  }) async {
    final photoRows = await _client
        .from('review_photos')
        .select()
        .eq('review_id', row['id'] as String)
        .order('position');
    final photos = await Future.wait(
      (photoRows as List<dynamic>).map((value) async {
        final photo = Map<String, dynamic>.from(value as Map);
        final storagePath = photo['storage_path'] as String;
        final signedUrl = await _client.storage
            .from(_photosBucket)
            .createSignedUrl(storagePath, _photoUrlLifetimeSeconds);
        return ReviewPhoto(
          id: photo['id'] as String,
          name: storagePath.split('/').last,
          storagePath: storagePath,
          signedUrl: signedUrl,
        );
      }),
    );
    return ReviewRemoteModel(
      row,
    ).toEntity(photos: photos, isMarkedHelpful: isMarkedHelpful);
  }

  Future<void> _replaceLocalPhotos({
    required String reviewId,
    required String userId,
    required List<ReviewPhoto> photos,
    required List<ReviewPhoto> existingPhotos,
  }) async {
    final retainedPaths = photos
        .map((photo) => photo.storagePath)
        .whereType<String>()
        .toSet();
    final removedPaths = existingPhotos
        .map((photo) => photo.storagePath)
        .whereType<String>()
        .where((path) => !retainedPaths.contains(path))
        .toList();

    // `position` is unique per review. Updating existing rows one at a time
    // can momentarily create duplicate positions when the user reorders or
    // replaces photos, so rebuild the lightweight database records first.
    // Retained Storage objects are reused; only removed files are deleted.
    if (existingPhotos.isNotEmpty) {
      await _client.from('review_photos').delete().eq('review_id', reviewId);
    }
    if (removedPaths.isNotEmpty) {
      await _client.storage.from(_photosBucket).remove(removedPaths);
    }

    for (final entry in photos.indexed) {
      final index = entry.$1;
      final photo = entry.$2;
      var storagePath = photo.storagePath;
      if (storagePath == null) {
        final bytes = photo.bytes;
        if (bytes == null) continue;
        final extension = _fileExtension(photo.name);
        storagePath =
            '$userId/$reviewId/${DateTime.now().microsecondsSinceEpoch}-$index.$extension';
        await _uploadPhoto(
          storagePath: storagePath,
          bytes: bytes,
          contentType: photo.contentType,
        );
      }
      await _client.from('review_photos').insert({
        'review_id': reviewId,
        'storage_path': storagePath,
        'position': index,
      });
    }
  }

  Future<void> _uploadPhoto({
    required String storagePath,
    required Uint8List bytes,
    String? contentType,
  }) async {
    await _client.storage
        .from(_photosBucket)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType ?? 'image/jpeg',
            upsert: false,
          ),
        );
  }

  String _fileExtension(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' || 'png' || 'webp' => extension,
      _ => 'jpg',
    };
  }

  void _ensureAuthenticatedOwner(String userId) {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null || currentUserId != userId) {
      throw StateError('Please sign in again before changing a review.');
    }
  }
}
