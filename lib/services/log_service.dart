import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

/// Model untuk sensor log data
class SensorLog {
  final int id;
  final double ph;
  final double tds;
  final double tempAir;
  final double tempUdara;
  final double humidity;
  final int ldr;
  final double waterLevel;
  final double flow;
  final DateTime createdAt;

  SensorLog({
    required this.id,
    required this.ph,
    required this.tds,
    required this.tempAir,
    required this.tempUdara,
    required this.humidity,
    required this.ldr,
    required this.waterLevel,
    required this.flow,
    required this.createdAt,
  });

  factory SensorLog.fromJson(Map<String, dynamic> json) {
    return SensorLog(
      id: json['id'] ?? 0,
      ph: (json['ph'] ?? 0).toDouble(),
      tds: (json['tds'] ?? 0).toDouble(),
      tempAir: (json['temp_air'] ?? 0).toDouble(),
      tempUdara: (json['temp_udara'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ldr: json['ldr'] ?? 0,
      waterLevel: (json['water_level'] ?? json['distance'] ?? 0).toDouble(),
      flow: (json['flow'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['timestamp'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String()),
    );
  }
}

/// Service untuk fetch sensor logs dari backend API
class LogService extends ChangeNotifier {
  List<SensorLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'daily'; // daily, weekly, monthly

  List<SensorLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedPeriod => _selectedPeriod;

  void setPeriod(String period) {
    _selectedPeriod = period;
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate date range based on period
      final now = DateTime.now();
      DateTime startDate;
      int limit;

      switch (_selectedPeriod) {
        case 'weekly':
          startDate = now.subtract(const Duration(days: 7));
          limit = 168; // 7 days * 24 hours
          break;
        case 'monthly':
          startDate = now.subtract(const Duration(days: 30));
          limit = 720; // 30 days * 24 hours
          break;
        default: // daily
          startDate = now.subtract(const Duration(hours: 24));
          limit = 100;
      }

      // Format dates for API (ISO 8601)
      final startDateStr = startDate.toIso8601String();
      final endDateStr = now.toIso8601String();

      final url =
          '${AppConstants.sensorHistoryEndpoint}?start_date=$startDateStr&end_date=$endDateStr&limit=$limit';
      debugPrint('📊 Fetching sensor logs: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((e) => SensorLog.fromJson(e)).toList();
        debugPrint('✅ Loaded ${_logs.length} sensor logs');
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
        debugPrint('❌ Error: $_error');
      }
    } catch (e) {
      _error = 'Connection error: $e';
      debugPrint('❌ Error: $_error');

      // Load dummy data for testing
      _loadDummyData();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dummy data untuk testing UI tanpa backend
  void _loadDummyData() {
    debugPrint('📊 Loading dummy data for testing...');
    final now = DateTime.now();
    _logs = List.generate(24, (i) {
      final time = now.subtract(Duration(hours: 23 - i));
      return SensorLog(
        id: i,
        ph: 6.0 + (i % 5) * 0.2,
        tds: 800 + (i % 10) * 50,
        tempAir: 25 + (i % 8) * 0.5,
        tempUdara: 28 + (i % 6) * 0.3,
        humidity: 60 + (i % 10) * 2,
        ldr: 1000 + (i % 15) * 100,
        waterLevel: 50 + (i % 20) * 2,
        flow: 0.5 + (i % 5) * 0.1,
        createdAt: time,
      );
    });
    _error = 'Using dummy data (API offline)';
  }

  /// Get data points for chart
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
      case 'water_level':
        return _logs.map((e) => e.waterLevel).toList();
      case 'flow':
        return _logs.map((e) => e.flow).toList();
      default:
        return [];
    }
  }

  /// Get time labels for chart
  List<String> getTimeLabels() {
    return _logs.map((e) {
      if (_selectedPeriod == 'daily') {
        return '${e.createdAt.hour}:00';
      } else if (_selectedPeriod == 'weekly') {
        return [
          'Mon',
          'Tue',
          'Wed',
          'Thu',
          'Fri',
          'Sat',
          'Sun'
        ][e.createdAt.weekday - 1];
      } else {
        return '${e.createdAt.day}/${e.createdAt.month}';
      }
    }).toList();
  }
}
