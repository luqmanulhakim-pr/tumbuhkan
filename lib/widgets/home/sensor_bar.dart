import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget untuk menampilkan sensor data dengan progress bar
class SensorBar extends StatelessWidget {
  final String iconPath; // Path SVG icon
  final String label; // Label sensor (e.g., "Water Level")
  final double value; // Nilai sensor (0-100)
  final double maxValue; // Nilai maksimal (default 100)
  final String unit; // Unit (%, ppm, °C)
  final Color? color; // Warna custom (opsional)
  final bool showPercentage; // Tampilkan % atau nilai asli

  const SensorBar({
    super.key,
    required this.iconPath,
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.unit = '%',
    this.color,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung persentase
    final percentage = (value / maxValue * 100).clamp(0, 100).toDouble();

    // Tentukan warna berdasarkan level
    final barColor = color ?? _getColorByLevel(percentage);

    // Format nilai display
    final displayValue = showPercentage
        ? '${percentage.toStringAsFixed(0)}%'
        : '${value.toStringAsFixed(1)} $unit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Icon + Label + Value)
          Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  iconPath,
                  colorFilter: ColorFilter.mode(
                    barColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF424242),
                  ),
                ),
              ),

              // Value
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Tentukan warna berdasarkan level (traffic light system)
  Color _getColorByLevel(double percentage) {
    if (percentage >= 60) {
      return const Color(0xFF4CAF50); // Green - Good
    } else if (percentage >= 30) {
      return const Color(0xFFFFC107); // Amber - Warning
    } else {
      return const Color(0xFFF44336); // Red - Critical
    }
  }
}
