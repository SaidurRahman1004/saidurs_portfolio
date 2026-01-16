import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../config/env.dart';

class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();

  factory ImageUploadService() => _instance;

  ImageUploadService._internal();

  static ImageUploadService get instance => _instance;

  static const String _apiKey = AppConstants.imgbbApiKey;
  static const String _uploadUrl = AppConstants.imgbbUploadEndpoint;

  Future<String> uploadImage({
    required Uint8List imageBytes,
    String? fileName,
  }) async {
    try {
      //Cheak Api key
      if (!Env.isConfigured) {
        throw Exception('ImgBB API key not configured');
      }
        debugPrint('Starting image upload to ImgBB...');
        debugPrint(' Image size: ${imageBytes.length} bytes');

        //encode Image to base 64
        final base64Image = base64Encode(imageBytes);
        debugPrint(' Image encoded to base64');
        //Create HTTP Post Request
        final uri = Uri.parse('$_uploadUrl?key=$_apiKey');
        final request = http.MultipartRequest('POST', uri);

        //Add Image Data in base 64 formate
        request.fields['image'] = base64Image;
        // Optional File name set
        if (fileName != null) {
          request.fields['name'] = fileName;
        }
        debugPrint('Image data added to request');

        //Send Request
        final streamedResponse = await request.send();
        debugPrint('Request sent to ImgBB');
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('📨 Response status: ${response.statusCode}');

        //Check ResponseSending request to ImgBB...');
        if (response.statusCode == 200) {
          //Response JSon PArse
          final responseData = jsonDecode(response.body);
          debugPrint('Response data: $responseData');
          if (responseData['success'] == true &&
              responseData['data'] != null &&
              responseData['data']['url'] != null) {
            final imageUrl = responseData['data']['url'] as String;

            debugPrint(' Upload successful! ');
            debugPrint(' Image URL: $imageUrl');

            return imageUrl;
          } else {
            /// Response have no url
            throw Exception('Invalid response from ImgBB:  Missing image URL');
          }
        } else {
          // Upload failed
          debugPrint('Upload failed with status: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');

          // Error message extract
          try {
            final errorData = json.decode(response.body);
            final errorMessage =
                errorData['error']['message'] ?? 'Unknown error';
            throw Exception('ImgBB upload failed: $errorMessage');
          } catch (e) {
            throw Exception('ImgBB upload failed: ${response.statusCode}');
          }
        }

    } on http.ClientException catch (e) {
      /// Network error
      debugPrint('Network error: $e');
      throw Exception('Network error: Please check your internet connection');
    } catch (e) {
      debugPrint('Upload error: $e');
      throw Exception('Image upload failed: $e');
    }
  }

  //Upload Multiple Image
  Future<List<String>> uploadMultipleImages({
    required List<Uint8List> imagesBytesList,
  }) async {
    final List<String> imageUrls = [];

    try {
      debugPrint(' Uploading ${imagesBytesList.length} images...');

      /// each image upload
      for (int i = 0; i < imagesBytesList.length; i++) {
        debugPrint(' Uploading image ${i + 1}/${imagesBytesList.length}...');

        final url = await uploadImage(
          imageBytes: imagesBytesList[i],
          fileName: 'image_${DateTime.now().millisecondsSinceEpoch}_$i',
        );

        imageUrls.add(url);
        debugPrint(' Image ${i + 1} uploaded successfully');
      }

      debugPrint('All images uploaded successfully!');
      return imageUrls;
    } catch (e) {
      debugPrint(' Multiple upload error: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  // Delete image from ImgBB

  Future<void> deleteImage(String imageUrl) async {
    // ImgBB free tier doesn't support deletion
    debugPrint('ImgBB free tier does not support image deletion');
    debugPrint(' Removing image URL from database only');
  }

  bool validateImageSize(Uint8List imageBytes, {int maxSizeMB = 5}) {
    final sizeInMB = imageBytes.length / (1024 * 1024);

    debugPrint(' Image size:  ${sizeInMB.toStringAsFixed(2)} MB');

    if (sizeInMB > maxSizeMB) {
      debugPrint('⚠️ Image size exceeds $maxSizeMB MB limit');
      return false;
    }

    return true;
  }

  // Get recommended image size info
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
