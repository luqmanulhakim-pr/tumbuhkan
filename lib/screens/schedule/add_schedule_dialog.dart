import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/schedule_service.dart';
import '../../models/schedule_model.dart';

class AddScheduleDialog extends StatefulWidget {
  final Schedule? schedule; // For editing existing schedule

  const AddScheduleDialog({super.key, this.schedule});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late String _selectedType;
  late DateTime _selectedDateTime;
  late int _durationSeconds;
  late bool _isRepeating;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    if (widget.schedule != null) {
      // Edit mode
      _selectedType = widget.schedule!.type;
      _selectedDateTime = widget.schedule!.scheduledTime;
      _durationSeconds = widget.schedule!.durationSeconds;
      _isRepeating = widget.schedule!.isRepeating;
      _notesController = TextEditingController(text: widget.schedule!.notes);
    } else {
      // Add mode
      _selectedType = 'nutrient_a';
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
      _durationSeconds = 30;
      _isRepeating = false;
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.schedule != null ? 'Edit Schedule' : 'Add Schedule',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            const Text(
              'Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'nutrient_a',
                      child: Text('💧 Nutrient A'),
                    ),
                    DropdownMenuItem(
                      value: 'nutrient_b',
                      child: Text('💧 Nutrient B'),
                    ),
                    DropdownMenuItem(
                      value: 'ph_up',
                      child: Text('⬆️ pH Up'),
                    ),
                    DropdownMenuItem(
                      value: 'ph_down',
                      child: Text('⬇️ pH Down'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date & Time Selector
            const Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDateTime(_selectedDateTime),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Duration
            const Text(
              'Duration (seconds)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _durationSeconds.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: '${_durationSeconds}s',
                    activeColor: const Color(0xFF2E7D32),
                    onChanged: (value) {
                      setState(() {
                        _durationSeconds = value.toInt();
                      });
                    },
                  ),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${_durationSeconds}s',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Repeating Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Repeat Daily',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: _isRepeating,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged: (value) {
                    setState(() {
                      _isRepeating = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes
            const Text(
              'Notes (optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'e.g., Morning feeding',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
          ),
          child: Text(widget.schedule != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  // ============================================
  // Select Date & Time
  // ============================================
  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // ============================================
  // Save Schedule
  // ============================================
  void _saveSchedule() {
    final scheduleService =
        Provider.of<ScheduleService>(context, listen: false);

    if (widget.schedule != null) {
      // Update existing schedule
      scheduleService.updateSchedule(
        widget.schedule!.id,
        widget.schedule!.copyWith(
          type: _selectedType,
          scheduledTime: _selectedDateTime,
          durationSeconds: _durationSeconds,
          isRepeating: _isRepeating,
          notes: _notesController.text,
        ),
      );
    } else {
      // Add new schedule
      final newSchedule = Schedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        scheduledTime: _selectedDateTime,
        durationSeconds: _durationSeconds,
        isRepeating: _isRepeating,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      scheduleService.addSchedule(newSchedule);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.schedule != null
              ? 'Schedule updated successfully!'
              : 'Schedule added successfully!',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  // ============================================
  // Format DateTime
  // ============================================
  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }
}
