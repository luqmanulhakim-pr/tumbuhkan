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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(mqtt),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16), // ✅ Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water & pH Control Section
                    const Text(
                      'Water & pH Control',
                      style: TextStyle(
                        fontSize: 16, // ✅ Reduced font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Control Buttons Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10, // ✅ Reduced spacing
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1, // ✅ Adjusted ratio
                      children: [
                        _buildControlCard(
                          icon: Icons.water_drop,
                          label: 'Watering',
                          isActive: mqtt.isPumpOn,
                          onTap: () => mqtt.setPump(!mqtt.isPumpOn),
                          color: Colors.blue,
                        ),
                        _buildControlCard(
                          icon: Icons.lightbulb,
                          label: 'Grow Light',
                          isActive: mqtt.isGrowLightOn,
                          onTap: () => mqtt.setGrowLight(!mqtt.isGrowLightOn),
                          color: Colors.amber,
                        ),
                        _buildControlCard(
                          icon: Icons.arrow_upward,
                          label: 'pH Up',
                          isActive: mqtt.isPhUpPumpOn,
                          onTap: () => mqtt.setPhUpPump(!mqtt.isPhUpPumpOn),
                          color: Colors.purple,
                        ),
                        _buildControlCard(
                          icon: Icons.arrow_downward,
                          label: 'pH Down',
                          isActive: mqtt.isPhDownPumpOn,
                          onTap: () => mqtt.setPhDownPump(!mqtt.isPhDownPumpOn),
                          color: Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Nutrients Section
                    const Text(
                      'Nutrient Control',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Nutrient Buttons Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: [
                        _buildControlCard(
                          icon: Icons.science,
                          label: 'Nutrient A',
                          isActive: mqtt.isNutrientAPumpOn,
                          onTap: () =>
                              mqtt.setNutrientAPump(!mqtt.isNutrientAPumpOn),
                          color: const Color(0xFF4CAF50),
                        ),
                        _buildControlCard(
                          icon: Icons.science,
                          label: 'Nutrient B',
                          isActive: mqtt.isNutrientBPumpOn,
                          onTap: () =>
                              mqtt.setNutrientBPump(!mqtt.isNutrientBPumpOn),
                          color: const Color(0xFF009688),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Info Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap cards to toggle actuators. Green border indicates active state.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[900],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
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
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/camera');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/home');
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
      padding: const EdgeInsets.all(16), // ✅ Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                      fontSize: 22, // ✅ Reduced font size
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Device Control Panel',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => mqtt.connect(),
                color: const Color(0xFF2E7D32),
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const ConnectionStatusIndicator(),
        ],
      ),
    );
  }

  // ============================================
  // Control Card Widget (FIXED - Better proportions)
  // ============================================
  Widget _buildControlCard({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12), // ✅ Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 2.5, // ✅ Slightly thinner border
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF2E7D32).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(10), // ✅ Reduced padding
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2E7D32).withOpacity(0.1)
                    : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28, // ✅ Reduced icon size
                color: isActive ? const Color(0xFF2E7D32) : color,
              ),
            ),
            const SizedBox(height: 8), // ✅ Reduced spacing

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13, // ✅ Reduced font size
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF2E7D32) : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3), // ✅ Reduced spacing

            // Status
            Text(
              isActive ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 10, // ✅ Reduced font size
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2E7D32) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
