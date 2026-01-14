/// Model for disease detection logs from PostgreSQL
/// Matches API response from /api/v1/disease/latest and /api/v1/disease/history
class DiseaseLog {
  final int id;
  final DateTime timestamp;
  final DiseaseResult? diseaseResult;
  final String? imagePath;
  final String? annotatedImagePath;
  final String? imageUrl;
  final String? annotatedImageUrl;

  DiseaseLog({
    required this.id,
    required this.timestamp,
    this.diseaseResult,
    this.imagePath,
    this.annotatedImagePath,
    this.imageUrl,
    this.annotatedImageUrl,
  });

  factory DiseaseLog.fromJson(Map<String, dynamic> json) {
    // Handle two response formats:
    // 1. Direct: {disease_class, confidence} at root level
    // 2. Nested: {disease_result: {disease_class, confidence}}

    DiseaseResult? diseaseResult;

    if (json['disease_result'] != null) {
      diseaseResult = DiseaseResult.fromJson(json['disease_result']);
    } else if (json['disease_class'] != null) {
      diseaseResult = DiseaseResult(
        diseaseClass: json['disease_class'] ?? 'Unknown',
        confidence: _parseDouble(json['confidence']),
      );
    }

    return DiseaseLog(
      id: json['id'] ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      diseaseResult: diseaseResult,
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
      'disease_result': diseaseResult?.toJson(),
      'image_path': imagePath,
      'annotated_image_path': annotatedImagePath,
      'image_url': imageUrl,
      'annotated_image_url': annotatedImageUrl,
    };
  }

  /// Get disease class name
  String get diseaseName => diseaseResult?.displayName ?? 'Unknown';

  /// Get raw disease class
  String get diseaseClass => diseaseResult?.diseaseClass ?? 'Unknown';

  /// Get confidence percentage
  double get confidence => diseaseResult?.confidence ?? 0.0;

  /// Get confidence as percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if plant is healthy
  bool get isHealthy => diseaseResult?.isHealthy ?? false;

  /// Get formatted timestamp
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Disease detection result
class DiseaseResult {
  final String diseaseClass;
  final double confidence;

  DiseaseResult({
    required this.diseaseClass,
    required this.confidence,
  });

  factory DiseaseResult.fromJson(Map<String, dynamic> json) {
    return DiseaseResult(
      diseaseClass: json['disease_class'] ?? 'Unknown',
      confidence: _parseDouble(json['confidence']),
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
      'disease_class': diseaseClass,
      'confidence': confidence,
    };
  }

  /// Normalize disease class for matching
  String get _normalizedClass => diseaseClass.toLowerCase();

  /// Check if plant is healthy
  bool get isHealthy => _normalizedClass == 'healthy';

  /// Get display name in Indonesian
  String get displayName {
    switch (_normalizedClass) {
      case 'healthy':
        return 'Sehat';
      case 'bacterial':
        return 'Penyakit Bakteri';
      case 'downy_mildew_on_lettuce':
        return 'Embun Bulu';
      case 'powdery_mildew_on_lettuce':
        return 'Embun Tepung';
      case 'septoria_blight_on_lettuce':
        return 'Septoria Blight';
      case 'viral':
        return 'Penyakit Virus';
      case 'wilt_and_leaf_blight_on_lettuce':
        return 'Layu & Hawar Daun';
      default:
        return diseaseClass
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                : '')
            .join(' ');
    }
  }

  /// Get color based on disease status
  int get statusColorValue {
    if (isHealthy) {
      return 0xFF4CAF50; // Green
    } else {
      return 0xFFF44336; // Red
    }
  }
}
