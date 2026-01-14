import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/growth_log.dart';

/// Service for fetching growth detection data from FastAPI backend
class GrowthService extends ChangeNotifier {
  List<GrowthLog> _logs = [];
  GrowthLog? _latestGrowth;
  bool _isLoading = false;
  String? _error;
  String _baseUrl = '';

  List<GrowthLog> get logs => _logs;
  GrowthLog? get latestGrowth => _latestGrowth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  /// Fetch latest growth detection for Home screen
  Future<void> fetchLatestGrowth({String? baseUrl}) async {
    final apiBaseUrl = baseUrl ?? _baseUrl;
    if (apiBaseUrl.isEmpty) return;

    try {
      final url = Uri.parse('$apiBaseUrl/api/v1/growth/latest');
      debugPrint('[GrowthService] Fetching latest: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestGrowth = GrowthLog.fromJson(data);
        debugPrint('[GrowthService] Latest: ${_latestGrowth?.stageName}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[GrowthService] Error fetching latest: $e');
    }
  }

  /// Fetch growth detection history
  Future<void> fetchHistory({
    String? baseUrl,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final apiBaseUrl = baseUrl ?? _baseUrl;
    if (apiBaseUrl.isEmpty) {
      _error = 'API base URL not configured';
      _isLoading = false;
      notifyListeners();
      return;
    }

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

      final url = Uri.parse('$apiBaseUrl/api/v1/growth/history')
          .replace(queryParameters: queryParams);

      debugPrint('[GrowthService] Fetching history: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((e) => GrowthLog.fromJson(e)).toList();
        debugPrint('[GrowthService] Loaded ${_logs.length} growth logs');
      } else {
        _error = 'Server error: ${response.statusCode}';
        debugPrint('[GrowthService] Error: $_error');
      }
    } catch (e) {
      _error = 'Connection failed';
      debugPrint('[GrowthService] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch single growth log by ID
  Future<GrowthLog?> fetchById(int growthId, {String? baseUrl}) async {
    final apiBaseUrl = baseUrl ?? _baseUrl;
    if (apiBaseUrl.isEmpty) return null;

    try {
      final url = Uri.parse('$apiBaseUrl/api/v1/growth/$growthId');
      debugPrint('[GrowthService] Fetching by ID: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GrowthLog.fromJson(data);
      }
    } catch (e) {
      debugPrint('[GrowthService] Error fetching by ID: $e');
    }
    return null;
  }
}
