import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tumbuhkan/models/mascot_state.dart';
import 'package:tumbuhkan/screens/home/home_screen.dart';
import '../../services/mqtt_service.dart';
import '../../services/mascot_service.dart';
import '../../widgets/home/tumu_mascot.dart';
import '../../widgets/home/animated_chat_bubble.dart';
import '../../widgets/home/cloud_chat_bubble.dart'; // ✅ ADD

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _sensorPanelWidth = 190;
  bool _isInitialized = false; // ✅ ADD THIS

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [HOME] initState called');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      final mqttService = context.read<MqttService>();
      final mascotService = context.read<MascotService>();

      debugPrint('🔗 [HOME] Linking services...');
      debugPrint('   MQTT: ${mqttService.runtimeType}');
      debugPrint('   Mascot: ${mascotService.runtimeType}');

      // ✅ CRITICAL: Link mascot to MQTT
      mqttService.setMascotService(mascotService);

      // Force initial update after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && mqttService.isConnected) {
          debugPrint('🎯 [HOME] Force initial mascot update...');
          mascotService.updateState(
            temperature: mqttService.airTemperature,
            phValue: mqttService.ph,
            nutrientLevel: mqttService.tds,
            waterLevel: mqttService.waterLevel,
            isConnected: mqttService.isConnected,
          );
        }
      });

      if (!mqttService.isConnected) {
        debugPrint('📡 [HOME] Connecting MQTT...');
        mqttService.connect();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF33A8DB), // Cyan blue
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content (NO SCROLL - Fixed Layout)
            Column(
              children: [
                const SizedBox(height: 110), // ✅ space for top overlay row

                Expanded(child: _buildMascot()),
                const SizedBox(height: 10),
                _buildWaterLevel(),
                const SizedBox(height: 10),
                _buildBottomNav(),
              ],
            ),

            // ✅ Top overlay: Sensor panel (left) + Cloud bubble (right) + MQTT status
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: _sensorPanelWidth,
                    child: _buildMiniSensorBars(),
                  ),
                  const SizedBox(width: 12),

                  // Bubble side (cloud)
                  Expanded(
                    child: Consumer<MascotService>(
                      builder: (context, mascot, _) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: CloudChatBubble(
                            message: mascot.currentState.message,
                            accentColor: mascot.currentState.color,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 12),
                  _buildMqttStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MINI SENSOR BARS (RPG STYLE - TOP LEFT) ✅ COMPLETE
  // ═══════════════════════════════════════════════════════════
  Widget _buildMiniSensorBars() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Water Level
              _buildMiniBar(
                icon: Icons.water_drop,
                label: 'Water',
                value: mqtt.waterLevel,
                maxValue: 100,
                color: _getWaterLevelColor(mqtt.waterLevel),
                unit: '%',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Water Level',
                  '%',
                  Icons.water_drop,
                  _getWaterLevelColor(mqtt.waterLevel),
                  mqtt.waterLevel.toStringAsFixed(0),
                ),
              ),
              const SizedBox(height: 8),

              // pH Level
              _buildMiniBar(
                icon: Icons.science,
                label: 'pH',
                value: mqtt.ph,
                maxValue: 14,
                color: _getPhColor(mqtt.ph),
                unit: '',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'pH Level',
                  '',
                  Icons.science,
                  _getPhColor(mqtt.ph),
                  mqtt.ph.toStringAsFixed(1),
                ),
              ),
              const SizedBox(height: 8),

              // TDS (Nutrient)
              _buildMiniBar(
                icon: Icons.bubble_chart,
                label: 'TDS',
                value: mqtt.tds,
                maxValue: 2000,
                color: _getTdsColor(mqtt.tds),
                unit: 'ppm',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'TDS (Nutrient)',
                  'ppm',
                  Icons.bubble_chart,
                  _getTdsColor(mqtt.tds),
                  mqtt.tds.toStringAsFixed(0),
                ),
              ),
              const SizedBox(height: 8),

              // Air Temperature
              _buildMiniBar(
                icon: Icons.thermostat,
                label: 'Air Temp',
                value: mqtt.airTemperature,
                maxValue: 50,
                color: _getTempColor(mqtt.airTemperature),
                unit: '°C',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Air Temperature',
                  '°C',
                  Icons.thermostat,
                  _getTempColor(mqtt.airTemperature),
                  mqtt.airTemperature.toStringAsFixed(1),
                ),
              ),
              const SizedBox(height: 8),

              // Water Temperature
              _buildMiniBar(
                icon: Icons.water,
                label: 'Water T.',
                value: mqtt.waterTemperature,
                maxValue: 50,
                color: _getWaterTempColor(mqtt.waterTemperature),
                unit: '°C',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Water Temperature',
                  '°C',
                  Icons.water,
                  _getWaterTempColor(mqtt.waterTemperature),
                  mqtt.waterTemperature.toStringAsFixed(1),
                ),
              ),
              const SizedBox(height: 8),

              // Air Humidity
              _buildMiniBar(
                icon: Icons.opacity,
                label: 'Humidity',
                value: mqtt.airHumidity,
                maxValue: 100,
                color: _getHumidityColor(mqtt.airHumidity),
                unit: '%',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Air Humidity',
                  '%',
                  Icons.opacity,
                  _getHumidityColor(mqtt.airHumidity),
                  mqtt.airHumidity.toStringAsFixed(0),
                ),
              ),
              const SizedBox(height: 8),

              // Light (LDR)
              _buildMiniBar(
                icon: Icons.wb_sunny,
                label: 'Light',
                value: mqtt.ldrValue,
                maxValue: 1000,
                color: _getLightColor(mqtt.ldrValue),
                unit: '',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Light Intensity',
                  'lux',
                  Icons.wb_sunny,
                  _getLightColor(mqtt.ldrValue),
                  mqtt.ldrValue.toStringAsFixed(0),
                ),
              ),
              const SizedBox(height: 8),

              // Water Flow
              _buildMiniBar(
                icon: Icons.waves,
                label: 'Flow',
                value: mqtt.waterFlow,
                maxValue: 10,
                color: const Color(0xFF00BCD4),
                unit: 'L/h',
                onTap: () => _navigateToSensorDetail(
                  context,
                  'Water Flow',
                  'L/hour',
                  Icons.waves,
                  const Color(0xFF00BCD4),
                  mqtt.waterFlow.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MQTT STATUS (TOP RIGHT) ✅
  // ═══════════════════════════════════════════════════════════
  Widget _buildMqttStatus() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Row(
          children: [
            // MQTT Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: mqtt.isConnected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: mqtt.isConnected ? Colors.green : Colors.red,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: mqtt.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mqtt.isConnected ? 'MQTT' : 'Offline',
                    style: TextStyle(
                      color: mqtt.isConnected ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Settings Button
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CHAT BUBBLE ✅
  // ═══════════════════════════════════════════════════════════
  Widget _buildChatBubble() {
    return Consumer<MascotService>(
      builder: (context, mascot, _) {
        return AnimatedChatBubble(
          message: mascot.currentState.message, // ✅ Now available via extension
          backgroundColor:
              mascot.currentState.color, // ✅ Now available via extension
          showTail: true,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MASCOT (MAIN FOCUS) ✅ - BIGGER
  // ═══════════════════════════════════════════════════════════
  Widget _buildMascot() {
    return Consumer<MascotService>(
      builder: (context, mascot, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Ambil sisi terpendek biar aman untuk square mascot
            final shortest = constraints.biggest.shortestSide;

            // Naikkan scale (atur angka ini kalau masih kurang besar)
            final size = (shortest * 1.20).clamp(240.0, 520.0);

            return Center(
              child: Transform.translate(
                // Sedikit naik supaya lebih “hero”
                offset: const Offset(0, -10),
                child: TumuMascot(
                  state: mascot.currentState,
                  size: size,
                  onTap: () {
                    // 🆕 Handle tap on Tumu
                    debugPrint('👆 [HOME] Tumu tapped!');

                    // Optional: Show snackbar atau dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Halo! ${mascot.currentState.message}'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: mascot.currentState.color,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WATER LEVEL DROPS ✅
  // ═══════════════════════════════════════════════════════════
  Widget _buildWaterLevel() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        final waterPercentage = (mqtt.waterLevel / 100).clamp(0.0, 1.0);
        final dropCount = (waterPercentage * 10).round().clamp(0, 10);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            10,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                Icons.water_drop,
                color: index < dropCount
                    ? const Color(0xFF2196F3)
                    : Colors.white.withOpacity(0.2),
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BOTTOM NAV ✅
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.camera_alt, 'Camera', false, () {
            Navigator.pushNamed(context, '/camera');
          }),
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.smart_toy, 'AI Chat', false, () {
            Navigator.pushNamed(context, '/chat');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF1976D2) : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFF1976D2) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS ✅
  // ═══════════════════════════════════════════════════════════
  Color _getWaterLevelColor(double level) {
    if (level >= 80) return const Color(0xFF4CAF50); // Green
    if (level >= 60) return const Color(0xFF8BC34A); // Light Green
    if (level >= 40) return const Color(0xFFFFC107); // Yellow
    if (level >= 20) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  Color _getPhColor(double ph) {
    if (ph >= 5.5 && ph <= 7.5) {
      return const Color(0xFF4CAF50); // Green (optimal 5.5-7.5)
    } else {
      return const Color(0xFF9C27B0); // Purple (unstable)
    }
  }

  Color _getTdsColor(double tds) {
    if (tds >= 1000 && tds <= 1500) {
      return const Color(0xFF4CAF50); // Green (optimal)
    } else if (tds < 800) {
      return const Color(0xFFFFC107); // Yellow (low)
    } else if (tds > 1800) {
      return const Color(0xFFFF5722); // Red (too high)
    }
    return const Color(0xFF8BC34A); // Light green (acceptable)
  }

  Color _getTempColor(double temp) {
    if (temp < 18) {
      return const Color(0xFF2196F3); // Blue (cold)
    } else if (temp > 32) {
      return const Color(0xFFFF5722); // Red (hot)
    } else if (temp >= 22 && temp <= 28) {
      return const Color(0xFF4CAF50); // Green (optimal)
    }
    return const Color(0xFFFFC107); // Yellow (acceptable)
  }

  Color _getWaterTempColor(double temp) {
    if (temp < 18) {
      return const Color(0xFF2196F3); // Blue (cold)
    } else if (temp > 28) {
      return const Color(0xFFFF5722); // Red (hot)
    } else if (temp >= 20 && temp <= 26) {
      return const Color(0xFF4CAF50); // Green (optimal)
    }
    return const Color(0xFF00BCD4); // Cyan (acceptable)
  }

  Color _getHumidityColor(double humidity) {
    if (humidity >= 50 && humidity <= 70) {
      return const Color(0xFF4CAF50); // Green (optimal)
    } else if (humidity < 40) {
      return const Color(0xFFFF9800); // Orange (dry)
    } else if (humidity > 80) {
      return const Color(0xFF2196F3); // Blue (wet)
    }
    return const Color(0xFF8BC34A); // Light green (acceptable)
  }

  Color _getLightColor(double ldrValue) {
    if (ldrValue >= 400 && ldrValue <= 600) {
      return const Color(0xFFFFC107); // Yellow (optimal)
    } else if (ldrValue < 300) {
      return const Color(0xFF757575); // Gray (dark)
    } else if (ldrValue > 700) {
      return const Color(0xFFFFEB3B); // Bright yellow (very bright)
    }
    return const Color(0xFFFF9800); // Orange (acceptable)
  }

  // Navigate to Sensor Detail
  void _navigateToSensorDetail(
    BuildContext context,
    String name,
    String unit,
    IconData icon,
    Color color,
    String currentValue,
  ) {
    Navigator.pushNamed(
      context,
      '/sensor-detail',
      arguments: {
        'sensorName': name,
        'sensorUnit': unit,
        'sensorIcon': icon,
        'sensorColor': color,
        'currentValue': currentValue,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MINI BAR WIDGET (✅ UPDATED with unit)
  // ═══════════════════════════════════════════════════════════
  Widget _buildMiniBar({
    required IconData icon,
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    required String unit,
    required VoidCallback onTap,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label + Value
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(value < 10 ? 1 : 0)}$unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
