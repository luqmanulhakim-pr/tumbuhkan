import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../services/mqtt_service.dart';

class TemperatureCard extends StatelessWidget {
  final MqttService mqttService;

  const TemperatureCard({
    super.key,
    required this.mqttService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Temperature Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/icon_temperature.svg',
                height: 32,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF5252),
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => const Icon(
                  Icons.thermostat,
                  color: Color(0xFFFF5252),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Temperature Values
          Flexible(
            child: Text(
              '${mqttService.temperature.toStringAsFixed(0)}°, '
              '${mqttService.humidity.toStringAsFixed(0)}°, '
              '${mqttService.lightLevel.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
