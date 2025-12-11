import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/constants.dart';

class CameraService {
  /// Upload foto ke Flask server
  static Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
      final uri = Uri.parse('${AppConstants.cameraPost}/upload');
      final request = http.MultipartRequest('POST', uri);

      // Attach image file
      final file = await http.MultipartFile.fromPath('image', imagePath);
      request.files.add(file);

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(responseBody),
        };
      } else {
        return {
          'success': false,
          'error': 'Upload failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get list of uploaded images
  static Future<Map<String, dynamic>> getImages() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.cameraPost}/images'));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get images',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
