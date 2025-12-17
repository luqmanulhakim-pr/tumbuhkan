import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/settings_model.dart';

class SettingsService extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';

  AppSettings _settings = AppSettings.defaultSettings();
  bool _isLoading = false;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  // Getters for easy access
  String get flaskBaseUrl => _settings.flaskBaseUrl;
  String get flaskStreamUrl => _settings.flaskStreamUrl;
  String get flaskUploadUrl => _settings.flaskUploadUrl;
  String get flaskImagesUrl => _settings.flaskImagesUrl;

  SettingsService() {
    loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = AppSettings.fromJson(json);
      } else {
        _settings = AppSettings.defaultSettings();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = AppSettings.defaultSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save settings to SharedPreferences
  Future<bool> saveSettings(AppSettings newSettings) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(newSettings.toJson());

      final success = await prefs.setString(_settingsKey, settingsJson);

      if (success) {
        _settings = newSettings;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update Flask IP
  Future<bool> updateFlaskIp(String ipAddress, {int port = 5000}) async {
    final newSettings = _settings.copyWith(
      flaskIpAddress: ipAddress,
      flaskPort: port,
    );
    return await saveSettings(newSettings);
  }

  // Reset to default
  Future<bool> resetToDefault() async {
    return await saveSettings(AppSettings.defaultSettings());
  }
}
