import 'package:image_picker/image_picker.dart';

import '../../business_logic/entities/place_review.dart';

/// Reads image files selected from the device gallery.
class ReviewImageDataSource {
  ReviewImageDataSource({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<List<ReviewPhoto>> pickPhotos() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 85);
    final selectedAt = DateTime.now().microsecondsSinceEpoch;
    final photos = <ReviewPhoto>[];

    for (var index = 0; index < files.length; index++) {
      final file = files[index];
      photos.add(
        ReviewPhoto(
          id: '$selectedAt-$index-${file.name}',
          name: file.name,
          bytes: await file.readAsBytes(),
          contentType: _contentTypeFor(file.name),
        ),
      );
    }

    return photos;
  }

  String _contentTypeFor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}
