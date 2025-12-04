import 'package:flutter/foundation.dart';
import '../models/schedule_model.dart';

class ScheduleService extends ChangeNotifier {
  // ============================================
  // Properties
  // ============================================
  final List<Schedule> _schedules = [];

  // ============================================
  // Getters
  // ============================================
  List<Schedule> get schedules => List.unmodifiable(_schedules);

  List<Schedule> get activeSchedules =>
      _schedules.where((s) => s.isActive).toList();

  List<Schedule> getSchedulesByType(String type) =>
      _schedules.where((s) => s.type == type).toList();

  // ============================================
  // Add Schedule
  // ============================================
  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    _schedules.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    notifyListeners();

    debugPrint(
        '✅ Schedule added: ${schedule.displayName} at ${schedule.scheduledTime}');

    // TODO: Save to database
    // await _saveToDatabase(schedule);
  }

  // ============================================
  // Update Schedule
  // ============================================
  void updateSchedule(String id, Schedule updatedSchedule) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      _schedules.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      notifyListeners();

      debugPrint('✅ Schedule updated: ${updatedSchedule.displayName}');

      // TODO: Update in database
      // await _updateInDatabase(updatedSchedule);
    }
  }

  // ============================================
  // Delete Schedule
  // ============================================
  void deleteSchedule(String id) {
    final schedule = _schedules.firstWhere((s) => s.id == id);
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();

    debugPrint('❌ Schedule deleted: ${schedule.displayName}');

    // TODO: Delete from database
    // await _deleteFromDatabase(id);
  }

  // ============================================
  // Toggle Schedule Active Status
  // ============================================
  void toggleSchedule(String id) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = _schedules[index].copyWith(
        isActive: !_schedules[index].isActive,
      );
      notifyListeners();

      debugPrint(
          '🔄 Schedule toggled: ${_schedules[index].displayName} (${_schedules[index].isActive ? "ON" : "OFF"})');

      // TODO: Update in database
      // await _updateInDatabase(_schedules[index]);
    }
  }

  // ============================================
  // Check and Execute Schedules
  // ============================================
  void checkSchedules() {
    final now = DateTime.now();

    for (final schedule in activeSchedules) {
      if (_shouldExecute(schedule, now)) {
        _executeSchedule(schedule);
      }
    }
  }

  bool _shouldExecute(Schedule schedule, DateTime now) {
    // Check if schedule time has passed
    if (schedule.scheduledTime.isBefore(now)) {
      // If repeating, check if it's time today
      if (schedule.isRepeating) {
        final scheduleTimeToday = DateTime(
          now.year,
          now.month,
          now.day,
          schedule.scheduledTime.hour,
          schedule.scheduledTime.minute,
        );

        // Execute if within 1 minute window
        final difference = now.difference(scheduleTimeToday).inMinutes.abs();
        return difference < 1;
      } else {
        // One-time schedule, execute once
        return true;
      }
    }
    return false;
  }

  void _executeSchedule(Schedule schedule) {
    debugPrint('⚡ Executing schedule: ${schedule.displayName}');

    // TODO: Trigger MQTT command to turn on pump
    // mqttService.publish(
    //   'tumbuhkan/actuator/${schedule.type}/control',
    //   '1',
    // );

    // TODO: After duration, turn off pump
    // Future.delayed(Duration(seconds: schedule.durationSeconds), () {
    //   mqttService.publish(
    //     'tumbuhkan/actuator/${schedule.type}/control',
    //     '0',
    //   );
    // });

    // If not repeating, deactivate after execution
    if (!schedule.isRepeating) {
      toggleSchedule(schedule.id);
    }
  }

  // ============================================
  // Load Dummy Data
  // ============================================
  void loadDummyData() {
    _schedules.addAll([
      Schedule(
        id: '1',
        type: 'nutrient_a',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        durationSeconds: 30,
        isRepeating: true,
        notes: 'Morning feeding',
      ),
      Schedule(
        id: '2',
        type: 'nutrient_b',
        scheduledTime: DateTime.now().add(const Duration(hours: 2, minutes: 5)),
        durationSeconds: 30,
        isRepeating: true,
        notes: 'Morning feeding',
      ),
      Schedule(
        id: '3',
        type: 'ph_up',
        scheduledTime: DateTime.now().add(const Duration(hours: 8)),
        durationSeconds: 15,
        isRepeating: false,
        notes: 'Adjust pH level',
      ),
    ]);
    notifyListeners();
  }
}
