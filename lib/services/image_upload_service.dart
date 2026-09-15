import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();
  static ImageUploadService get instance => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads an image to Firebase Storage and returns the download URL.
  /// Reports upload progress via [onProgress] if provided.
  Future<String> uploadImage({
    required Uint8List imageBytes,
    String? fileName,
    String folder = 'uploads',
    void Function(double progress)? onProgress,
  }) async {
    // 1. Security Check: Ensure user is authenticated before uploading
    if (_auth.currentUser == null) {
      throw Exception('Upload failed: User is not authenticated.');
    }

    // 2. Generate unique filename
    final String safeFileName = fileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String fullPath = '$folder/$safeFileName';

    try {
      final Reference ref = _storage.ref().child(fullPath);

      // Set Metadata to ensure correct handling
      final SettableMetadata metadata = SettableMetadata(
        contentType: _guessContentType(safeFileName),
        customMetadata: {'uploaded_by': _auth.currentUser!.uid},
      );

      // 3. Start Upload
      final UploadTask uploadTask = ref.putData(imageBytes, metadata);

      // 4. Listen to progress if callback is provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // 5. Wait for completion and return URL
      final TaskSnapshot completedTask = await uploadTask;
      final String downloadUrl = await completedTask.ref.getDownloadURL();
      
      debugPrint('Successfully uploaded image to: $fullPath');
      return downloadUrl;

    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Failed to upload image: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Upload Error: $e');
      throw Exception('An unexpected error occurred during upload.');
    }
  }

  /// Uploads multiple images and returns a list of URLs.
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> imagesBytesList,
    String folder = 'uploads',
    void Function(int currentIndex, int total, double currentProgress)? onProgress,
  }) async {
    final List<String> imageUrls = [];

    try {
      for (int i = 0; i < imagesBytesList.length; i++) {
        final url = await uploadImage(
          imageBytes: imagesBytesList[i],
          fileName: 'img_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          folder: folder,
          onProgress: (progress) {
            if (onProgress != null) {
              onProgress(i + 1, imagesBytesList.length, progress);
            }
          },
        );
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      debugPrint('Multiple upload error: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  /// Deletes an image from Firebase Storage using its download URL.
  Future<void> deleteImage(String imageUrl) async {
    if (_auth.currentUser == null) {
      throw Exception('Delete failed: User is not authenticated.');
    }

    try {
      // Create a reference from the download URL and delete it
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('Successfully deleted image: ${ref.fullPath}');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        debugPrint('Image already deleted or not found: $imageUrl');
        return; // Ignore if it doesn't exist to avoid orphaned data errors
      }
      debugPrint('Firebase Storage Delete Error: ${e.code} - ${e.message}');
      throw Exception('Failed to delete image: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('Delete Error: $e');
      throw Exception('An unexpected error occurred during deletion.');
    }
  }

  /// Validates image size against [maxSizeMB].
  bool validateImageSize(Uint8List imageBytes, {int maxSizeMB = 5}) {
    final sizeInMB = imageBytes.length / (1024 * 1024);
    if (sizeInMB > maxSizeMB) {
      debugPrint('Warning: Image size (${sizeInMB.toStringAsFixed(2)} MB) exceeds $maxSizeMB MB limit');
      return false;
    }
    return true;
  }

  /// Returns a human-readable size string.
  String getImageSizeInfo(Uint8List imageBytes) {
    final sizeInBytes = imageBytes.length;
    final sizeInKB = sizeInBytes / 1024;
    final sizeInMB = sizeInKB / 1024;

    if (sizeInMB >= 1) {
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else if (sizeInKB >= 1) {
      return '${sizeInKB.toStringAsFixed(2)} KB';
    } else {
      return '$sizeInBytes bytes';
    }
  }

  /// Helper to guess content type from filename extension
  String _guessContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
