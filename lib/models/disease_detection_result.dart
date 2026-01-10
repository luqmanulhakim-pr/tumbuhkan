/// Model untuk hasil deteksi penyakit tanaman
class DiseaseDetectionResult {
  final bool success;
  final String diseaseClass;
  final double confidence;
  final String? imageBase64;
  final DateTime timestamp;
  final String? errorMessage;

  DiseaseDetectionResult({
    required this.success,
    required this.diseaseClass,
    required this.confidence,
    this.imageBase64,
    DateTime? timestamp,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionResult(
      success: json['success'] ?? false,
      diseaseClass: json['disease_class'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imageBase64: json['image_base64'], // FastAPI returns 'image_base64'
    );
  }

  factory DiseaseDetectionResult.error(String message) {
    return DiseaseDetectionResult(
      success: false,
      diseaseClass: 'error',
      confidence: 0.0,
      errorMessage: message,
    );
  }

  /// Get display name for disease class (Indonesian)
  String get displayName {
    switch (diseaseClass.toLowerCase()) {
      case 'healthy':
        return 'Sehat';
      case 'bacterial':
        return 'Penyakit Bakteri';
      case 'downy_mildew_on_lettuce':
        return 'Embun Bulu (Downy Mildew)';
      case 'powdery_mildew_on_lettuce':
        return 'Embun Tepung (Powdery Mildew)';
      case 'septoria_blight_on_lettuce':
        return 'Septoria Blight';
      case 'viral':
        return 'Penyakit Virus';
      case 'wilt_and_leaf_blight_on_lettuce':
        return 'Layu & Hawar Daun';
      default:
        return diseaseClass;
    }
  }

  /// Get color based on disease status
  int get statusColorValue {
    if (diseaseClass.toLowerCase() == 'healthy') {
      return 0xFF4CAF50; // Green
    } else if (diseaseClass.toLowerCase() == 'error') {
      return 0xFF9E9E9E; // Grey
    } else {
      return 0xFFF44336; // Red for diseases
    }
  }

  /// Get confidence percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if plant is healthy
  bool get isHealthy => diseaseClass.toLowerCase() == 'healthy';
}
