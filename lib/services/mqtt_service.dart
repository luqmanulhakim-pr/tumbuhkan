import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/constants.dart';
import 'mqtt_connection_state.dart';
import 'mascot_service.dart';

/// MQTT Service for managing broker connection and sensor data.
class MqttService extends ChangeNotifier {
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
  double _phVoltage = 0.0;
  double _tdsVoltage = 0.0;

  // Labels
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
  MascotService? _mascotService;

  // Getters - Sensor Data
  double get ph => _ph;
  double get tds => _tds;
  double get waterFlow => _waterFlow;
  double get flow => _waterFlow;
  double get airHumidity => _airHumidity;
  double get airTemperature => _airTemperature;
  double get ldrValue => _ldrValue;
  int get ldr => _ldrValue.toInt();
  double get waterTemperature => _waterTemperature;
  double get waterLevel => _waterLevel;
  double get phVoltage => _phVoltage;
  double get tdsVoltage => _tdsVoltage;

  // Getters - Labels
  String get phLabel => _phLabel;
  String get tdsLabel => _tdsLabel;
  String get ambientLabel => _ambientLabel;
  String get lightLabel => _lightLabel;
  String get status => _status;
  String get timestamp => _timestamp;

  // Getters - Connection
  AppMqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == AppMqttConnectionState.connected;
  bool get isConnecting =>
      _connectionState == AppMqttConnectionState.connecting;
  bool get isDisconnected =>
      _connectionState == AppMqttConnectionState.disconnected;
  bool get hasError => _connectionState == AppMqttConnectionState.error;
  String get lastError => _lastError;
  int get reconnectAttempts => _reconnectAttempts;

  // Getters - Actuators
  bool get isPumpOn => _isPumpOn;
  bool get isGrowLightOn => _isGrowLightOn;
  bool get isPhUpPumpOn => _isPhUpPumpOn;
  bool get isPhDownPumpOn => _isPhDownPumpOn;
  bool get isNutrientAPumpOn => _isNutrientAPumpOn;
  bool get isNutrientBPumpOn => _isNutrientBPumpOn;

  /// Connects to the MQTT broker.
  Future<void> connect() async {
    if (_connectionState == AppMqttConnectionState.connecting) return;

    try {
      _connectionState = AppMqttConnectionState.connecting;
      notifyListeners();

      final uniqueClientId =
          '${AppConstants.mqttClientId}_${DateTime.now().millisecondsSinceEpoch}';

      client = MqttServerClient(AppConstants.mqttBrokerUrl, uniqueClientId);
      client.port = AppConstants.mqttPort;
      client.keepAlivePeriod = AppConstants.mqttKeepAlive;
      client.logging(on: kDebugMode);
      client.autoReconnect = true;
      client.connectTimeoutPeriod = 10000;

      debugPrint('[MQTT] Connecting to ${AppConstants.mqttBrokerUrl}...');

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(uniqueClientId)
          .withWillTopic('tumbuhkan/status')
          .withWillMessage('Flutter client disconnected')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client.connectionMessage = connMessage;

      await client.connect();

      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _connectionState = AppMqttConnectionState.connected;
        _reconnectAttempts = 0;
        debugPrint('[MQTT] Connected successfully');

        _setupListener();
        await Future.delayed(const Duration(milliseconds: 500));
        _subscribeToTopics();
        _startHeartbeat();
        notifyListeners();
      } else {
        throw Exception('Connection failed: ${client.connectionStatus?.state}');
      }
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  void _handleConnectionError(dynamic error) {
    _connectionState = AppMqttConnectionState.error;
    _lastError = error.toString();
    debugPrint('[MQTT] Error: $error');
    notifyListeners();

    _reconnectAttempts++;
    if (_reconnectAttempts < AppConstants.maxReconnectAttempts) {
      debugPrint(
          '[MQTT] Retrying in ${AppConstants.reconnectDelay.inSeconds}s...');
      Future.delayed(AppConstants.reconnectDelay, connect);
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(AppConstants.heartbeatInterval, (_) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime);

      if (timeSinceLastMessage > AppConstants.heartbeatTimeout) {
        debugPrint('[MQTT] Heartbeat timeout, reconnecting...');
        _connectionState = AppMqttConnectionState.error;
        _lastError = 'No data from sensor';
        notifyListeners();
        connect();
      }
    });
  }

  void _subscribeToTopics() {
    client.subscribe(AppConstants.topicSensorData, MqttQos.atMostOnce);
    client.subscribe(AppConstants.topicRelayStatus, MqttQos.atMostOnce);
    debugPrint('[MQTT] Subscribed to topics');
  }

  void _setupListener() {
    client.updates?.listen(
      (List<MqttReceivedMessage<MqttMessage>> messages) {
        final message = messages[0].payload as MqttPublishMessage;
        final topic = messages[0].topic;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        _handleMessage(topic, payload);
      },
      onError: (error) {
        debugPrint('[MQTT] Stream error: $error');
        _connectionState = AppMqttConnectionState.error;
        _lastError = error.toString();
        notifyListeners();
      },
      onDone: () {
        if (_connectionState == AppMqttConnectionState.connected) {
          connect();
        }
      },
    );
  }

