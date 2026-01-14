import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/settings_model.dart';

class SettingsService extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';

  AppSettings _settings = AppSettings.defaultSettings();

  AppSettings get settings => _settings;

  // Getters untuk akses cepat
  String get flaskIpAddress => _settings.flaskIpAddress;
  int get flaskPort => _settings.flaskPort;
  String get esp32CamIpAddress => _settings.esp32CamIpAddress;
  int get esp32CamPort => _settings.esp32CamPort;
  bool get useEsp32CamForStream => _settings.useEsp32CamForStream;

  // URLs
  String get flaskBaseUrl => _settings.flaskBaseUrl;
  String get flaskStreamUrl => _settings.flaskStreamUrl;
  String get flaskUploadUrl => _settings.flaskUploadUrl;
  String get flaskUploadGrowthUrl => _settings.flaskUploadGrowthUrl;
  String get esp32CamBaseUrl => _settings.esp32CamBaseUrl;
  String get esp32CamStreamUrl => _settings.esp32CamStreamUrl;
  String get streamUrl => _settings.streamUrl; // Dynamic

  // ============================================
  // Load Settings from Storage
  // ============================================
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        _settings = AppSettings.fromJson(json);
        debugPrint('✅ Settings loaded: ${_settings.toJson()}');
      } else {
        _settings = AppSettings.defaultSettings();
        debugPrint('ℹ️  No saved settings, using defaults');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
      _settings = AppSettings.defaultSettings();
      notifyListeners();
    }
  }

  // ============================================
  // Save Settings to Storage
  // ============================================
  Future<void> saveSettings(AppSettings newSettings) async {
    try {
      _settings = newSettings;

      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_settings.toJson());
      await prefs.setString(_settingsKey, jsonString);

      debugPrint('✅ Settings saved: ${_settings.toJson()}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
      rethrow;
    }
  }

  // ============================================
  // Update Individual Settings
  // ============================================
  Future<void> updateFlaskIp(String ip, int port) async {
    final newSettings = _settings.copyWith(
      flaskIpAddress: ip,
      flaskPort: port,
    );
    await saveSettings(newSettings);
  }

  Future<void> updateEsp32CamIp(String ip, int port) async {
    final newSettings = _settings.copyWith(
      esp32CamIpAddress: ip,
      esp32CamPort: port,
    );
    await saveSettings(newSettings);
  }

  Future<void> toggleStreamSource(bool useEsp32Cam) async {
    final newSettings = _settings.copyWith(
      useEsp32CamForStream: useEsp32Cam,
    );
    await saveSettings(newSettings);
  }

  // ============================================
  // Reset to Defaults
  // ============================================
  Future<void> resetToDefaults() async {
    await saveSettings(AppSettings.defaultSettings());
  }
}
