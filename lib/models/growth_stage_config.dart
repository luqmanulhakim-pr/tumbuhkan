/// Model for growth stage configuration thresholds from PostgreSQL
class GrowthStageConfig {
  final int id;
  final String stageName;
  final double tdsTarget;
  final double tdsTolerance;
  final double phTarget;
  final double phTolerance;
  final double tempThresholdHigh;
  final int ldrThresholdDark;
  final DateTime? updatedAt;

  GrowthStageConfig({
    required this.id,
    required this.stageName,
    required this.tdsTarget,
    this.tdsTolerance = 50.0,
    required this.phTarget,
    this.phTolerance = 0.2,
    this.tempThresholdHigh = 30.0,
    this.ldrThresholdDark = 500,
    this.updatedAt,
  });

  factory GrowthStageConfig.fromJson(Map<String, dynamic> json) {
    return GrowthStageConfig(
      id: json['id'] ?? 0,
      stageName: json['stage_name'] ?? '',
      tdsTarget: _parseDouble(json['tds_target']),
      tdsTolerance: _parseDouble(json['tds_tolerance']) ?? 50.0,
      phTarget: _parseDouble(json['ph_target']),
      phTolerance: _parseDouble(json['ph_tolerance']) ?? 0.2,
      tempThresholdHigh: _parseDouble(json['temp_threshold_high']) ?? 30.0,
      ldrThresholdDark: json['ldr_threshold_dark'] ?? 500,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stage_name': stageName,
      'tds_target': tdsTarget,
      'tds_tolerance': tdsTolerance,
      'ph_target': phTarget,
      'ph_tolerance': phTolerance,
      'temp_threshold_high': tempThresholdHigh,
      'ldr_threshold_dark': ldrThresholdDark,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if TDS is within target range
  bool isTdsInRange(double tds) {
    return tds >= (tdsTarget - tdsTolerance) &&
        tds <= (tdsTarget + tdsTolerance);
  }

  /// Check if pH is within target range
  bool isPhInRange(double ph) {
    return ph >= (phTarget - phTolerance) && ph <= (phTarget + phTolerance);
  }

  /// Check if temperature is too high
  bool isTempTooHigh(double temp) {
    return temp > tempThresholdHigh;
  }

  /// Check if it's dark (needs LED)
  bool isDark(int ldr) {
    return ldr < ldrThresholdDark;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Default stage configurations
  static List<GrowthStageConfig> get defaultConfigs => [
        GrowthStageConfig(
            id: 1,
            stageName: 'Stage 01: Early Growth',
            tdsTarget: 600.0,
            phTarget: 6.0),
        GrowthStageConfig(
            id: 2,
            stageName: 'Stage 02: Leafy Growth',
            tdsTarget: 800.0,
            phTarget: 6.0),
        GrowthStageConfig(
            id: 3,
            stageName: 'Stage 03: Head Formation',
            tdsTarget: 1000.0,
            phTarget: 6.0),
        GrowthStageConfig(
            id: 4,
            stageName: 'Stage 04: Harvest Stage',
            tdsTarget: 1100.0,
            phTarget: 6.0),
      ];
}
