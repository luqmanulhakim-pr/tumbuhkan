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
      imageBase64: json['image_base64'],
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

  /// Normalize disease class key for matching
  /// API returns: "Septoria_Blight_on_Lettuce" -> "septoria_blight_on_lettuce"
  String get _normalizedClass => diseaseClass.toLowerCase();

  /// Get display name for disease class (Indonesian)
  /// Matches exact API response classes from backend
  String get displayName {
    switch (_normalizedClass) {
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
        // Fallback: capitalize and replace underscores
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
    if (_normalizedClass == 'healthy') {
      return 0xFF4CAF50; // Green
    } else if (_normalizedClass == 'error') {
      return 0xFF9E9E9E; // Grey
    } else {
      return 0xFFF44336; // Red for diseases
    }
  }

  /// Get confidence percentage string
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if plant is healthy
  bool get isHealthy => _normalizedClass == 'healthy';

  /// Get treatment and prevention suggestions for each disease
  String get suggestion {
    switch (_normalizedClass) {
      case 'healthy':
        return 'Tanaman dalam kondisi sehat! Lanjutkan perawatan rutin dengan menjaga kadar nutrisi dan pH air tetap optimal.';
      case 'bacterial':
        return '• Segera pisahkan tanaman yang terinfeksi\n• Buang daun yang terserang\n• Gunakan bakterisida berbasis tembaga\n• Pastikan sirkulasi udara baik\n• Hindari kelembaban berlebih pada daun';
      case 'downy_mildew_on_lettuce':
        return '• Kurangi kelembaban di sekitar tanaman\n• Tingkatkan sirkulasi udara\n• Semprot dengan fungisida berbahan aktif metalaxyl\n• Hindari penyiraman pada malam hari\n• Buang daun yang terinfeksi';
      case 'powdery_mildew_on_lettuce':
        return '• Semprot dengan fungisida sulfur atau neem oil\n• Pastikan jarak tanam cukup\n• Tingkatkan sirkulasi udara\n• Kurangi kelembaban\n• Buang daun yang terserang parah';
      case 'septoria_blight_on_lettuce':
        return '• Buang dan musnahkan daun yang terinfeksi\n• Hindari penyiraman dari atas\n• Gunakan fungisida berbasis tembaga\n• Jaga kebersihan area tanam\n• Rotasi tanaman jika menanam di media';
      case 'viral':
        return '• Tidak ada obat untuk infeksi virus\n• Segera cabut dan musnahkan tanaman terinfeksi\n• Kendalikan serangga vektor (kutu daun, thrips)\n• Bersihkan alat-alat tanam\n• Gunakan bibit yang bebas virus';
      case 'wilt_and_leaf_blight_on_lettuce':
        return '• Periksa dan perbaiki drainase sistem\n• Kurangi kelembaban berlebih\n• Gunakan fungisida sistemik\n• Pastikan pH dan EC nutrisi optimal\n• Buang tanaman yang layu parah';
      default:
        return 'Konsultasikan dengan ahli pertanian untuk penanganan lebih lanjut.';
    }
  }
}
