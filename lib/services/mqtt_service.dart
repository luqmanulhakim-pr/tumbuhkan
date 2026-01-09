import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/constants.dart';
import 'mqtt_connection_state.dart';
import 'mascot_service.dart';

// ============================================
// Properties (✅ UPDATED - Add new fields)
// ============================================
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

  // ✅ NEW: Add pH voltage field
  double _phVoltage = 0.0;
  double _tdsVoltage = 0.0;

  // ✅ NEW: Label fields from backend
  String _phLabel = 'Unknown';
  String _tdsLabel = 'Unknown';
  String _ambientLabel = 'Unknown';
  String _lightLabel = 'Unknown';
  String _status = 'Unknown';
  String _timestamp = '';

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

  // Mascot Service
  MascotService? _mascotService;

  // Getters
  double get ph => _ph;
  double get tds => _tds;
  double get waterFlow => _waterFlow;
  double get flow => _waterFlow; // Alias
  double get airHumidity => _airHumidity;
  double get airTemperature => _airTemperature;
  double get ldrValue => _ldrValue;
  int get ldr => _ldrValue.toInt(); // Alias
  double get waterTemperature => _waterTemperature;
  double get waterLevel => _waterLevel;

  // ✅ NEW: Add voltage getters
  double get phVoltage => _phVoltage;
  double get tdsVoltage => _tdsVoltage;

  // ✅ NEW Getters
  String get phLabel => _phLabel;
  String get tdsLabel => _tdsLabel;
  String get ambientLabel => _ambientLabel;
  String get lightLabel => _lightLabel;
  String get status => _status;
  String get timestamp => _timestamp;

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
        rethrow;
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
            '🔄 Mencoba lagi dalam ${AppConstants.reconnectDelay.inSeconds} detik... ($_reconnectAttempts/${AppConstants.maxReconnectAttempts})');
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

  // Subscribe Topics (ESP32 Format)
  // ============================================
  void _subscribeToTopics() {
    debugPrint('📡 Berlangganan ke topic MQTT...');

    // Sensor data topic
    client.subscribe(AppConstants.topicSensorData, MqttQos.atMostOnce);
    debugPrint('  ✓ Subscribed: ${AppConstants.topicSensorData}');

    // Relay status topic (single JSON topic from ESP32)
    client.subscribe(AppConstants.topicRelayStatus, MqttQos.atMostOnce);
    debugPrint('  ✓ Subscribed: ${AppConstants.topicRelayStatus}');

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
  // Handle Message (ESP32 Format)
  // ============================================
  void _handleMessage(String topic, String value) {
    _lastMessageTime = DateTime.now();

    try {
      if (topic == AppConstants.topicSensorData) {
        _handleSensorData(value);
        return;
      }

      // Handle relay status JSON from ESP32
      // Format: {"LED":"ON","FAN":"OFF","PH_UP":"OFF","AB_MIX":"OFF","PH_DOWN":"OFF","PUMP":"OFF"}
      if (topic == AppConstants.topicRelayStatus) {
        _handleRelayStatus(value);
        return;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error parsing message: $e');
    }
  }

  // ============================================
  // Handle Relay Status JSON from ESP32
  // ============================================
  void _handleRelayStatus(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      _isGrowLightOn = data[AppConstants.relayLed] == 'ON';
      _isPumpOn = data[AppConstants.relayPump] == 'ON';
      _isPhUpPumpOn = data[AppConstants.relayPhUp] == 'ON';
      _isPhDownPumpOn = data[AppConstants.relayPhDown] == 'ON';
      _isNutrientAPumpOn = data[AppConstants.relayAbMix] == 'ON';
      _isNutrientBPumpOn =
          data[AppConstants.relayAbMix] == 'ON'; // Same as A for AB_MIX

      debugPrint('═══════════════════════════════════════');
      debugPrint('🔌 RELAY STATUS UPDATED');
      debugPrint('═══════════════════════════════════════');
      debugPrint('💡 LED       : ${_isGrowLightOn ? "ON" : "OFF"}');
      debugPrint('💧 PUMP      : ${_isPumpOn ? "ON" : "OFF"}');
      debugPrint('⬆️  PH_UP     : ${_isPhUpPumpOn ? "ON" : "OFF"}');
      debugPrint('⬇️  PH_DOWN   : ${_isPhDownPumpOn ? "ON" : "OFF"}');
      debugPrint('🧪 AB_MIX    : ${_isNutrientAPumpOn ? "ON" : "OFF"}');
      debugPrint('═══════════════════════════════════════');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error parsing relay status: $e');
    }
  }

  // ============================================
  // Parse JSON Sensor Data (ESP32 Format)
  // ============================================
  void _handleSensorData(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      _ph = _parseDouble(data['ph']);
      _tds = _parseDouble(data['tds']);
      _waterTemperature = _parseDouble(data['temp_air']);
      _airTemperature = _parseDouble(data['temp_udara']);
      _airHumidity = _parseDouble(data['humidity']);
      _ldrValue = _parseDouble(data['ldr']);
      _waterLevel = _parseDouble(data['distance']);
      _waterFlow = _parseDouble(data['flow']);

      // ✅ NEW: Parse voltage values
      _phVoltage = _parseDouble(data['ph_voltage']);
      _tdsVoltage = _parseDouble(data['tds_voltage']);

      // Calculate labels based on values
      _phLabel = _getPhLabel(_ph);
      _tdsLabel = _getTdsLabel(_tds);
      _lightLabel = _getLightLabel(_ldrValue);
      _ambientLabel = _getAmbientLabel(_airTemperature, _airHumidity);
      _status = 'Connected';
      _timestamp = DateTime.now().toIso8601String();

      debugPrint('═══════════════════════════════════════');
      debugPrint('📊 SENSOR DATA UPDATED (ESP32)');
      debugPrint('═══════════════════════════════════════');
      debugPrint('🧪 pH           : ${_ph.toStringAsFixed(2)} ($_phLabel)');
      debugPrint('   pH Voltage   : ${_phVoltage.toStringAsFixed(4)}V');
      debugPrint(
          '💛 TDS          : ${_tds.toStringAsFixed(2)} ppm ($_tdsLabel)');
      debugPrint('   TDS Voltage  : ${_tdsVoltage.toStringAsFixed(5)}V');
      debugPrint('🌡️  Air Temp     : ${_airTemperature.toStringAsFixed(1)}°C');
      debugPrint('💦 Water Temp   : ${_waterTemperature.toStringAsFixed(1)}°C');
      debugPrint('💧 Humidity     : ${_airHumidity.toStringAsFixed(0)}%');
      debugPrint(
          '☀️  LDR          : ${_ldrValue.toStringAsFixed(0)} ($_lightLabel)');
      debugPrint('📏 Distance     : ${_waterLevel.toStringAsFixed(1)} cm');
      debugPrint('💧 Water Flow   : ${_waterFlow.toStringAsFixed(2)} L/min');
      debugPrint('═══════════════════════════════════════');

      // Notify listeners
      notifyListeners();

      // Update mascot state
      if (_mascotService != null) {
        Future.microtask(() {
          if (_mascotService != null) {
            _mascotService!.updateState(
              temperature: _airTemperature,
              phValue: _ph,
              nutrientLevel: _tds,
              waterLevel: _waterLevel,
              isConnected: _connectionState == AppMqttConnectionState.connected,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [MQTT] Error parsing sensor JSON: $e');
      debugPrint('📄 Raw payload: $jsonString');
    }
  }

  // Helper methods for labels
  String _getPhLabel(double ph) {
    if (ph < 0) return 'Invalid';
    if (ph < 5.5) return 'Asam';
    if (ph > 7.5) return 'Basa';
    return 'Optimal';
  }

  String _getTdsLabel(double tds) {
    if (tds < 500) return 'Rendah';
    if (tds > 2000) return 'Tinggi';
    return 'Optimal';
  }

  String _getLightLabel(double ldr) {
    if (ldr < 500) return 'Gelap';
    if (ldr < 2000) return 'Redup';
    return 'Terang';
  }

  String _getAmbientLabel(double temp, double humidity) {
    if (temp > 32) return 'Panas';
    if (temp < 18) return 'Dingin';
    if (humidity > 80) return 'Lembab';
    if (humidity < 40) return 'Kering';
    return 'Normal';
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
  // Publish Methods
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

  // ============================================
  // Actuator Control Methods (ESP32 JSON Format)
  // ============================================

  /// Publish relay control command to ESP32
  /// For LED/FAN: uses state "ON"/"OFF"
  /// For PUMP/PH_UP/PH_DOWN/AB_MIX: uses duration in ms
  void _publishRelayCommand(String relayName,
      {int? durationMs, String? state}) {
    final Map<String, dynamic> payload = {};

    if (state != null) {
      // LED/FAN use state
      payload[relayName] = {'state': state};
    } else if (durationMs != null) {
      // Relay pumps use duration
      payload[relayName] = {'duration': durationMs};
    }

    final jsonPayload = json.encode(payload);
    publish(AppConstants.topicRelayControl, jsonPayload);
    debugPrint('🔌 Relay command: $jsonPayload');
  }

  void setPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayPump,
          durationMs: AppConstants.defaultRelayDuration);
    }
    // Note: ESP32 will auto-turn off after duration.
    // If status == false, do nothing (let timer handle it)
  }

  void setGrowLight(bool status) {
    _publishRelayCommand(AppConstants.relayLed, state: status ? 'ON' : 'OFF');
  }

  void setPhUpPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayPhUp,
          durationMs: AppConstants.defaultRelayDuration);
    }
  }

  void setPhDownPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayPhDown,
          durationMs: AppConstants.defaultRelayDuration);
    }
  }

  void setNutrientAPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayAbMix,
          durationMs: AppConstants.defaultRelayDuration);
    }
  }

  void setNutrientBPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayAbMix,
          durationMs: AppConstants.defaultRelayDuration);
    }
  }

  /// Custom relay control with specific duration
  void setRelayWithDuration(String relayName, int durationMs) {
    _publishRelayCommand(relayName, durationMs: durationMs);
  }

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
  // Calibration Methods
  // ============================================

  /// Mengirim kalibrasi sensor pH dengan nilai voltase dari user
  void publishPhCalibration(double v4, double v7, double v9) {
    if (!isConnected) {
      debugPrint('⚠️ Gagal mengirim kalibrasi pH: MQTT Disconnected');
      return;
    }

    final calibrationData = jsonEncode({
      'v4': double.parse(v4.toStringAsFixed(4)),
      'v7': double.parse(v7.toStringAsFixed(4)),
      'v9': double.parse(v9.toStringAsFixed(4)),
    });

    publish(AppConstants.topicPhCalibration, calibrationData);
    debugPrint('📊 Mengirim kalibrasi pH: $calibrationData');
  }

  /// Mengirim kalibrasi sensor TDS dengan koefisien m dan c
  /// Rumus: TDS = m * voltage + c
  /// m = 500 / (V1000 - V500)
  /// c = 500 - m * V500
  void publishTdsCalibration(double m, double c) {
    if (!isConnected) {
      debugPrint('⚠️ Gagal mengirim kalibrasi TDS: MQTT Disconnected');
      return;
    }

    final calibrationData = jsonEncode({
      'm': double.parse(m.toStringAsFixed(2)),
      'c': double.parse(c.toStringAsFixed(2)),
    });

    publish(AppConstants.topicTdsCalibration, calibrationData);
    debugPrint('📊 Mengirim kalibrasi TDS: $calibrationData');
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

  // ============================================
  // ✅ FIXED: Connect Method dengan protocol yang benar
  // ============================================
  void setMascotService(MascotService mascotService) {
    _mascotService = mascotService;
    debugPrint('🔗 [MQTT] MascotService linked: ${mascotService.runtimeType}');
    debugPrint('   Current state: ${mascotService.currentState.name}');
  }
}