  void _handleMessage(String topic, String payload) {
    _lastMessageTime = DateTime.now();

    try {
      if (topic == AppConstants.topicSensorData) {
        _handleSensorData(payload);
      } else if (topic == AppConstants.topicRelayStatus) {
        _handleRelayStatus(payload);
      }
    } catch (e) {
      debugPrint('[MQTT] Parse error: $e');
    }
  }

  void _handleRelayStatus(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;

      _isGrowLightOn = data[AppConstants.relayLed] == 'ON';
      _isPumpOn = data[AppConstants.relayPump] == 'ON';
      _isPhUpPumpOn = data[AppConstants.relayPhUp] == 'ON';
      _isPhDownPumpOn = data[AppConstants.relayPhDown] == 'ON';
      _isNutrientAPumpOn = data[AppConstants.relayAbMix] == 'ON';
      _isNutrientBPumpOn = data[AppConstants.relayAbMix] == 'ON';

      notifyListeners();
    } catch (e) {
      debugPrint('[MQTT] Relay status parse error: $e');
    }
  }

  void _handleSensorData(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;

      _ph = _parseDouble(data['ph']);
      _tds = _parseDouble(data['tds']);
      _waterTemperature = _parseDouble(data['temp_air']);
      _airTemperature = _parseDouble(data['temp_udara']);
      _airHumidity = _parseDouble(data['humidity']);
      _ldrValue = _parseDouble(data['ldr']);
      _waterLevel = _parseDouble(data['distance']);
      _waterFlow = _parseDouble(data['flow']);
      _phVoltage = _parseDouble(data['ph_voltage']);
      _tdsVoltage = _parseDouble(data['tds_voltage']);

      _phLabel = _getPhLabel(_ph);
      _tdsLabel = _getTdsLabel(_tds);
      _lightLabel = _getLightLabel(_ldrValue);
      _ambientLabel = _getAmbientLabel(_airTemperature, _airHumidity);
      _status = 'Connected';
      _timestamp = DateTime.now().toIso8601String();

      notifyListeners();
      _updateMascotState();
    } catch (e) {
      debugPrint('[MQTT] Sensor data parse error: $e');
    }
  }

  void _updateMascotState() {
    if (_mascotService == null) return;

    Future.microtask(() {
      _mascotService?.updateState(
        temperature: _airTemperature,
        phValue: _ph,
        nutrientLevel: _tds,
        waterLevel: _waterLevel,
        isConnected: isConnected,
      );
    });
  }

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

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Publishes a message to the specified topic.
  void publish(String topic, String message) {
    if (!isConnected) {
      debugPrint('[MQTT] Cannot publish: not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  void _publishRelayCommand(String relayName,
      {int? durationMs, String? state}) {
    final payload = <String, dynamic>{};

    if (state != null) {
      payload[relayName] = {'state': state};
    } else if (durationMs != null) {
      payload[relayName] = {'duration': durationMs};
    }

    publish(AppConstants.topicRelayControl, json.encode(payload));
  }

  void setPump(bool status) {
    if (status) {
      _publishRelayCommand(AppConstants.relayPump,
          durationMs: AppConstants.defaultRelayDuration);
    }
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

  void setRelayWithDuration(String relayName, int durationMs) {
    _publishRelayCommand(relayName, durationMs: durationMs);
  }

  void publishCaptureCommand() {
    if (!isConnected) return;
    publish(AppConstants.topicCameraCapture, 'CAPTURE');
  }

  void publishCameraStatus(String status) {
    if (!isConnected) return;
    publish(AppConstants.topicCameraStatus, status);
  }

  void publishPhCalibration(double v4, double v7, double v9) {
    if (!isConnected) return;

    final calibrationData = jsonEncode({
      'v4': double.parse(v4.toStringAsFixed(4)),
      'v7': double.parse(v7.toStringAsFixed(4)),
      'v9': double.parse(v9.toStringAsFixed(4)),
    });

    publish(AppConstants.topicPhCalibration, calibrationData);
  }

  void publishTdsCalibration(double m, double c) {
    if (!isConnected) return;

    final calibrationData = jsonEncode({
      'm': double.parse(m.toStringAsFixed(2)),
      'c': double.parse(c.toStringAsFixed(2)),
    });

    publish(AppConstants.topicTdsCalibration, calibrationData);
  }

  Future<void> executeScheduledAction(
      String actuatorType, int durationSeconds) async {
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
  }

  void disconnect() {
    _heartbeatTimer?.cancel();
    client.disconnect();
    _connectionState = AppMqttConnectionState.disconnected;
    debugPrint('[MQTT] Disconnected');
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    disconnect();
    super.dispose();
  }

  void setMascotService(MascotService mascotService) {
    _mascotService = mascotService;
  }
}
