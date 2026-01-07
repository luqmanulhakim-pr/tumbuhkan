import 'package:flutter/material.dart';
import 'package:tumbuhkan/widgets/home/sensor_bar.dart';

/// Grid untuk menampilkan semua sensor
class SensorGrid extends StatelessWidget {
  final double waterLevel;
  final double phValue;
  final double nutrientPpm;
  final double temperature;
  final double humidity;

  const SensorGrid({
    super.key,
    required this.waterLevel,
    required this.phValue,
    required this.nutrientPpm,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Water Level
        SensorBar(
          iconPath: 'assets/images/icon_water.svg',
          label: 'Water Level',
          value: waterLevel,
          maxValue: 100,
          unit: '%',
          showPercentage: true,
        ),

        // pH
        SensorBar(
          iconPath: 'assets/images/icon_ph.svg',
          label: 'pH Level',
          value: phValue,
          maxValue: 14,
          unit: '',
          showPercentage: false,
          color: _getPhColor(phValue),
        ),

        // Nutrient
        SensorBar(
          iconPath: 'assets/images/icon_nutrients.svg',
          label: 'Nutrient',
          value: nutrientPpm,
          maxValue: 2000,
          unit: 'ppm',
          showPercentage: false,
          color: const Color(0xFFFFC107), // Yellow
        ),

        // Temperature
        SensorBar(
          iconPath: 'assets/images/icon_temperature.svg',
          label: 'Temperature',
          value: temperature,
          maxValue: 50,
          unit: '°C',
          showPercentage: false,
          color: _getTemperatureColor(temperature),
        ),
      ],
    );
  }

  /// Warna pH (purple untuk unstable)
  Color _getPhColor(double ph) {
    if (ph >= 5.5 && ph <= 7.5) {
      return const Color(0xFF4CAF50); // Green - Optimal
    } else {
      return const Color(0xFF9C27B0); // Purple - Unstable
    }
  }

  /// Warna temperature
  Color _getTemperatureColor(double temp) {
    if (temp < 18) {
      return const Color(0xFF2196F3); // Blue - Cold
    } else if (temp > 32) {
      return const Color(0xFFFF5722); // Red - Hot
    } else {
      return const Color(0xFF4CAF50); // Green - Normal
    }
  }
}
