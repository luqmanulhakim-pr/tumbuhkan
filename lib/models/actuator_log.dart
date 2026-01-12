/// Model for actuator logs from PostgreSQL
class ActuatorLog {
  final int id;
  final DateTime timestamp;
  final String led;
  final String fan;
  final bool phUp;
  final bool abMix;
  final bool phDown;
  final bool pump;

  ActuatorLog({
    required this.id,
    required this.timestamp,
    this.led = 'OFF',
    this.fan = 'OFF',
    this.phUp = false,
    this.abMix = false,
    this.phDown = false,
    this.pump = false,
  });

  factory ActuatorLog.fromJson(Map<String, dynamic> json) {
    return ActuatorLog(
      id: json['id'] ?? 0,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      led: json['led'] ?? 'OFF',
      fan: json['fan'] ?? 'OFF',
      phUp: json['ph_up'] ?? false,
      abMix: json['ab_mix'] ?? false,
      phDown: json['ph_down'] ?? false,
      pump: json['pump'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'led': led,
      'fan': fan,
      'ph_up': phUp,
      'ab_mix': abMix,
      'ph_down': phDown,
      'pump': pump,
    };
  }

  bool get isLedOn => led.toUpperCase() == 'ON';
  bool get isFanOn => fan.toUpperCase() == 'ON';

  /// Get list of active actuators
  List<String> get activeActuators {
    final active = <String>[];
    if (isLedOn) active.add('LED');
    if (isFanOn) active.add('FAN');
    if (phUp) active.add('pH Up');
    if (phDown) active.add('pH Down');
    if (abMix) active.add('AB Mix');
    if (pump) active.add('Pump');
    return active;
  }
}
