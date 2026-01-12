import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sensor_log.dart';

export '../models/sensor_log.dart';

/// Service for fetching sensor logs from FastAPI backend
class LogService extends ChangeNotifier {
  List<SensorLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'daily';
  String _baseUrl = '';

  List<SensorLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;

  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    fetchLogs();
  }

  Future<void> fetchLogs({String? baseUrl}) async {
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
      final now = DateTime.now();
      DateTime startDate;
      int limit;

      switch (_selectedPeriod) {
        case 'weekly':
          startDate = now.subtract(const Duration(days: 7));
          limit = 500;
          break;
        case 'monthly':
          startDate = now.subtract(const Duration(days: 30));
          limit = 1000;
          break;
        default:
          startDate = now.subtract(const Duration(hours: 24));
          limit = 100;
      }

      final url = Uri.parse('$apiBaseUrl/api/v1/sensors/history').replace(
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': now.toIso8601String(),
          'limit': limit.toString(),
          'offset': '0',
        },
      );

      debugPrint('[LogService] Fetching: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((e) => SensorLog.fromJson(e)).toList();
        debugPrint('[LogService] Loaded ${_logs.length} records');
      } else {
        _error = 'Server error: ${response.statusCode}';
        debugPrint('[LogService] Error: $_error');
      }
    } catch (e) {
      _error = 'Connection failed';
      debugPrint('[LogService] Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<double> getChartData(String sensorType) {
    switch (sensorType) {
      case 'ph':
        return _logs.map((e) => e.ph).toList();
      case 'tds':
        return _logs.map((e) => e.tds).toList();
      case 'temp_air':
        return _logs.map((e) => e.tempAir).toList();
      case 'temp_udara':
        return _logs.map((e) => e.tempUdara).toList();
      case 'humidity':
        return _logs.map((e) => e.humidity).toList();
      case 'ldr':
        return _logs.map((e) => e.ldr.toDouble()).toList();
      case 'distance':
        return _logs.map((e) => e.distance).toList();
      case 'flow':
        return _logs.map((e) => e.flow).toList();
      default:
        return [];
    }
  }

  List<String> getTimeLabels() {
    return _logs.map((e) {
      if (_selectedPeriod == 'daily') {
        return '${e.timestamp.hour}:00';
      } else if (_selectedPeriod == 'weekly') {
        return [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ][e.timestamp.weekday - 1];
      } else {
        return '${e.timestamp.day}/${e.timestamp.month}';
      }
    }).toList();
  }
}
