import 'dart:async';
import 'dart:convert';
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
  double _ph = 0.0;
  double _tds = 0.0;
  double _waterFlow = 0.0;
  double _airHumidity = 0.0;
  double _airTemperature = 0.0;
  double _ldrValue = 0.0;
  double _waterTemperature = 0.0;
  double _waterLevel = 0.0;
  String _waterStatus = 'Unknown';

  // Actuator States
  bool _isPumpOn = false;
  bool _isGrowLightOn = false;
  bool _isPhUpPumpOn = false;
  bool _isPhDownPumpOn = false;
  bool _isNutrientAPumpOn = false;
  bool _isNutrientBPumpOn = false;

  String _lastError = '';
  int _reconnectAttempts = 0;
  DateTime _lastMessageTime = DateTime.now();
  Timer? _heartbeatTimer;

  // Getters
  double get ph => _ph;
  double get tds => _tds;
  double get waterFlow => _waterFlow;
  double get airHumidity => _airHumidity;
  double get airTemperature => _airTemperature;
  double get ldrValue => _ldrValue;
  double get waterTemperature => _waterTemperature;
  double get waterLevel => _waterLevel;
  String get waterStatus => _waterStatus;

  AppMqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == AppMqttConnectionState.connected;
  bool get isConnecting =>
      _connectionState == AppMqttConnectionState.connecting;
  bool get isDisconnected =>
      _connectionState == AppMqttConnectionState.disconnected;
  bool get hasError => _connectionState == AppMqttConnectionState.error;
  String get lastError => _lastError;
  int get reconnectAttempts => _reconnectAttempts;

  bool get isPumpOn => _isPumpOn;
  bool get isGrowLightOn => _isGrowLightOn;
  bool get isPhUpPumpOn => _isPhUpPumpOn;
  bool get isPhDownPumpOn => _isPhDownPumpOn;
  bool get isNutrientAPumpOn => _isNutrientAPumpOn;
  bool get isNutrientBPumpOn => _isNutrientBPumpOn;

  // ============================================
  // ✅ FIXED: Connect Method dengan protocol yang benar
  // ============================================
  Future<void> connect() async {
    if (_connectionState == AppMqttConnectionState.connecting) {
      debugPrint('⏳ Sudah dalam proses koneksi...');
      return;
    }

    try {
      _connectionState = AppMqttConnectionState.connecting;
      notifyListeners();

      // Generate unique client ID
      final uniqueClientId =
          '${AppConstants.mqttClientId}_${DateTime.now().millisecondsSinceEpoch}';

      client = MqttServerClient(AppConstants.mqttBrokerUrl, uniqueClientId);
      client.port = AppConstants.mqttPort;
      client.keepAlivePeriod = AppConstants.mqttKeepAlive;
      client.logging(on: true);
      client.autoReconnect = true;

      // ✅ Set proper timeouts
      client.connectTimeoutPeriod = 10000; // 10 seconds

      debugPrint('🔌 Menghubungkan ke ${AppConstants.mqttBrokerUrl}...');
      debugPrint('   Client ID: $uniqueClientId');

      // ✅ FIXED: Use proper MQTT 3.1.1 protocol
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(uniqueClientId)
          .withWillTopic('tumbuhkan/status')
          .withWillMessage('Flutter client disconnected')
          .startClean() // Clean session
          .withWillQos(MqttQos.atLeastOnce);

      client.connectionMessage = connMessage;

      // ✅ Connect with proper error handling
      try {
        await client.connect();
      } on Exception catch (e) {
        debugPrint('❌ Connection exception: $e');
        client.disconnect();
        throw e;
      }

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _connectionState = AppMqttConnectionState.connected;
        _reconnectAttempts = 0;
        debugPrint('✅ Terhubung ke MQTT broker');
        debugPrint('   Return Code: ${client.connectionStatus?.returnCode}');

        _setupListener();
        await Future.delayed(const Duration(milliseconds: 500));
        _subscribeToTopics();
        _startHeartbeat();

        notifyListeners();
      } else {
        throw Exception('Koneksi gagal: ${client.connectionStatus?.state}\n'
            'Return Code: ${client.connectionStatus?.returnCode}');
      }
    } catch (e) {
      _connectionState = AppMqttConnectionState.error;
      _lastError = e.toString();
      debugPrint('❌ Error koneksi: $e');
      notifyListeners();

      _reconnectAttempts++;
      if (_reconnectAttempts < AppConstants.maxReconnectAttempts) {
        debugPrint(
            '🔄 Mencoba lagi dalam ${AppConstants.reconnectDelay.inSeconds} detik... (${_reconnectAttempts}/${AppConstants.maxReconnectAttempts})');
        Future.delayed(AppConstants.reconnectDelay, connect);
      } else {
        debugPrint('🚫 Batas maksimum percobaan koneksi tercapai');
      }
    }
  }

  // ============================================
  // Heartbeat Checker (tidak berubah)
  // ============================================
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (_) {
      final now = DateTime.now();
      final timeSinceLastMessage = now.difference(_lastMessageTime);

      if (timeSinceLastMessage > AppConstants.heartbeatTimeout) {
        debugPrint('💔 Heartbeat timeout - mencoba reconnect...');
        _connectionState = AppMqttConnectionState.error;
        _lastError = 'Tidak ada data dari sensor';
        notifyListeners();
        connect();
      }
    });
  }

  // ============================================
  // Subscribe Topics (tidak berubah)
  // ============================================
  void _subscribeToTopics() {
    debugPrint('📡 Berlangganan ke topic MQTT...');

    client.subscribe(AppConstants.topicSensorData, MqttQos.atMostOnce);
    debugPrint('  ✓ Subscribed: ${AppConstants.topicSensorData}');

    client.subscribe(AppConstants.topicPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicGrowLightStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhUpPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhDownPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientAPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientBPumpStatus, MqttQos.atMostOnce);

    debugPrint('✅ Berhasil subscribe ke semua topic');
  }

  // ============================================
  // Setup Listener (tidak berubah)
  // ============================================
  void _setupListener() {
    debugPrint('👂 Setting up MQTT listener...');

    client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message =
            messages[0].payload as MqttPublishMessage;
        final String topic = messages[0].topic;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        debugPrint('📨 Received: $topic -> $payload');
        _handleMessage(topic, payload);
      },
      onError: (error) {
        debugPrint('❌ MQTT stream error: $error');
        _connectionState = AppMqttConnectionState.error;
        _lastError = error.toString();
        notifyListeners();
      },
      onDone: () {
        debugPrint('🔌 MQTT stream closed');
        if (_connectionState == AppMqttConnectionState.connected) {
          connect();
        }
      },
    );

    debugPrint('✅ Listener setup complete');
  }

  // ============================================
  // Handle Message (tidak berubah)
  // ============================================
  void _handleMessage(String topic, String value) {
    _lastMessageTime = DateTime.now();

    try {
      if (topic == AppConstants.topicSensorData) {
        _handleSensorData(value);
        return;
      }

      switch (topic) {
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
      debugPrint('❌ Error parsing message: $e');
    }
  }

  // ============================================
  // ✅ UPDATED: Parse JSON Sensor Data (struktur baru)
  // ============================================
  void _handleSensorData(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      _ph = _parseDouble(data['ph']);
      _tds = _parseDouble(data['tds']);
      _waterFlow = _parseDouble(data['water_flow']);
      _airHumidity = _parseDouble(data['air_humidity']);
      _airTemperature = _parseDouble(data['air_temperature']);
      _ldrValue = _parseDouble(data['ldr_value']);
      _waterTemperature = _parseDouble(data['water_temperature']);
      _waterLevel = _parseDouble(data['water_level']);
      _waterStatus = data['status']?.toString() ?? 'Unknown';

      debugPrint(
          '📊 Data sensor updated: pH=${_ph.toStringAsFixed(2)}, TDS=${_tds.toStringAsFixed(0)}, Status=$_waterStatus');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error parsing JSON: $e');
    }
  }

  // ============================================
  // Helper Parse Double (tidak berubah)
  // ============================================
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ============================================
  // Publish Methods (tidak berubah)
  // ============================================
  void publish(String topic, String message) {
    if (!isConnected) {
      debugPrint('⚠️ Tidak dapat publish: Belum terhubung ke broker');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    debugPrint('📤 Published: $topic = $message');
  }

  void setPump(bool status) =>
      publish(AppConstants.topicPumpControl, status ? '1' : '0');
  void setGrowLight(bool status) =>
      publish(AppConstants.topicGrowLightControl, status ? '1' : '0');
  void setPhUpPump(bool status) =>
      publish(AppConstants.topicPhUpPumpControl, status ? '1' : '0');
  void setPhDownPump(bool status) =>
      publish(AppConstants.topicPhDownPumpControl, status ? '1' : '0');
  void setNutrientAPump(bool status) =>
      publish(AppConstants.topicNutrientAPumpControl, status ? '1' : '0');
  void setNutrientBPump(bool status) =>
      publish(AppConstants.topicNutrientBPumpControl, status ? '1' : '0');

  // ============================================
  // Camera Control Methods
  // ============================================

  /// Mengirim perintah CAPTURE untuk memicu analisis pertumbuhan tanaman
  void publishCaptureCommand() {
    if (!isConnected) {
      debugPrint('⚠️ Gagal mengirim perintah capture: MQTT Disconnected');
      return;
    }

    publish(AppConstants.topicCameraCapture, 'CAPTURE');
    debugPrint('📸 Mengirim perintah analisis pertumbuhan (CAPTURE)');
  }

  /// Mengirim status kamera
  void publishCameraStatus(String status) {
    if (!isConnected) return;
    publish(AppConstants.topicCameraStatus, status);
  }

  // ============================================
  // Execute Scheduled Action (tidak berubah)
  // ============================================
  Future<void> executeScheduledAction(
      String actuatorType, int durationSeconds) async {
    debugPrint('⏰ Executing: $actuatorType for $durationSeconds seconds');

    switch (actuatorType) {
      case 'pump':
        setPump(true);
        break;
      case 'growlight':
        setGrowLight(true);
        break;
      case 'ph_up':
        setPhUpPump(true);
        break;
      case 'ph_down':
        setPhDownPump(true);
        break;
      case 'nutrient_a':
        setNutrientAPump(true);
        break;
      case 'nutrient_b':
        setNutrientBPump(true);
        break;
    }

    await Future.delayed(Duration(seconds: durationSeconds));

    switch (actuatorType) {
      case 'pump':
        setPump(false);
        break;
      case 'growlight':
        setGrowLight(false);
        break;
      case 'ph_up':
        setPhUpPump(false);
        break;
      case 'ph_down':
        setPhDownPump(false);
        break;
      case 'nutrient_a':
        setNutrientAPump(false);
        break;
      case 'nutrient_b':
        setNutrientBPump(false);
        break;
    }

    debugPrint('✅ Schedule completed: $actuatorType');
  }

  // ============================================
  // Disconnect (tidak berubah)
  // ============================================
  void disconnect() {
    _heartbeatTimer?.cancel();
    client.disconnect();
    _connectionState = AppMqttConnectionState.disconnected;
    debugPrint('🔌 Terputus dari MQTT broker');
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    disconnect();
    super.dispose();
  }
}
