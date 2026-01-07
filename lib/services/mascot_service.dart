import 'package:flutter/foundation.dart';
import '../models/mascot_state.dart';

/// Service untuk menentukan state Tumu berdasarkan sensor data
class MascotService extends ChangeNotifier {
  MascotState _currentState = MascotState.normal;

  MascotState get currentState => _currentState;

  /// ✅ Update state berdasarkan sensor data
  void updateState({
    required double temperature,
    required double phValue,
    required double nutrientLevel,
    required double waterLevel,
    required bool isConnected,
  }) {
    debugPrint('');
    debugPrint('🎯 [MASCOT] updateState called:');
    debugPrint('   Temperature: $temperature°C');
    debugPrint('   pH: $phValue');
    debugPrint('   TDS: $nutrientLevel ppm');
    debugPrint('   Water Level: $waterLevel%');
    debugPrint('   MQTT Connected: $isConnected');
    debugPrint('   Current State: ${_currentState.name}');

    MascotState newState;

    // ✅ PRIORITY ORDER
    if (!isConnected) {
      newState = MascotState.noSignal;
      debugPrint('   → Decision: noSignal (MQTT disconnected)');
    } else if (waterLevel < 20) {
      newState = MascotState.lowLevelWater;
      debugPrint('   → Decision: lowLevelWater (water: $waterLevel%)');
    } else if (waterLevel >= 90) {
      newState = MascotState.highLevelWater;
      debugPrint('   → Decision: highLevelWater (water: $waterLevel%)');
    } else if (phValue < 5.5 || phValue > 7.5) {
      newState = MascotState.unstablePh;
      debugPrint('   → Decision: unstablePh (pH: $phValue)');
    } else if (temperature > 32) {
      newState = MascotState.highTemperature;
      debugPrint('   → Decision: highTemperature (temp: $temperature°C)');
    } else if (temperature < 18) {
      newState = MascotState.lowTemperature;
      debugPrint('   → Decision: lowTemperature (temp: $temperature°C)');
    } else if (nutrientLevel < 800) {
      newState = MascotState.lowNutrient;
      debugPrint('   → Decision: lowNutrient (TDS: $nutrientLevel ppm)');
    } else {
      newState = MascotState.normal;
      debugPrint('   → Decision: normal (all optimal)');
    }

    // ✅ Notify if changed
    if (_currentState != newState) {
      debugPrint(
          '🔄 [MASCOT] State CHANGED: ${_currentState.name} → ${newState.name}');
      _currentState = newState;
      notifyListeners();
    } else {
      debugPrint('✅ [MASCOT] State UNCHANGED: ${newState.name}');
    }
    debugPrint('');
  }

  /// ✅ Force set state (untuk testing manual)
  void setState(MascotState state) {
    if (_currentState != state) {
      debugPrint('🎯 [MASCOT] Manual state set: ${state.name}');
      _currentState = state;
      notifyListeners();
    }
  }
}
