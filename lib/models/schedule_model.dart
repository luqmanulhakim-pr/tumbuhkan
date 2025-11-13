class Schedule {
  final String id;
  final String type; // 'nutrient_a', 'nutrient_b', 'ph_up', 'ph_down'
  final DateTime scheduledTime;
  final int durationSeconds; // Duration to run pump
  final bool isActive;
  final bool isRepeating; // Daily repeat
  final String? notes;

  Schedule({
    required this.id,
    required this.type,
    required this.scheduledTime,
    required this.durationSeconds,
    this.isActive = true,
    this.isRepeating = false,
    this.notes,
  });

  // Copy with method for updates
  Schedule copyWith({
    String? id,
    String? type,
    DateTime? scheduledTime,
    int? durationSeconds,
    bool? isActive,
    bool? isRepeating,
    String? notes,
  }) {
    return Schedule(
      id: id ?? this.id,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isActive: isActive ?? this.isActive,
      isRepeating: isRepeating ?? this.isRepeating,
      notes: notes ?? this.notes,
    );
  }

  // Convert to JSON (for database storage later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'isActive': isActive,
      'isRepeating': isRepeating,
      'notes': notes,
    };
  }

  // Create from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      type: json['type'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      durationSeconds: json['durationSeconds'],
      isActive: json['isActive'] ?? true,
      isRepeating: json['isRepeating'] ?? false,
      notes: json['notes'],
    );
  }

  // Get display name
  String get displayName {
    switch (type) {
      case 'nutrient_a':
        return 'Nutrient A';
      case 'nutrient_b':
        return 'Nutrient B';
      case 'ph_up':
        return 'pH Up';
      case 'ph_down':
        return 'pH Down';
      default:
        return 'Unknown';
    }
  }

  // Get icon
  String get icon {
    switch (type) {
      case 'nutrient_a':
      case 'nutrient_b':
        return '💧';
      case 'ph_up':
        return '⬆️';
      case 'ph_down':
        return '⬇️';
      default:
        return '❓';
    }
  }

  // Get color
  int get colorValue {
    switch (type) {
      case 'nutrient_a':
        return 0xFF4CAF50; // Green
      case 'nutrient_b':
        return 0xFF009688; // Teal
      case 'ph_up':
        return 0xFF2196F3; // Blue
      case 'ph_down':
        return 0xFFFF9800; // Orange
      default:
        return 0xFF9E9E9E; // Grey
    }
  }
}
