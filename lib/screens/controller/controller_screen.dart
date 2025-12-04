import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../widgets/home/connection_status_indicator.dart';

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
      backgroundColor: Colors.grey[100],
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

                    // Info Card (UPDATED - Blue theme)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2)
                            .withOpacity(0.1), // ✅ Blue background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1976D2)
                              .withOpacity(0.3), // ✅ Blue border
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF1976D2), // ✅ Blue icon
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap cards to toggle actuators. Blue border indicates active state.',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    const Color(0xFF0D47A1), // ✅ Dark blue text
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
    );
  }

  // ============================================
  // Header (UPDATED - Blue theme)
  // ============================================
  Widget _buildHeader(MqttService mqtt) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2), // ✅ Blue
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
                color: const Color(0xFF1976D2), // ✅ Blue
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
  // Control Card Widget (UPDATED - Blue active state)
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF1976D2)
                : Colors.transparent, // ✅ Blue
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF1976D2).withOpacity(0.2) // ✅ Blue shadow
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1976D2)
                        .withOpacity(0.1) // ✅ Blue background
                    : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color:
                    isActive ? const Color(0xFF1976D2) : color, // ✅ Blue icon
              ),
            ),
            const SizedBox(height: 8),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF1976D2)
                    : Colors.black87, // ✅ Blue text
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            // Status
            Text(
              isActive ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive
                    ? const Color(0xFF1976D2)
                    : Colors.grey, // ✅ Blue status
              ),
            ),
          ],
        ),
      ),
    );
  }
}
