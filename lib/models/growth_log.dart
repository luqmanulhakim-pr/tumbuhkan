/// Model for growth detection logs from PostgreSQL
/// Matches API response from /api/v1/growth/latest and /api/v1/growth/history
class GrowthLog {
  final int id;
  final DateTime timestamp;
  final GrowthStage? growthStage;
  final String? imagePath;
  final String? annotatedImagePath;
  final String? imageUrl;
  final String? annotatedImageUrl;

  GrowthLog({
    required this.id,
    required this.timestamp,
    this.growthStage,
    this.imagePath,
    this.annotatedImagePath,
    this.imageUrl,
    this.annotatedImageUrl,
  });

  factory GrowthLog.fromJson(Map<String, dynamic> json) {
    // Handle two response formats:
    // 1. Direct: {growth_class, confidence} at root level (from /prediction/growth/detect)
    // 2. Nested: {growth_stage: {growth_class, confidence}} (from /growth/history)

    GrowthStage? growthStage;

    if (json['growth_stage'] != null) {
      // Nested format (from database/history)
      growthStage = GrowthStage.fromJson(json['growth_stage']);
    } else if (json['growth_class'] != null) {
      // Direct format (from prediction API)
      growthStage = GrowthStage(
        growthClass: json['growth_class'] ?? 'Unknown',
        confidence: _parseDouble(json['confidence']),
      );
    }

    return GrowthLog(
      id: json['id'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      growthStage: growthStage,
      imagePath: json['image_path'],
      annotatedImagePath: json['annotated_image_path'],
      imageUrl: json['image_url'],
      annotatedImageUrl: json['annotated_image_url'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'growth_stage': growthStage?.toJson(),
      'image_path': imagePath,
      'annotated_image_path': annotatedImagePath,
      'image_url': imageUrl,
      'annotated_image_url': annotatedImageUrl,
    };
  }

  /// Get stage class name
  String get stageName => growthStage?.growthClass ?? 'Unknown';

  /// Get confidence percentage
  double get confidence => growthStage?.confidence ?? 0.0;

  /// Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Get formatted timestamp
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Growth stage detection result
class GrowthStage {
  final double confidence;
  final String growthClass;

  GrowthStage({
    required this.confidence,
    required this.growthClass,
  });

  factory GrowthStage.fromJson(Map<String, dynamic> json) {
    return GrowthStage(
      confidence: _parseDouble(json['confidence']),
      growthClass: json['growth_class'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'growth_class': growthClass,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
