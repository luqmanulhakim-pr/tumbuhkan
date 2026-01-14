import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/disease_log.dart';

/// Service for disease detection log API calls
class DiseaseService {
  final String baseUrl;

  DiseaseService({required this.baseUrl});

  /// Fetch latest disease detection
  Future<DiseaseLog?> fetchLatestDisease() async {
    try {
      final url = '$baseUrl/api/v1/disease/latest';
      debugPrint('[DiseaseService] Fetching latest from: $url');

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DiseaseLog.fromJson(data);
      } else if (response.statusCode == 404) {
        debugPrint('[DiseaseService] No disease detection found');
        return null;
      } else {
        debugPrint('[DiseaseService] Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[DiseaseService] Exception: $e');
      return null;
    }
  }

  /// Fetch disease detection history
  Future<List<DiseaseLog>> fetchHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/api/v1/disease/history')
          .replace(queryParameters: queryParams);

      debugPrint('[DiseaseService] Fetching history from: $uri');

      final response = await http.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('[DiseaseService] Received ${data.length} records');
        return data.map((item) => DiseaseLog.fromJson(item)).toList();
      } else {
        debugPrint('[DiseaseService] Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[DiseaseService] Exception: $e');
      return [];
    }
  }

  /// Fetch disease by ID
  Future<DiseaseLog?> fetchById(int id) async {
    try {
      final url = '$baseUrl/api/v1/disease/$id';
      debugPrint('[DiseaseService] Fetching by ID from: $url');

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DiseaseLog.fromJson(data);
      } else {
        debugPrint('[DiseaseService] Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('[DiseaseService] Exception: $e');
      return null;
    }
  }

  /// Fetch diseases by class
  Future<List<DiseaseLog>> fetchByClass(String diseaseClass) async {
    try {
      final url = '$baseUrl/api/v1/disease/by-class/$diseaseClass';
      debugPrint('[DiseaseService] Fetching by class from: $url');

      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DiseaseLog.fromJson(item)).toList();
      } else {
        debugPrint('[DiseaseService] Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('[DiseaseService] Exception: $e');
      return [];
    }
  }
}
