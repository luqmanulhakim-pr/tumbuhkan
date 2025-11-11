class AppConstants {
  // App Info
  static const String appName = 'Tumbuhkan';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart IoT Hydroponics System';
  static const String mqttBrokerUrl = 'broker.hivemq.com';
  static const int mqttPort = 1883;

  static const String mqttClientIdPrefix = 'tumbuhkan_';
  static const int mqttKeepAlivePeriod = 60;
  static const Duration mqttReconnectDelay = Duration(seconds: 5);

  // MQTT Topics - Sensors (Subscribe)
  static const String topicTemperature = 'tumbuhkan/sensor/temperature';
  static const String topicHumidity = 'tumbuhkan/sensor/humidity';
  static const String topicLight = 'tumbuhkan/sensor/light';
  static const String topicMoisture = 'tumbuhkan/sensor/moisture';

  // ============================================
  // 🆕 MQTT Topics - Actuators (Two-Way Communication)
  // ============================================

  // Control Topics (App → Hardware) - untuk kirim command
  static const String topicPump = 'tumbuhkan/actuator/pump';
  static const String topicGrowLight = 'tumbuhkan/actuator/light';
  static const String topicFan = 'tumbuhkan/actuator/fan';

  // Status Topics (Hardware → App) - untuk terima status feedback
  static const String topicPumpStatus = 'tumbuhkan/actuator/pump/status';
  static const String topicGrowLightStatus = 'tumbuhkan/actuator/light/status';
  static const String topicFanStatus = 'tumbuhkan/actuator/fan/status';

  // MQTT Topics - Device Status
  static const String topicDeviceStatus = 'tumbuhkan/device/status';
  static const String topicDeviceControl = 'tumbuhkan/device/control';

  // ============================================
  // API URLs
  // ============================================
  static const String flaskApiBaseUrl = 'https://your-flask-api.com';
  static const String flaskDiseaseDetectionEndpoint = '/api/detect-disease';

  // ============================================
  // Firebase Collections
  // ============================================
  static const String devicesCollection = 'devices';
  static const String sensorsCollection = 'sensors';
  static const String actuatorsCollection = 'actuators';
  static const String usersCollection = 'users';
  static const String plantsCollection = 'plants';
  static const String alertsCollection = 'alerts';

  // ============================================
  // App Behavior
  // ============================================
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration sensorUpdateInterval = Duration(seconds: 5);
}
