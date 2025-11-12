import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/constants.dart';
import 'mqtt_connection_state.dart';

class MqttService extends ChangeNotifier {
  // ============================================
  // Properties
  // ============================================
  late MqttServerClient client;
  AppMqttConnectionState _connectionState = AppMqttConnectionState.disconnected;

  // Sensor Data
  double _temperature = 0.0;
  double _humidity = 0.0;
  double _moistureLevel = 0.0;
  double _lightLevel = 0.0;
  double _phLevel = 0.0;
  double _nutrientA = 0.0;
  double _nutrientB = 0.0;

  // Actuator States
  bool _isPumpOn = false;
  bool _isGrowLightOn = false;
  bool _isPhUpPumpOn = false;
  bool _isPhDownPumpOn = false;
  bool _isNutrientAPumpOn = false;
  bool _isNutrientBPumpOn = false;

  String _lastError = '';
  int _reconnectAttempts = 0;

  // ============================================
  // Getters
  // ============================================
  AppMqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == AppMqttConnectionState.connected;
  bool get isConnecting =>
      _connectionState == AppMqttConnectionState.connecting;
  bool get isDisconnected =>
      _connectionState == AppMqttConnectionState.disconnected;
  bool get hasError => _connectionState == AppMqttConnectionState.error;
  String get lastError => _lastError;
  int get reconnectAttempts => _reconnectAttempts;

  // Sensor Getters
  double get temperature => _temperature;
  double get humidity => _humidity;
  double get moistureLevel => _moistureLevel;
  double get lightLevel => _lightLevel;
  double get phLevel => _phLevel;
  double get nutrientA => _nutrientA;
  double get nutrientB => _nutrientB;

  // Actuator Getters
  bool get isPumpOn => _isPumpOn;
  bool get isGrowLightOn => _isGrowLightOn;
  bool get isPhUpPumpOn => _isPhUpPumpOn;
  bool get isPhDownPumpOn => _isPhDownPumpOn;
  bool get isNutrientAPumpOn => _isNutrientAPumpOn;
  bool get isNutrientBPumpOn => _isNutrientBPumpOn;

  // ============================================
  // Connect Method (Simple!)
  // ============================================
  Future<void> connect() async {
    if (_connectionState == AppMqttConnectionState.connecting) {
      debugPrint('⚠️ Already connecting...');
      return;
    }

    try {
      _connectionState = AppMqttConnectionState.connecting;
      notifyListeners();

      // ✅ Simple setup like your example
      client = MqttServerClient(
        AppConstants.mqttBrokerUrl,
        AppConstants.mqttClientId,
      );
      client.port = AppConstants.mqttPort;
      client.keepAlivePeriod = 60;
      client.logging(on: false); // ✅ Disable logging

      debugPrint('🔌 Connecting to ${AppConstants.mqttBrokerUrl}...');

      // ✅ Simple connect
      await client.connect();

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _connectionState = AppMqttConnectionState.connected;
        _reconnectAttempts = 0;
        debugPrint('✅ Connected!');

        // Subscribe to topics
        _subscribeToTopics();

        // Listen to messages
        _setupListener();

        notifyListeners();
      } else {
        throw Exception('Connection failed');
      }
    } catch (e) {
      _connectionState = AppMqttConnectionState.error;
      _lastError = e.toString();
      debugPrint('❌ Error: $e');
      notifyListeners();

      // Simple retry
      _reconnectAttempts++;
      if (_reconnectAttempts < AppConstants.maxReconnectAttempts) {
        debugPrint(
            '🔄 Retrying in 5s... ($_reconnectAttempts/${AppConstants.maxReconnectAttempts})');
        Future.delayed(const Duration(seconds: 5), connect);
      }
    }
  }

  // ============================================
  // Subscribe to Topics
  // ============================================
  void _subscribeToTopics() {
    debugPrint('📡 Subscribing to topics...');

    client.subscribe(AppConstants.topicTemperature, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicHumidity, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicMoisture, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicLight, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPH, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientA, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientB, MqttQos.atMostOnce);

    client.subscribe(AppConstants.topicPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicGrowLightStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhUpPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhDownPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientAPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientBPumpStatus, MqttQos.atMostOnce);

    debugPrint('✅ Subscribed to all topics');
  }

  // ============================================
  // Listen to Messages (Simple!)
  // ============================================
  void _setupListener() {
    client.updates?.listen((messages) {
      final message = messages[0];
      final payload = message.payload as MqttPublishMessage;
      final topic = message.topic;
      final value = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );

      debugPrint('📨 $topic = $value');

      // Parse message
      _handleMessage(topic, value);
    });
  }

  // ============================================
  // Handle Incoming Messages
  // ============================================
  void _handleMessage(String topic, String value) {
    try {
      switch (topic) {
        case AppConstants.topicTemperature:
          _temperature = double.parse(value);
          break;
        case AppConstants.topicHumidity:
          _humidity = double.parse(value);
          break;
        case AppConstants.topicMoisture:
          _moistureLevel = double.parse(value);
          break;
        case AppConstants.topicLight:
          _lightLevel = double.parse(value);
          break;
        case AppConstants.topicPH:
          _phLevel = double.parse(value);
          break;
        case AppConstants.topicNutrientA:
          _nutrientA = double.parse(value);
          break;
        case AppConstants.topicNutrientB:
          _nutrientB = double.parse(value);
          break;

        case AppConstants.topicPumpStatus:
          _isPumpOn = value == '1' || value.toLowerCase() == 'true';
          break;
        case AppConstants.topicGrowLightStatus:
          _isGrowLightOn = value == '1' || value.toLowerCase() == 'true';
          break;
        case AppConstants.topicPhUpPumpStatus:
          _isPhUpPumpOn = value == '1' || value.toLowerCase() == 'true';
          break;
        case AppConstants.topicPhDownPumpStatus:
          _isPhDownPumpOn = value == '1' || value.toLowerCase() == 'true';
          break;
        case AppConstants.topicNutrientAPumpStatus:
          _isNutrientAPumpOn = value == '1' || value.toLowerCase() == 'true';
          break;
        case AppConstants.topicNutrientBPumpStatus:
          _isNutrientBPumpOn = value == '1' || value.toLowerCase() == 'true';
          break;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Parse error: $e');
    }
  }

  // ============================================
  // Publish Messages (Simple!)
  // ============================================
  void publish(String topic, String message) {
    if (!isConnected) {
      debugPrint('⚠️ Not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    debugPrint('📤 Published: $topic = $message');
  }

  // Control Methods
  void setPump(bool status) => publish(
        AppConstants.topicPumpControl,
        status ? '1' : '0',
      );

  void setGrowLight(bool status) => publish(
        AppConstants.topicGrowLightControl,
        status ? '1' : '0',
      );

  void setPhUpPump(bool status) => publish(
        AppConstants.topicPhUpPumpControl,
        status ? '1' : '0',
      );

  void setPhDownPump(bool status) => publish(
        AppConstants.topicPhDownPumpControl,
        status ? '1' : '0',
      );

  void setNutrientAPump(bool status) => publish(
        AppConstants.topicNutrientAPumpControl,
        status ? '1' : '0',
      );

  void setNutrientBPump(bool status) => publish(
        AppConstants.topicNutrientBPumpControl,
        status ? '1' : '0',
      );

  // ============================================
  // Disconnect
  // ============================================
  void disconnect() {
    client.disconnect();
    _connectionState = AppMqttConnectionState.disconnected;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
