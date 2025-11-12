import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/mqtt_service.dart';

class SensorCard extends StatelessWidget {
  final MqttService mqttService;

  const SensorCard({
    super.key,
    required this.mqttService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProgressBar(
            iconPath: 'assets/images/icon_water.svg',
            iconFallback: Icons.water_drop,
            label: 'Lv.',
            value: mqttService.moistureLevel,
            maxValue: 100,
            unit: '',
            color: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            iconPath: 'assets/images/icon_ph.svg',
            iconFallback: Icons.science,
            label: 'pH',
            value: mqttService.humidity / 10,
            maxValue: 14,
            unit: '',
            color: const Color(0xFF26C6DA),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            iconPath: 'assets/images/icon_nutrients.svg',
            iconFallback: Icons.bolt,
            label: 'N',
            value: mqttService.lightLevel,
            maxValue: 200,
            unit: ' ppm',
            color: const Color(0xFFFDD835),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String iconPath,
    required IconData iconFallback,
    required String label,
    required double value,
    required double maxValue,
    required String unit,
    required Color color,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                placeholderBuilder: (context) => Icon(
                  iconFallback,
                  color: color,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Label
          SizedBox(
            width: 32,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),

          // Progress Bar
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 20,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Value
          SizedBox(
            width: 70,
            child: Text(
              '${value.toStringAsFixed(value >= 10 ? 0 : 1)}$unit',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
