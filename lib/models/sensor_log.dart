/// Model for sensor readings from PostgreSQL
class SensorLog {
  final int id;
  final DateTime timestamp;
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

  SensorLog({
    required this.id,
    required this.timestamp,
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
  });

  factory SensorLog.fromJson(Map<String, dynamic> json) {
    return SensorLog(
      id: json['id'] ?? 0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      ph: _parseDouble(json['ph']),
      phVoltage: _parseDouble(json['ph_voltage']),
      tds: _parseDouble(json['tds']),
      tdsVoltage: _parseDouble(json['tds_voltage']),
      tempAir: _parseDouble(json['temp_air']),
      tempUdara: _parseDouble(json['temp_udara']),
      humidity: _parseDouble(json['humidity']),
      ldr: _parseInt(json['ldr']),
      distance: _parseDouble(json['distance']),
      flow: _parseDouble(json['flow']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'ph': ph,
      'ph_voltage': phVoltage,
      'tds': tds,
      'tds_voltage': tdsVoltage,
      'temp_air': tempAir,
      'temp_udara': tempUdara,
      'humidity': humidity,
      'ldr': ldr,
      'distance': distance,
      'flow': flow,
    };
  }

  // Aliases for backward compatibility
  DateTime get createdAt => timestamp;
  double get waterLevel => distance;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
