import 'package:flutter/material.dart';

/// Enum untuk state Tumu Mascot
enum MascotState {
  normal,
  highTemperature,
  lowTemperature,
  unstablePh,
  lowNutrient,
  lowLevelWater,
  highLevelWater,
  noSignal,
}

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

  String get message {
    switch (this) {
      case MascotState.normal:
        return 'Yeay, kondisi optimal! Tanaman tumbuh subur!';
      case MascotState.highTemperature:
        return 'Waduh, kepanasan nih! Ayo turunin suhunya!';
      case MascotState.lowTemperature:
        return 'Brrrr... kedinginan! Perlu penghangat nih!';
      case MascotState.unstablePh:
        return 'pH-ku gak stabil nih! Perlu penyesuaian!';
      case MascotState.lowNutrient:
        return 'Nutrisi kurang nih! Tambahin dong!';
      case MascotState.lowLevelWater:
        return 'Haus nih! Airnya kurang! Tolong isi ya!';
      case MascotState.highLevelWater:
        return 'Wah, airnya penuh! Siap untuk tumbuh!';
      case MascotState.noSignal:
        return 'Aduh, gak ada sinyal! Cek koneksi ya!';
    }
  }

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

  String get displayName {
    switch (this) {
      case MascotState.normal:
        return 'Normal';
      case MascotState.highTemperature:
        return 'Suhu Tinggi';
      case MascotState.lowTemperature:
        return 'Suhu Rendah';
      case MascotState.unstablePh:
        return 'pH Tidak Stabil';
      case MascotState.lowNutrient:
        return 'Nutrisi Rendah';
      case MascotState.lowLevelWater:
        return 'Air Rendah';
      case MascotState.highLevelWater:
        return 'Air Penuh';
      case MascotState.noSignal:
        return 'Tidak Terhubung';
    }
  }

  /// Apakah state ini memiliki aksi yang bisa di-trigger
  bool get hasAction {
    switch (this) {
      case MascotState.unstablePh:
      case MascotState.lowNutrient:
      case MascotState.lowLevelWater:
      case MascotState.highTemperature:
        return true;
      default:
        return false;
    }
  }

  /// Label untuk action button
  String get actionLabel {
    switch (this) {
      case MascotState.unstablePh:
        return 'Sesuaikan pH';
      case MascotState.lowNutrient:
        return 'Tambah Nutrisi';
      case MascotState.lowLevelWater:
        return 'Isi Air';
      case MascotState.highTemperature:
        return 'Nyalakan Kipas';
      default:
        return '';
    }
  }

  /// Icon untuk action button
  IconData get actionIcon {
    switch (this) {
      case MascotState.unstablePh:
        return Icons.science;
      case MascotState.lowNutrient:
        return Icons.water_drop;
      case MascotState.lowLevelWater:
        return Icons.water;
      case MascotState.highTemperature:
        return Icons.air;
      default:
        return Icons.touch_app;
    }
  }
}
