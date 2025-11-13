import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../widgets/home/connection_status_indicator.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../sensor_detail/sensor_detail_screen.dart'; // ✅ Import sensor detail screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMqtt();
  }

  Future<void> _initializeMqtt() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final mqtt = Provider.of<MqttService>(context, listen: false);
    mqtt.connect();
  }

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
              child: _isInitialized ? _buildDashboard(mqtt) : _buildLoading(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleNavigation(index); // Handle navigation
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
                    'Tumbuhkan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Smart Hydroponics Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => mqtt.connect(),
                color: const Color(0xFF2E7D32),
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
  // Loading State
  // ============================================
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF2E7D32),
      ),
    );
  }

  // ============================================
  // Dashboard
  // ============================================
  Widget _buildDashboard(MqttService mqtt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sensor Data Section
          const Text(
            'Sensor Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ CHANGED: 6 sensor cards (remove nutrient A/B, add PPM)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildSensorCard(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: mqtt.temperature.toStringAsFixed(1),
                unit: '°C',
                color: Colors.orange,
              ),
              _buildSensorCard(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: mqtt.humidity.toStringAsFixed(1),
                unit: '%',
                color: Colors.blue,
              ),
              _buildSensorCard(
                icon: Icons.grass,
                label: 'Moisture',
                value: mqtt.moistureLevel.toStringAsFixed(1),
                unit: '%',
                color: Colors.brown,
              ),
              _buildSensorCard(
                icon: Icons.light_mode,
                label: 'Light',
                value: mqtt.lightLevel.toStringAsFixed(0),
                unit: 'lux',
                color: Colors.amber,
              ),
              _buildSensorCard(
                icon: Icons.science,
                label: 'pH Level',
                value: mqtt.phLevel.toStringAsFixed(1),
                unit: '',
                color: Colors.purple,
              ),

              // ✅ CHANGED: Single PPM card (nutrient concentration)
              _buildSensorCard(
                icon: Icons.water,
                label: 'Nutrients',
                value: mqtt.nutrientPPM.toStringAsFixed(0),
                unit: 'ppm',
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ✅ ADD: Schedule Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/schedule');
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Manage Schedules '),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================
  // Sensor Card Widget (UPDATED - Add navigation)
  // ============================================
  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // ✅ Navigate to sensor detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensorDetailScreen(
              sensorName: label,
              sensorUnit: unit,
              sensorIcon: icon,
              sensorColor: color,
              currentValue: value,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Actuator Card Widget
  // ============================================
  Widget _buildActuatorCard({
    required String label,
    required bool isOn,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOn
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOn ? Icons.power : Icons.power_off,
                  color: isOn ? const Color(0xFF2E7D32) : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOn ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOn ? const Color(0xFF2E7D32) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isOn,
            onChanged: onToggle,
            activeColor: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Navigation Handling
  // ============================================
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
            context, '/camera'); // ✅ Navigate to camera
        break;
      case 1:
        // Already on home
        break;
      case 2:
        Navigator.pushNamed(context, '/controller'); // ✅ Navigate to controller
        break;
    }
  }

  // ============================================
  // Snackbar
  // ============================================
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
