import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../config/env.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();
  static ImageUploadService get instance => _instance;

  static const String _uploadUrl = AppConstants.imgbbUploadEndpoint;

  /// Uploads an image to ImgBB and returns the direct CDN image URL (i.ibb.co/...).
  /// Reports upload progress via [onProgress] if provided.
  Future<String> uploadImage({
    required Uint8List imageBytes,
    String? fileName,
    String folder = 'uploads',
    void Function(double progress)? onProgress,
  }) async {
    final apiKey = Env.imgbbApiKey.trim();
    if (apiKey.isEmpty) {
      throw Exception('ImgBB API key is missing or not configured in Env.');
    }

    // Validate size (max 10 MB)
    if (!validateImageSize(imageBytes, maxSizeMB: 10)) {
      throw Exception('Image size exceeds 10 MB limit.');
    }

    try {
      onProgress?.call(0.15);
      debugPrint('[ImageUploadService] Starting ImgBB upload (${imageBytes.length} bytes)...');

      final base64Image = base64Encode(imageBytes);
      onProgress?.call(0.4);

      final uri = Uri.parse('$_uploadUrl?key=$apiKey');
      final request = http.MultipartRequest('POST', uri);

      request.fields['image'] = base64Image;
      if (fileName != null && fileName.trim().isNotEmpty) {
        request.fields['name'] = fileName.trim();
      }

      onProgress?.call(0.65);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      onProgress?.call(0.9);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final imageUrl = (data['data']['display_url'] ?? data['data']['url']) as String?;
          if (imageUrl != null && imageUrl.isNotEmpty) {
            debugPrint('[ImageUploadService] ImgBB upload successful: $imageUrl');
            onProgress?.call(1.0);
            return imageUrl;
          }
        }
        throw Exception('Invalid response format from ImgBB API.');
      } else {
        String errorMsg = 'HTTP ${response.statusCode}';
        try {
          final errJson = jsonDecode(response.body);
          if (errJson['error']?['message'] != null) {
            errorMsg = errJson['error']['message'];
          }
        } catch (_) {}
        debugPrint('[ImageUploadService] ImgBB upload failed: $errorMsg');
        throw Exception('ImgBB upload error: $errorMsg');
      }
    } catch (e) {
      debugPrint('[ImageUploadService] Error during image upload: $e');
      rethrow;
    }
  }

  /// Uploads multiple images sequentially and returns a list of URLs.
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> imagesBytesList,
    String folder = 'uploads',
    void Function(int currentIndex, int total, double currentProgress)? onProgress,
  }) async {
    final List<String> imageUrls = [];

    for (int i = 0; i < imagesBytesList.length; i++) {
      final url = await uploadImage(
        imageBytes: imagesBytesList[i],
        fileName: 'img_${DateTime.now().millisecondsSinceEpoch}_$i',
        folder: folder,
        onProgress: (progress) {
          onProgress?.call(i + 1, imagesBytesList.length, progress);
        },
      );
      imageUrls.add(url);
    }
    return imageUrls;
  }

  /// ImgBB free tier does not support remote deletion via API;
  /// safe no-op that logs the deletion intent.
  Future<void> deleteImage(String imageUrl) async {
    debugPrint('[ImageUploadService] ImgBB free tier image removal logged for: $imageUrl');
  }

  /// Validates image size against [maxSizeMB].
  bool validateImageSize(Uint8List imageBytes, {int maxSizeMB = 10}) {
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
}
