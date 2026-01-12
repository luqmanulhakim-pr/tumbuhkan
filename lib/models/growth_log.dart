/// Model for growth logs from PostgreSQL
class GrowthLog {
  final int id;
  final DateTime timestamp;
  final Map<String, dynamic>? growthStage;
  final String? imagePath;
  final String? annotatedImagePath;

  GrowthLog({
    required this.id,
    required this.timestamp,
    this.growthStage,
    this.imagePath,
    this.annotatedImagePath,
  });

  factory GrowthLog.fromJson(Map<String, dynamic> json) {
    return GrowthLog(
      id: json['id'] ?? 0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      growthStage: json['growth_stage'] is Map ? json['growth_stage'] : null,
      imagePath: json['image_path'],
      annotatedImagePath: json['annotated_image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'growth_stage': growthStage,
      'image_path': imagePath,
      'annotated_image_path': annotatedImagePath,
    };
  }

  /// Get stage name from growthStage JSONB
  String get stageName {
    if (growthStage == null) return 'Unknown';
    return growthStage!['stage_name'] ?? growthStage!['class'] ?? 'Unknown';
  }

  /// Get confidence from growthStage JSONB
  double get confidence {
    if (growthStage == null) return 0.0;
    final conf = growthStage!['confidence'];
    if (conf == null) return 0.0;
    if (conf is double) return conf;
    if (conf is int) return conf.toDouble();
    return 0.0;
  }
}
