/// Custom MQTT Connection State (renamed to avoid conflict with mqtt_client)
enum AppMqttConnectionState {
  /// Not connected
  disconnected,

  /// Attempting to connect
  connecting,

  /// Successfully connected
  connected,

  /// Connection error
  error,
}

extension AppMqttConnectionStateExtension on AppMqttConnectionState {
  String get displayName {
    switch (this) {
      case AppMqttConnectionState.disconnected:
        return 'Disconnected';
      case AppMqttConnectionState.connecting:
        return 'Connecting...';
      case AppMqttConnectionState.connected:
        return 'Connected';
      case AppMqttConnectionState.error:
        return 'Error';
    }
  }

  String get emoji {
    switch (this) {
      case AppMqttConnectionState.disconnected:
        return '⚫';
      case AppMqttConnectionState.connecting:
        return '🟡';
      case AppMqttConnectionState.connected:
        return '🟢';
      case AppMqttConnectionState.error:
        return '🔴';
    }
  }
}
