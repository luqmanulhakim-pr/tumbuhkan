import 'dart:async';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';
import '../config/constants.dart';

class MqttService extends ChangeNotifier {
  late MqttServerClient _client;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  int _retryCount = 0;
  static const int _maxRetries = 5;

  // Sensor Data
  double _temperature = 0.0;
  double _humidity = 0.0;
  double _lightLevel = 0.0;
  double _moistureLevel = 0.0;

  double get temperature => _temperature;
  double get humidity => _humidity;
  double get lightLevel => _lightLevel;
  double get moistureLevel => _moistureLevel;

  // Actuator States
  bool _isPumpOn = false;
  bool _isGrowLightOn = false;
  bool _isFanOn = false;

  bool get isPumpOn => _isPumpOn;
  bool get isGrowLightOn => _isGrowLightOn;
  bool get isFanOn => _isFanOn;

  final String _clientId =
      '${AppConstants.mqttClientIdPrefix}${DateTime.now().millisecondsSinceEpoch}';

  MqttService() {
    _initializeMqtt();
  }

  Future<void> _initializeMqtt() async {
    try {
      _client = MqttServerClient.withPort(
        AppConstants.mqttBrokerUrl,
        _clientId,
        AppConstants.mqttPort,
      );

      _client.logging(on: kDebugMode);
      _client.keepAlivePeriod = AppConstants.mqttKeepAlivePeriod;
      _client.connectTimeoutPeriod = 10000;
      _client.autoReconnect = true;
      _client.resubscribeOnAutoReconnect = true;
      _client.useWebSocket = false;
      _client.secure = false;
      _client.setProtocolV311();

      _client.onConnected = _onConnected;
      _client.onDisconnected = _onDisconnected;
      _client.onSubscribed = _onSubscribed;
      _client.onAutoReconnect = _onAutoReconnect;
      _client.onAutoReconnected = _onAutoReconnected;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client.connectionMessage = connMessage;

      debugPrint('🔌 Connecting to MQTT...');
      debugPrint(
          '📡 Broker: ${AppConstants.mqttBrokerUrl}:${AppConstants.mqttPort}');
      debugPrint('📱 Client ID: $_clientId');

      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _retryCount = 0;
      } else {
        _handleConnectionFailure();
      }
    } catch (e) {
      debugPrint('❌ MQTT Error: $e');
      _handleConnectionFailure();
    }
  }

  void _handleConnectionFailure() {
    _client.disconnect();
    _isConnected = false;
    notifyListeners();

    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('🔄 Retry $_retryCount/$_maxRetries in 5s...');

      Future.delayed(AppConstants.mqttReconnectDelay, () {
        _initializeMqtt();
      });
    } else {
      debugPrint('❌ Max retries reached!');
    }
  }

  void _onConnected() {
    debugPrint('');
    debugPrint('✅ ═══════════════════════════════════════');
    debugPrint('✅ MQTT CONNECTED SUCCESSFULLY!');
    debugPrint('✅ ═══════════════════════════════════════');
    debugPrint('');

    _isConnected = true;
    _retryCount = 0;
    notifyListeners();

    _subscribeToTopics();
    _client.updates?.listen(_onMessage);
  }

  void _onDisconnected() {
    debugPrint('⚠️ MQTT Disconnected');
    _isConnected = false;
    notifyListeners();
  }

  void _onAutoReconnect() {
    debugPrint('🔄 Auto reconnecting...');
  }

  void _onAutoReconnected() {
    debugPrint('✅ Auto reconnected!');
    _isConnected = true;
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    debugPrint('📡 ✓ Subscribed: $topic');
  }

  void _subscribeToTopics() {
    try {
      // Subscribe to sensor topics
      _client.subscribe(AppConstants.topicTemperature, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicHumidity, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicLight, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicMoisture, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicDeviceStatus, MqttQos.atLeastOnce);

      // 🔥 Subscribe to actuator STATUS topics (untuk feedback dari hardware)
      _client.subscribe(AppConstants.topicPumpStatus, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicGrowLightStatus, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicFanStatus, MqttQos.atLeastOnce);

      // 🆕 PENTING: Subscribe juga ke CONTROL topics (untuk sync dari MQTT Box)
      _client.subscribe(AppConstants.topicPump, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicGrowLight, MqttQos.atLeastOnce);
      _client.subscribe(AppConstants.topicFan, MqttQos.atLeastOnce);

      debugPrint('✅ Subscribed to ALL topics');
      debugPrint('📋 Total subscriptions: 11 topics');
      debugPrint('   - 4 sensor topics');
      debugPrint('   - 3 control topics (bidirectional)');
      debugPrint('   - 3 status topics');
      debugPrint('   - 1 device status');
    } catch (e) {
      debugPrint('❌ Subscribe error: $e');
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final topic = messages[0].topic;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    debugPrint('📩 $topic → $payload');

    try {
      // ============================================
      // Handle Sensor Data
      // ============================================
      if (topic == AppConstants.topicTemperature) {
        _temperature = double.tryParse(payload) ?? 0.0;
        notifyListeners();
      } else if (topic == AppConstants.topicHumidity) {
        _humidity = double.tryParse(payload) ?? 0.0;
        notifyListeners();
      } else if (topic == AppConstants.topicLight) {
        _lightLevel = double.tryParse(payload) ?? 0.0;
        notifyListeners();
      } else if (topic == AppConstants.topicMoisture) {
        _moistureLevel = double.tryParse(payload) ?? 0.0;
        notifyListeners();
      }

      // ============================================
      // 🔥 Handle Actuator CONTROL Topics (dari MQTT Box/External)
      // ============================================
      else if (topic == AppConstants.topicPump) {
        final newState = _parseStatusPayload(payload);
        if (_isPumpOn != newState) {
          _isPumpOn = newState;
          debugPrint(
              '💧 Pump updated from external: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      } else if (topic == AppConstants.topicGrowLight) {
        final newState = _parseStatusPayload(payload);
        if (_isGrowLightOn != newState) {
          _isGrowLightOn = newState;
          debugPrint(
              '💡 Light updated from external: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      } else if (topic == AppConstants.topicFan) {
        final newState = _parseStatusPayload(payload);
        if (_isFanOn != newState) {
          _isFanOn = newState;
          debugPrint(
              '🌀 Fan updated from external: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      }

      // ============================================
      // Handle Actuator STATUS Topics (feedback dari hardware)
      // ============================================
      else if (topic == AppConstants.topicPumpStatus) {
        final newState = _parseStatusPayload(payload);
        if (_isPumpOn != newState) {
          _isPumpOn = newState;
          debugPrint('💧 Pump status confirmed: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      } else if (topic == AppConstants.topicGrowLightStatus) {
        final newState = _parseStatusPayload(payload);
        if (_isGrowLightOn != newState) {
          _isGrowLightOn = newState;
          debugPrint('💡 Light status confirmed: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      } else if (topic == AppConstants.topicFanStatus) {
        final newState = _parseStatusPayload(payload);
        if (_isFanOn != newState) {
          _isFanOn = newState;
          debugPrint('🌀 Fan status confirmed: ${newState ? "ON" : "OFF"}');
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('❌ Parse error: $e');
    }
  }

  // Helper: Parse Status Payload
  // Support: ON/OFF, on/off, 1/0, true/false
  bool _parseStatusPayload(String payload) {
    final normalized = payload.trim().toUpperCase();
    return normalized == 'ON' || normalized == '1' || normalized == 'TRUE';
  }

  void publishMessage(String topic, String message) {
    if (!_isConnected) {
      debugPrint('⚠️ Cannot publish: Not connected');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      debugPrint('📤 $topic → $message');
    } catch (e) {
      debugPrint('❌ Publish error: $e');
    }
  }

  // ============================================
  // Actuator Control Methods
  // ============================================

  void togglePump() {
    final newState = !_isPumpOn;
    publishMessage(AppConstants.topicPump, newState ? 'ON' : 'OFF');
  }

  void setPump(bool state) {
    publishMessage(AppConstants.topicPump, state ? 'ON' : 'OFF');
  }

  void toggleGrowLight() {
    final newState = !_isGrowLightOn;
    publishMessage(AppConstants.topicGrowLight, newState ? 'ON' : 'OFF');
  }

  void setGrowLight(bool state) {
    publishMessage(AppConstants.topicGrowLight, state ? 'ON' : 'OFF');
  }

  void toggleFan() {
    final newState = !_isFanOn;
    publishMessage(AppConstants.topicFan, newState ? 'ON' : 'OFF');
  }

  void setFan(bool state) {
    publishMessage(AppConstants.topicFan, state ? 'ON' : 'OFF');
  }

  // Backward compatibility
  void controlPump(bool turnOn) => setPump(turnOn);
  void controlGrowLight(bool turnOn) => setGrowLight(turnOn);
  void controlFan(bool turnOn) => setFan(turnOn);

  Future<void> reconnect() async {
    debugPrint('🔄 Manual reconnect');
    disconnect();
    _retryCount = 0;
    await Future.delayed(const Duration(seconds: 1));
    await _initializeMqtt();
  }

  void disconnect() {
    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.disconnect();
      debugPrint('🔌 Disconnected');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
