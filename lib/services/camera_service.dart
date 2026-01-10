import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CameraService {
  static const Duration _timeout = Duration(seconds: 30); // 🆕 Timeout 30 detik

  // /// Upload foto ke Flask server
  // /// [baseUrl] diambil dari SettingsService
  // static Future<Map<String, dynamic>> uploadImage(
  //   String imagePath,
  //   String baseUrl, // 🆕 Tambah parameter baseUrl
  // ) async {
  //   try {
  //     final uploadUrl = '$baseUrl/upload';
  //     debugPrint('═══════════════════════════════════════');
  //     debugPrint('🔵 [CAMERA SERVICE] Starting upload...');
  //     debugPrint('🔵 [CAMERA SERVICE] Upload URL: $uploadUrl');
  //     debugPrint('🔵 [CAMERA SERVICE] Image path: $imagePath');

  //     final uri = Uri.parse(uploadUrl);
  //     final request = http.MultipartRequest('POST', uri);

  //     // Attach image file
  //     final file = await http.MultipartFile.fromPath('image', imagePath);
  //     debugPrint('🔵 [CAMERA SERVICE] File size: ${file.length} bytes');

  //     request.files.add(file);

  //     debugPrint('🔵 [CAMERA SERVICE] Sending request...');

  //     // Send request with timeout
  //     final streamedResponse = await request.send().timeout(
  //       _timeout,
  //       onTimeout: () {
  //         debugPrint(
  //             '🔴 [CAMERA SERVICE] Request timeout after ${_timeout.inSeconds}s');
  //         throw Exception('Upload timeout - check network connection');
  //       },
  //     );

  //     final response = await http.Response.fromStream(streamedResponse);

  //     debugPrint('🔵 [CAMERA SERVICE] Response status: ${response.statusCode}');
  //     debugPrint('🔵 [CAMERA SERVICE] Response body: ${response.body}');
  //     debugPrint('═══════════════════════════════════════');

  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'data': json.decode(response.body),
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'error':
  //             'Upload failed with status ${response.statusCode}: ${response.body}',
  //       };
  //     }
  //   } catch (e) {
  //     debugPrint('🔴 [CAMERA SERVICE] Exception: $e');
  //     debugPrint('═══════════════════════════════════════');
  //     return {
  //       'success': false,
  //       'error': e.toString(),
  //     };
  //   }
  // }

  // /// Get list of uploaded images
  // /// [baseUrl] diambil dari SettingsService
  // static Future<Map<String, dynamic>> getImages(
  //   String baseUrl, // 🆕 Tambah parameter baseUrl
  // ) async {
  //   try {
  //     final imagesUrl = '$baseUrl/images';
  //     debugPrint('🔵 [CAMERA SERVICE] Getting images from: $imagesUrl');

  //     final response = await http.get(Uri.parse(imagesUrl)).timeout(_timeout);

  //     debugPrint('🔵 [CAMERA SERVICE] Response status: ${response.statusCode}');

  //     if (response.statusCode == 200) {
  //       return {
  //         'success': true,
  //         'data': json.decode(response.body),
  //       };
  //     } else {
  //       return {
  //         'success': false,
  //         'error': 'Failed to get images',
  //       };
  //     }
  //   } catch (e) {
  //     debugPrint('🔴 [CAMERA SERVICE] Error: $e');
  //     return {
  //       'success': false,
  //       'error': e.toString(),
  //     };
  //   }
  // }

  // /// Test connection to Flask server
  // static Future<bool> testConnection(String baseUrl) async {
  //   try {
  //     debugPrint('🔵 [CAMERA SERVICE] Testing connection to: $baseUrl/test');
  //     final response = await http.get(Uri.parse('$baseUrl/test')).timeout(
  //           const Duration(seconds: 5),
  //         );

  //     debugPrint('🔵 [CAMERA SERVICE] Test response: ${response.statusCode}');
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     debugPrint('🔴 [CAMERA SERVICE] Connection test failed: $e');
  //     return false;
  //   }
  // }

  /// Detect plant disease from image
  /// Sends image to /api/v1/prediction/disease/detect
  /// Returns disease_class, confidence, and annotated image_base64
  static Future<Map<String, dynamic>> detectDisease(
    String imagePath,
    String baseUrl,
  ) async {
    try {
      final detectUrl = '$baseUrl/api/v1/prediction/disease/detect';
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔬 [CAMERA SERVICE] Starting disease detection...');
      debugPrint('🔬 [CAMERA SERVICE] Detect URL: $detectUrl');
      debugPrint('🔬 [CAMERA SERVICE] Image path: $imagePath');

      final uri = Uri.parse(detectUrl);
      final request = http.MultipartRequest('POST', uri);

      // Attach image file with field name 'file' as per API spec
      final file = await http.MultipartFile.fromPath('file', imagePath);
      debugPrint('🔬 [CAMERA SERVICE] File size: ${file.length} bytes');

      request.files.add(file);

      debugPrint('🔬 [CAMERA SERVICE] Sending detection request...');

      // Send request with longer timeout for ML processing
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('🔴 [CAMERA SERVICE] Detection timeout after 60s');
          throw Exception('Detection timeout - server may be processing');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔬 [CAMERA SERVICE] Response status: ${response.statusCode}');

      // Don't print full body as it may contain large base64 image
      final bodyPreview = response.body.length > 200
          ? '${response.body.substring(0, 200)}...'
          : response.body;
      debugPrint('🔬 [CAMERA SERVICE] Response preview: $bodyPreview');
      debugPrint('═══════════════════════════════════════');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error':
              'Detection failed with status ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('🔴 [CAMERA SERVICE] Detection exception: $e');
      debugPrint('═══════════════════════════════════════');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
