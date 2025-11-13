class AppConstants {
  // ============================================
  // MQTT Configuration
  // ============================================
  static const String mqttBrokerUrl = 'broker.hivemq.com';
  static const int mqttPort = 1883;
  static const String mqttClientId = 'tumbuhkan_flutter_client';

  // Connection Settings
  static const int mqttKeepAlive = 60;
  static const int mqttTimeout = 5;

  // Auto-Reconnect Settings
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const Duration maxReconnectDelay = Duration(minutes: 5);

  // Heartbeat Settings
  static const Duration heartbeatInterval = Duration(seconds: 30);
  static const Duration heartbeatTimeout = Duration(minutes: 2);

  // ============================================
  // MQTT Topics - Sensors (Subscribe)
  // ============================================
  static const String topicTemperature = 'tumbuhkan/sensor/temperature';
  static const String topicHumidity = 'tumbuhkan/sensor/humidity';
  static const String topicMoisture = 'tumbuhkan/sensor/moisture';
  static const String topicLight = 'tumbuhkan/sensor/light';
  static const String topicPH = 'tumbuhkan/sensor/ph';

  // CHANGED: Single PPM topic (from TDS sensor)
  static const String topicNutrientPPM = 'tumbuhkan/sensor/ppm';

  // ============================================
  // MQTT Topics - Actuator Control (Publish)
  // ============================================
  static const String topicPumpControl = 'tumbuhkan/actuator/pump/control';
  static const String topicGrowLightControl =
      'tumbuhkan/actuator/growlight/control';
  static const String topicPhUpPumpControl = 'tumbuhkan/actuator/ph_up/control';
  static const String topicPhDownPumpControl =
      'tumbuhkan/actuator/ph_down/control';

  // ✅ KEEP: Control topics tetap terpisah
  static const String topicNutrientAPumpControl =
      'tumbuhkan/actuator/nutrient_a/control';
  static const String topicNutrientBPumpControl =
      'tumbuhkan/actuator/nutrient_b/control';

  // ============================================
  // MQTT Topics - Actuator Status (Subscribe)
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

  // ✅ ADD: PPM threshold
  static const double minPPM = 500.0;
  static const double maxPPM = 2000.0;

  // ============================================
  // App Info
  // ============================================
  static const String appName = 'Tumbuhkan';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Hydroponics by Part-IoT';
}
