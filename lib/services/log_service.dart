import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

/// Model for sensor log data from PostgreSQL backend
class SensorLog {
  final int id;
  final double ph;
  final double phVoltage;
  final double tds;
  final double tdsVoltage;
  final double tempAir;
  final double tempUdara;
  final double humidity;
  final int ldr;
  final double distance;
  final double flow;
  final String? imagePath;
  final String? annotatedImagePath;
  final int? growthStage;
  final String? imageUrl;
  final DateTime timestamp;

  SensorLog({
    required this.id,
    required this.ph,
    this.phVoltage = 0.0,
    required this.tds,
    this.tdsVoltage = 0.0,
    required this.tempAir,
    required this.tempUdara,
    required this.humidity,
    required this.ldr,
    required this.distance,
    required this.flow,
    this.imagePath,
    this.annotatedImagePath,
    this.growthStage,
    this.imageUrl,
    required this.timestamp,
  });

  factory SensorLog.fromJson(Map<String, dynamic> json) {
    return SensorLog(
      id: json['id'] ?? 0,
      ph: _parseDouble(json['ph']),
      phVoltage: _parseDouble(json['ph_voltage']),
      tds: _parseDouble(json['tds']),
      tdsVoltage: _parseDouble(json['tds_voltage']),
      tempAir: _parseDouble(json['temp_air']),
      tempUdara: _parseDouble(json['temp_udara']),
      humidity: _parseDouble(json['humidity']),
      ldr: (json['ldr'] ?? 0) is int ? json['ldr'] : (json['ldr'] ?? 0).toInt(),
      distance: _parseDouble(json['distance']),
      flow: _parseDouble(json['flow']),
      imagePath: json['image_path'],
      annotatedImagePath: json['annotated_image_path'],
      growthStage: json['growth_stage'],
      imageUrl: json['image_url'],
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Alias for backward compatibility
  DateTime get createdAt => timestamp;
  double get waterLevel => distance;
}

/// Service for fetching sensor logs from FastAPI backend
class LogService extends ChangeNotifier {
  List<SensorLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  String _selectedPeriod = 'daily';

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

      final startDateStr = startDate.toIso8601String();
      final endDateStr = now.toIso8601String();

      final url = Uri.parse(AppConstants.sensorHistoryEndpoint).replace(
        queryParameters: {
          'start_date': startDateStr,
          'end_date': endDateStr,
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
      _error = 'Connection failed: ${e.toString().split(':').last.trim()}';
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
