import 'dart:async';
import 'dart:convert'; // ✅ ADD: Import untuk JSON parsing
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
  double _nutrientPPM = 0.0;

  // Actuator States
  bool _isPumpOn = false;
  bool _isGrowLightOn = false;
  bool _isPhUpPumpOn = false;
  bool _isPhDownPumpOn = false;
  bool _isNutrientAPumpOn = false;
  bool _isNutrientBPumpOn = false;

  String _lastError = '';
  int _reconnectAttempts = 0;

  // ✅ NEW: Heartbeat tracking
  DateTime _lastMessageTime = DateTime.now();
  Timer? _heartbeatTimer;

  // ============================================
  // Getters (tidak berubah)
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
  double get nutrientPPM => _nutrientPPM;

  // Actuator Getters
  bool get isPumpOn => _isPumpOn;
  bool get isGrowLightOn => _isGrowLightOn;
  bool get isPhUpPumpOn => _isPhUpPumpOn;
  bool get isPhDownPumpOn => _isPhDownPumpOn;
  bool get isNutrientAPumpOn => _isNutrientAPumpOn;
  bool get isNutrientBPumpOn => _isNutrientBPumpOn;

  // ============================================
  // Connect Method
  // ============================================
  Future<void> connect() async {
    if (_connectionState == AppMqttConnectionState.connecting) {
      debugPrint('⏳ Sudah dalam proses koneksi...');
      return;
    }

    try {
      _connectionState = AppMqttConnectionState.connecting;
      notifyListeners();

      client = MqttServerClient(
        AppConstants.mqttBrokerUrl,
        AppConstants.mqttClientId,
      );
      client.port = AppConstants.mqttPort;
      client.keepAlivePeriod = AppConstants.mqttKeepAlive;
      client.logging(on: false);

      debugPrint('🔌 Menghubungkan ke ${AppConstants.mqttBrokerUrl}...');

      await client.connect();

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _connectionState = AppMqttConnectionState.connected;
        _reconnectAttempts = 0;
        debugPrint('✅ Terhubung ke MQTT broker');

        _subscribeToTopics();
        _setupListener();
        _startHeartbeat(); // ✅ NEW: Mulai heartbeat checker

        notifyListeners();
      } else {
        throw Exception('Koneksi gagal');
      }
    } catch (e) {
      _connectionState = AppMqttConnectionState.error;
      _lastError = e.toString();
      debugPrint('❌ Error koneksi: $e');
      notifyListeners();

      _reconnectAttempts++;
      if (_reconnectAttempts < AppConstants.maxReconnectAttempts) {
        debugPrint(
          '🔄 Mencoba lagi dalam ${AppConstants.reconnectDelay.inSeconds} detik... '
          '(Percobaan $_reconnectAttempts/${AppConstants.maxReconnectAttempts})',
        );
        Future.delayed(AppConstants.reconnectDelay, connect);
      } else {
        debugPrint('🚫 Batas maksimum percobaan koneksi tercapai');
      }
    }
  }

  // ============================================
  // ✅ NEW: Heartbeat Checker
  // ============================================
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (_) {
      final now = DateTime.now();
      final timeSinceLastMessage = now.difference(_lastMessageTime);

      // Jika tidak ada pesan dalam 2 menit, reconnect
      if (timeSinceLastMessage > AppConstants.heartbeatTimeout) {
        debugPrint('💔 Heartbeat timeout - mencoba reconnect...');
        _connectionState = AppMqttConnectionState.error;
        _lastError =
            'Tidak ada data dari sensor dalam ${AppConstants.heartbeatTimeout.inMinutes} menit';
        notifyListeners();
        connect();
      }
    });
  }

  // ============================================
  // ✅ MODIFIED: Subscribe ke 1 Topic Sensor + Topic Actuator
  // ============================================
  void _subscribeToTopics() {
    debugPrint('📡 Berlangganan ke topic MQTT...');

    // ✅ NEW: Subscribe ke single sensor topic
    client.subscribe(AppConstants.topicSensorData, MqttQos.atMostOnce);
    debugPrint('  ✓ ${AppConstants.topicSensorData}');

    // Actuator status topics (tidak berubah)
    client.subscribe(AppConstants.topicPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicGrowLightStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhUpPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicPhDownPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientAPumpStatus, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicNutrientBPumpStatus, MqttQos.atMostOnce);

    debugPrint('✅ Berhasil subscribe ke semua topic');
  }

  // ============================================
  // Listen to Messages (tidak berubah)
  // ============================================
  void _setupListener() {
    client.updates?.listen(
      (messages) {
        final message = messages[0];
        final payload = message.payload as MqttPublishMessage;
        final topic = message.topic;
        final value = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );

        debugPrint('📩 Received: $topic');

        _handleMessage(topic, value);
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
          connect(); // Auto-reconnect
        }
      },
    );
  }

  // ============================================
  // ✅ MODIFIED: Handle JSON Payload untuk Sensor
  // ============================================
  void _handleMessage(String topic, String value) {
    // ✅ Update waktu terakhir menerima pesan
    _lastMessageTime = DateTime.now();

    try {
      // ✅ NEW: Handle JSON sensor data
      if (topic == AppConstants.topicSensorData) {
        _handleSensorData(value);
        return;
      }

      // Handle actuator status (tidak berubah)
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
  // ✅ NEW: Parse JSON Sensor Data
  // ============================================
  void _handleSensorData(String jsonString) {
    try {
      final Map<String, dynamic> data = json.decode(jsonString);

      // Parse setiap field sensor
      _temperature = _parseDouble(data['temperature']);
      _humidity = _parseDouble(data['humidity']);
      _moistureLevel = _parseDouble(data['moisture']);
      _lightLevel = _parseDouble(data['light']);
      _phLevel = _parseDouble(data['ph']);
      _nutrientPPM = _parseDouble(data['ppm']);

      debugPrint('📊 Data sensor diperbarui:');
      debugPrint('   🌡️  Suhu: ${_temperature.toStringAsFixed(1)}°C');
      debugPrint('   💧 Kelembaban: ${_humidity.toStringAsFixed(1)}%');
      debugPrint(
          '   🌱 Kelembaban Tanah: ${_moistureLevel.toStringAsFixed(1)}%');
      debugPrint('   💡 Cahaya: ${_lightLevel.toStringAsFixed(0)} lux');
      debugPrint('   ⚗️  pH: ${_phLevel.toStringAsFixed(2)}');
      debugPrint('   🧪 PPM: ${_nutrientPPM.toStringAsFixed(0)}');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error parsing JSON sensor data: $e');
      debugPrint('   Payload: $jsonString');
    }
  }

  // ============================================
  // ✅ NEW: Helper untuk Parse Double Aman
  // ============================================
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // ============================================
  // Publish Messages (tidak berubah)
  // ============================================
  void publish(String topic, String message) {
    if (!isConnected) {
      debugPrint('⚠️  Tidak dapat publish: Belum terhubung ke broker');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    debugPrint('📤 Published: $topic = $message');
  }

  // ============================================
  // ✅ NEW: Publish dengan Konfirmasi (QoS 1)
  // ============================================
  Future<bool> publishWithConfirmation(String topic, String message) async {
    if (!isConnected) {
      debugPrint('⚠️  Tidak dapat publish: Belum terhubung ke broker');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(
        topic,
        MqttQos.atLeastOnce, // QoS 1 untuk konfirmasi
        builder.payload!,
      );
      debugPrint('✅ Published dengan konfirmasi: $topic = $message');
      return true;
    } catch (e) {
      debugPrint('❌ Publish gagal: $e');
      return false;
    }
  }

  // ============================================
  // Actuator Control Methods (tidak berubah)
  // ============================================
  void setPump(bool status) {
    publish(AppConstants.topicPumpControl, status ? '1' : '0');
    debugPrint('💧 ${status ? "Menyalakan" : "Mematikan"} pompa air');
  }

  void setGrowLight(bool status) {
    publish(AppConstants.topicGrowLightControl, status ? '1' : '0');
    debugPrint('💡 ${status ? "Menyalakan" : "Mematikan"} lampu grow');
  }

  void setPhUpPump(bool status) {
    publish(AppConstants.topicPhUpPumpControl, status ? '1' : '0');
    debugPrint('⬆️  ${status ? "Menyalakan" : "Mematikan"} pompa pH Up');
  }

  void setPhDownPump(bool status) {
    publish(AppConstants.topicPhDownPumpControl, status ? '1' : '0');
    debugPrint('⬇️  ${status ? "Menyalakan" : "Mematikan"} pompa pH Down');
  }

  void setNutrientAPump(bool status) {
    publish(AppConstants.topicNutrientAPumpControl, status ? '1' : '0');
    debugPrint('🧪 ${status ? "Menyalakan" : "Mematikan"} pompa Nutrisi A');
  }

  void setNutrientBPump(bool status) {
    publish(AppConstants.topicNutrientBPumpControl, status ? '1' : '0');
    debugPrint('🧪 ${status ? "Menyalakan" : "Mematikan"} pompa Nutrisi B');
  }

  // ============================================
  // ✅ NEW: Eksekusi Aksi Terjadwal (untuk ScheduleService)
  // ============================================
  Future<void> executeScheduledAction(
    String actuatorType,
    int durationSeconds,
  ) async {
    debugPrint(
        '⏰ Mengeksekusi jadwal: $actuatorType selama $durationSeconds detik');

    // Nyalakan aktuator
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

    // Tunggu durasi
    await Future.delayed(Duration(seconds: durationSeconds));

    // Matikan aktuator
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

    debugPrint('✅ Jadwal selesai dieksekusi: $actuatorType');
  }

  // ============================================
  // Disconnect
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
  // ✅ NEW: Camera Control
  // ============================================
  /// Mengirim perintah CAPTURE ke topic kamera
  /// Digunakan untuk trigger analisis pertumbuhan tanaman
  void publishCaptureCommand() {
    if (!isConnected) {
      debugPrint('⚠️ Gagal mengirim perintah capture: MQTT Disconnected');
      return;
    }

    publish(AppConstants.topicCameraCapture, 'CAPTURE');
    debugPrint('📸 Mengirim perintah analisis pertumbuhan (CAPTURE)');
  }
}
