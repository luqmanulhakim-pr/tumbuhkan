class AppConstants {
  // ============================================
  // MQTT Configuration
  // ============================================
  static const String mqttBrokerUrl = 'broker.hivemq.com';
  static const int mqttPort = 1883;
  static const String mqttClientId = 'tumbuhkan_flutter_client';
  static const int mqttKeepAlive = 60;
  static const Duration reconnectDelay = Duration(seconds: 5);
  static const int maxReconnectAttempts = 5;
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration heartbeatTimeout = Duration(minutes: 2);

  // ============================================
  // ✅ MQTT Topics - Sensor Data (Single JSON Topic)
  // ============================================
  static const String topicSensorData = 'tumbuhkan/sensor/data';

  // ============================================
  // ✅ MQTT Topics - Camera
  // ============================================
  static const String topicCameraCapture = 'tumbuhkan/camera/capture';
  static const String topicCameraStatus = 'tumbuhkan/camera/status';

  // ============================================
  // MQTT Topics - Actuator Control
  // ============================================
  static const String topicPumpControl = 'tumbuhkan/actuator/pump/control';
  static const String topicGrowLightControl =
      'tumbuhkan/actuator/growlight/control';
  static const String topicPhUpPumpControl = 'tumbuhkan/actuator/ph_up/control';
  static const String topicPhDownPumpControl =
      'tumbuhkan/actuator/ph_down/control';
  static const String topicNutrientAPumpControl =
      'tumbuhkan/actuator/nutrient_a/control';
  static const String topicNutrientBPumpControl =
      'tumbuhkan/actuator/nutrient_b/control';

  // ============================================
  // MQTT Topics - Actuator Status
  // ============================================
  static const String topicPumpStatus = 'tumbuhkan/actuator/pump/status';
  static const String topicGrowLightStatus =
      'tumbuhkan/actuator/growlight/status';
  static const String topicPhUpPumpStatus = 'tumbuhkan/actuator/ph_up/status';
  static const String topicPhDownPumpStatus =
      'tumbuhkan/actuator/ph_down/status';
  static const String topicNutrientAPumpStatus =
      'tumbuhkan/actuator/nutrient_a/status';
  static const String topicNutrientBPumpStatus =
      'tumbuhkan/actuator/nutrient_b/status';

  // ============================================
  // NEW: Flask Camera API
  // ============================================
  static const String flaskBaseUrl = 'http://192.168.1.100:5000';
  static const String flaskStreamUrl = '$flaskBaseUrl/stream';
  static const String flaskUploadUrl = '$flaskBaseUrl/upload';
  static const String flaskImagesUrl = '$flaskBaseUrl/images';

  // ============================================
  // Sensor Thresholds
  // ============================================
  static const double minTemperature = 18.0;
  static const double maxTemperature = 30.0;
  static const double minHumidity = 40.0;
  static const double maxHumidity = 80.0;
  static const double minPH = 5.5;
  static const double maxPH = 6.5;
  static const double minMoisture = 40.0;
  static const double maxMoisture = 80.0;
  static const double minPPM = 500.0;
  static const double maxPPM = 2000.0;

  // ============================================
  // App Info
  // ============================================
  static const String appName = 'Tumbuhkan';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Hydroponics by Part-IoT';
  static const String appDescription = 'Sistem IoT Hidroponik Cerdas';
  static const String githubRepo = 'https://github.com/username/tumbuhkan';

  // ============================================
  // NEW: API Endpoints (untuk integrasi Flask nanti)
  // ============================================
  // static const String apiBaseUrl = 'https://api.tumbuhkan.com';
  // static const String apiDiseaseDetection = '/api/detect-disease';
  // static const String apiGrowthPrediction = '/api/predict-growth';
  // static const String apiBatchUpload = '/api/sensors/batch';

  //Camera
  static const String cameraStreamUrl = 'http://192.168.1.146:5000/stream';
  static const String cameraPost = 'http://192.168.1.146:5000';

  static const String plantHeight = '15.4 cm';
  static const String plantLeafCount = '12 Helai';
  static const String plantHealthScore = '98%';
  static const String harvestPrediction = '12 Hari lagi';

  //Chatbot
  static const String geminiApiKey = 'AIzaSyBqWUMVZMZEa1D4HM1TwjWwqMaC-s_QveU';
  static const String geminiModel = 'gemini-2.5-flash';
  static const int geminiMaxTokens = 2048;
  static const double geminiTemperature = 0.7;

  // Chatbot Personality
  static const String chatbotName = 'Tumu Assistant';
  static const String chatbotRole = 'Hydroponics Expert Assistant';
}
