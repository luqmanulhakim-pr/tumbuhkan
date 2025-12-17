class AppSettings {
  final String flaskIpAddress;
  final int flaskPort;

  AppSettings({
    required this.flaskIpAddress,
    this.flaskPort = 5000,
  });

  // Default settings
  factory AppSettings.defaultSettings() {
    return AppSettings(
      flaskIpAddress: '192.168.1.100',
      flaskPort: 5000,
    );
  }

  // Get full Flask URL
  String get flaskBaseUrl => 'http://$flaskIpAddress:$flaskPort';
  String get flaskStreamUrl => '$flaskBaseUrl/stream';
  String get flaskUploadUrl => '$flaskBaseUrl/upload';
  String get flaskImagesUrl => '$flaskBaseUrl/images';

  // Copy with
  AppSettings copyWith({
    String? flaskIpAddress,
    int? flaskPort,
  }) {
    return AppSettings(
      flaskIpAddress: flaskIpAddress ?? this.flaskIpAddress,
      flaskPort: flaskPort ?? this.flaskPort,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'flaskIpAddress': flaskIpAddress,
      'flaskPort': flaskPort,
    };
  }

  // From JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      flaskIpAddress: json['flaskIpAddress'] ?? '192.168.1.100',
      flaskPort: json['flaskPort'] ?? 5000,
    );
  }
}
