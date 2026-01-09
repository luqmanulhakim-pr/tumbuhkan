import 'package:flutter/foundation.dart';
import '../models/mascot_state.dart';

/// Service untuk menentukan state Tumu berdasarkan sensor data
class MascotService extends ChangeNotifier {
  MascotState _currentState = MascotState.normal;

  // Track sensor values untuk menentukan aksi yang tepat
  double _lastPhValue = 7.0;
  double _lastTemperature = 25.0;
  double _lastNutrientLevel = 1000.0;
  double _lastWaterLevel = 50.0;

  MascotState get currentState => _currentState;

  // Getters untuk sensor values
  double get lastPhValue => _lastPhValue;
  double get lastTemperature => _lastTemperature;
  double get lastNutrientLevel => _lastNutrientLevel;
  double get lastWaterLevel => _lastWaterLevel;

  // Untuk menentukan apakah pH terlalu rendah atau tinggi
  bool get isPhLow => _lastPhValue < 5.5;
  bool get isPhHigh => _lastPhValue > 7.5;

  void updateState({
    required double temperature,
    required double phValue,
    required double nutrientLevel,
    required double waterLevel,
    required bool isConnected,
  }) {
    // Store values untuk aksi
    _lastPhValue = phValue;
    _lastTemperature = temperature;
    _lastNutrientLevel = nutrientLevel;
    _lastWaterLevel = waterLevel;

    MascotState newState;

    if (!isConnected) {
      newState = MascotState.noSignal;
    } else if (waterLevel < 20) {
      newState = MascotState.lowLevelWater;
    } else if (waterLevel >= 90) {
      newState = MascotState.highLevelWater;
    } else if (phValue < 5.5 || phValue > 7.5) {
      newState = MascotState.unstablePh;
    } else if (temperature > 32) {
      newState = MascotState.highTemperature;
    } else if (temperature < 18) {
      newState = MascotState.lowTemperature;
    } else if (nutrientLevel < 800) {
      newState = MascotState.lowNutrient;
    } else {
      newState = MascotState.normal;
    }

    if (_currentState != newState) {
      debugPrint('🌱 [Mascot] State changed: $_currentState -> $newState');
      _currentState = newState;
      notifyListeners();
    }
  }
}
