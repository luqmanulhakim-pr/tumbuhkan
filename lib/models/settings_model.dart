class AppSettings {
  // Flask Backend Settings (untuk upload foto & API)
  final String flaskIpAddress;
  final int flaskPort;

  // ESP32-CAM Settings (untuk video streaming)
  final String esp32CamIpAddress;
  final int esp32CamPort;

  // Toggle: Pakai ESP32-CAM atau Flask untuk streaming
  final bool useEsp32CamForStream;

  AppSettings({
    required this.flaskIpAddress,
    this.flaskPort = 5000,
    required this.esp32CamIpAddress,
    this.esp32CamPort = 80,
    this.useEsp32CamForStream = true, // Default pakai ESP32-CAM
  });

  // Default settings
  factory AppSettings.defaultSettings() {
    return AppSettings(
      flaskIpAddress: '192.168.2.80',
      flaskPort: 5000,
      esp32CamIpAddress: '192.168.43.100',
      esp32CamPort: 80,
      useEsp32CamForStream: true,
    );
  }

  // ============================================
  // Flask URLs (untuk upload & API)
  // ============================================
  String get flaskBaseUrl => 'http://$flaskIpAddress:$flaskPort';
  String get flaskStreamUrl => '$flaskBaseUrl/stream';
  String get flaskUploadUrl => '$flaskBaseUrl/upload';
  String get flaskUploadGrowthUrl => '$flaskBaseUrl/uploadGrowth';
  String get flaskImagesUrl => '$flaskBaseUrl/images';
  String get flaskImagesGrowthUrl => '$flaskBaseUrl/imagesGrowth';
  String get flaskTestUrl => '$flaskBaseUrl/test';

  // ============================================
  // ESP32-CAM URLs (untuk streaming)
  // ============================================
  String get esp32CamBaseUrl => 'http://$esp32CamIpAddress:$esp32CamPort';
  String get esp32CamStreamUrl => '$esp32CamBaseUrl/stream';
  String get esp32CamCaptureUrl => '$esp32CamBaseUrl/capture';
  String get esp32CamStatusUrl => '$esp32CamBaseUrl/status';

  // ============================================
  // Dynamic Stream URL (tergantung toggle)
  // ============================================
  String get streamUrl =>
      useEsp32CamForStream ? esp32CamStreamUrl : flaskStreamUrl;

  // ============================================
  // JSON Serialization
  // ============================================
  Map<String, dynamic> toJson() {
    return {
      'flaskIpAddress': flaskIpAddress,
      'flaskPort': flaskPort,
      'esp32CamIpAddress': esp32CamIpAddress,
      'esp32CamPort': esp32CamPort,
      'useEsp32CamForStream': useEsp32CamForStream,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      flaskIpAddress: json['flaskIpAddress'] ?? '192.168.2.80',
      flaskPort: json['flaskPort'] ?? 5000,
      esp32CamIpAddress: json['esp32CamIpAddress'] ?? '192.168.43.100',
      esp32CamPort: json['esp32CamPort'] ?? 80,
      useEsp32CamForStream: json['useEsp32CamForStream'] ?? true,
    );
  }

  // ============================================
  // Copy With (untuk update settings)
  // ============================================
  AppSettings copyWith({
    String? flaskIpAddress,
    int? flaskPort,
    String? esp32CamIpAddress,
    int? esp32CamPort,
    bool? useEsp32CamForStream,
  }) {
    return AppSettings(
      flaskIpAddress: flaskIpAddress ?? this.flaskIpAddress,
      flaskPort: flaskPort ?? this.flaskPort,
      esp32CamIpAddress: esp32CamIpAddress ?? this.esp32CamIpAddress,
      esp32CamPort: esp32CamPort ?? this.esp32CamPort,
      useEsp32CamForStream: useEsp32CamForStream ?? this.useEsp32CamForStream,
    );
  }
}
