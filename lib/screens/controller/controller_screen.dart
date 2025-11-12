import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../widgets/home/connection_status_indicator.dart';
import '../../widgets/home/bottom_nav_bar.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  final int _selectedIndex = 2; // Controller tab

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF29B6F6), // Blue background like mockup
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(mqtt),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // CONTROLLING Section
                    const Text(
                      'CONTROLLING',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Control Buttons Row 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.water_drop,
                          label: 'WATERING',
                          isActive: mqtt.isPumpOn,
                          onTap: () => mqtt.setPump(!mqtt.isPumpOn),
                        ),
                        _buildControlButton(
                          icon: Icons.arrow_upward,
                          label: 'UP',
                          sublabel: 'pH',
                          isActive: mqtt.isPhUpPumpOn,
                          onTap: () => mqtt.setPhUpPump(!mqtt.isPhUpPumpOn),
                        ),
                        _buildControlButton(
                          icon: Icons.arrow_downward,
                          label: 'DOWN',
                          sublabel: 'pH',
                          isActive: mqtt.isPhDownPumpOn,
                          onTap: () => mqtt.setPhDownPump(!mqtt.isPhDownPumpOn),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // NUTRIENTS Section
                    const Text(
                      'NUTRIENTS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Control Buttons Row 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.circle,
                          label: 'A',
                          isActive: mqtt.isNutrientAPumpOn,
                          onTap: () =>
                              mqtt.setNutrientAPump(!mqtt.isNutrientAPumpOn),
                          backgroundColor: Colors.yellow,
                        ),
                        _buildControlButton(
                          icon: Icons.circle,
                          label: 'B',
                          isActive: mqtt.isNutrientBPumpOn,
                          onTap: () =>
                              mqtt.setNutrientBPump(!mqtt.isNutrientBPumpOn),
                          backgroundColor: Colors.yellow,
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            if (index == 1) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 0) {
              Navigator.pushReplacementNamed(context, '/camera');
            }
          }
        },
      ),
    );
  }

  // ============================================
  // Header
  // ============================================
  Widget _buildHeader(MqttService mqtt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF29B6F6),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controller',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Device Control Panel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => mqtt.connect(),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const ConnectionStatusIndicator(),
        ],
      ),
    );
  }

  // ============================================
  // Control Button Widget
  // ============================================
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    String? sublabel,
    required bool isActive,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? const Color(0xFF2E7D32) : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF2E7D32).withOpacity(0.5)
                  : Colors.black.withOpacity(0.2),
              blurRadius: isActive ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: sublabel != null ? 28 : 36,
              color:
                  isActive ? const Color(0xFF2E7D32) : const Color(0xFF29B6F6),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF29B6F6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
