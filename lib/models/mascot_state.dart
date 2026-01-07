import 'package:flutter/material.dart';

/// Enum untuk state Tumu Mascot
enum MascotState {
  normal,
  highTemperature,
  lowTemperature,
  unstablePh,
  lowNutrient,
  lowLevelWater, // 🆕 NEW
  highLevelWater, // 🆕 NEW
  noSignal, // 🆕 NEW
}

/// ✅ Extension untuk mendapatkan properties dari MascotState
extension MascotStateExtension on MascotState {
  /// Rive input name (sesuai dengan State Machine di Rive)
  String get riveInputName {
    switch (this) {
      case MascotState.normal:
        return 'Normal';
      case MascotState.highTemperature:
        return 'High Temperature';
      case MascotState.lowTemperature:
        return 'Low Temperature';
      case MascotState.unstablePh:
        return 'Unstable Ph';
      case MascotState.lowNutrient:
        return 'Low Nutrient';
      case MascotState.lowLevelWater:
        return 'Low Level Water';
      case MascotState.highLevelWater:
        return 'High Level Water';
      case MascotState.noSignal:
        return 'No Signal';
    }
  }

  /// ✅ Chat bubble message
  String get message {
    switch (this) {
      case MascotState.normal:
        return 'Yeay, kondisi optimal! 😊\nTanamanmu sehat!';
      case MascotState.highTemperature:
        return 'Waduh, kepanasan nih! 🔥😎\nAyo turunin suhunya!';
      case MascotState.lowTemperature:
        return 'Brrrr... kedinginan! 🥶❄️\nNaikin suhu dong!';
      case MascotState.unstablePh:
        return 'pH-ku gak stabil nih! 😵💫\nCek larutan nutrisi ya!';
      case MascotState.lowNutrient:
        return 'Nutrisi kurang nih! 😟💛\nTambah nutrisi dong!';
      case MascotState.lowLevelWater:
        return 'Air hampir habis! 💧😰\nSegera isi ulang ya!';
      case MascotState.highLevelWater:
        return 'Wah, airnya penuh! 💧😊\nSiap untuk tumbuh!';
      case MascotState.noSignal:
        return 'Aduh, gak ada sinyal! 📡❌\nCek koneksi sensor!';
    }
  }

  /// ✅ Chat bubble background color
  Color get color {
    switch (this) {
      case MascotState.normal:
        return const Color(0xFF4CAF50); // Green
      case MascotState.highTemperature:
        return const Color(0xFFFF5722); // Orange/Red
      case MascotState.lowTemperature:
        return const Color(0xFF2196F3); // Blue
      case MascotState.unstablePh:
        return const Color(0xFF9C27B0); // Purple
      case MascotState.lowNutrient:
        return const Color(0xFFFFC107); // Yellow
      case MascotState.lowLevelWater:
        return const Color(0xFFF44336); // Red (critical)
      case MascotState.highLevelWater:
        return const Color(0xFF00BCD4); // Cyan (full)
      case MascotState.noSignal:
        return const Color(0xFF757575); // Gray (disconnected)
    }
  }

  /// ✅ Emoji representation
  String get emoji {
    switch (this) {
      case MascotState.normal:
        return '😊';
      case MascotState.highTemperature:
        return '🔥😎';
      case MascotState.lowTemperature:
        return '🥶❄️';
      case MascotState.unstablePh:
        return '😵💫';
      case MascotState.lowNutrient:
        return '😟💛';
      case MascotState.lowLevelWater:
        return '💧😰';
      case MascotState.highLevelWater:
        return '💧😊';
      case MascotState.noSignal:
        return '📡❌';
    }
  }

  /// ✅ State name (for debugging)
  String get displayName {
    switch (this) {
      case MascotState.normal:
        return 'Normal';
      case MascotState.highTemperature:
        return 'High Temperature';
      case MascotState.lowTemperature:
        return 'Low Temperature';
      case MascotState.unstablePh:
        return 'Unstable pH';
      case MascotState.lowNutrient:
        return 'Low Nutrient';
      case MascotState.lowLevelWater:
        return 'Low Water Level';
      case MascotState.highLevelWater:
        return 'High Water Level';
      case MascotState.noSignal:
        return 'No Signal';
    }
  }
}
