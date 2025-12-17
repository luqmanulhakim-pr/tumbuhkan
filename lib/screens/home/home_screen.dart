import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tumbuhkan/widgets/chatbot_fab.dart';
import 'package:tumbuhkan/widgets/home/connection_status_indicator.dart';
import '../../services/mqtt_service.dart';
import '../../widgets/home/bottom_nav_bar.dart';
import '../controller/controller_screen.dart';
import '../camera/camera_screen.dart';
import '../monitoring/monitoring_screen.dart';
import '../sensor_detail/sensor_detail_screen.dart';
import '../settings/settings_screen.dart'; // 🆕 Import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const _DashboardScreen(),
    const ControllerScreen(),
    const CameraScreen(),
    const MonitoringScreen(),
    const SettingsScreen(), // 🆕 Add
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMqtt();
    });
  }

  Future<void> _initializeMqtt() async {
    final mqtt = Provider.of<MqttService>(context, listen: false);
    await mqtt.connect();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // Contoh di home_screen.dart
      floatingActionButton: const ChatBotFAB(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ============================================
// Dashboard Screen
// ============================================
class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen();

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttService>(context);

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context, mqtt),
          Expanded(
            child: _buildDashboard(context, mqtt),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MqttService mqtt) {
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
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Smart Hydroponics System',
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
                color: const Color(0xFF1976D2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const ConnectionStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, MqttService mqtt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Water Status Card (hasil klasifikasi)
          _buildWaterStatusCard(mqtt),
          const SizedBox(height: 20),

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

          // ✅ UPDATED: Sensor Cards dengan data baru
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildSensorCard(
                context,
                icon: Icons.thermostat,
                label: 'Air Temperature',
                value: mqtt.airTemperature.toStringAsFixed(1),
                unit: '°C',
                color: Colors.orange,
              ),
              _buildSensorCard(
                context,
                icon: Icons.water_drop,
                label: 'Air Humidity',
                value: mqtt.airHumidity.toStringAsFixed(1),
                unit: '%',
                color: Colors.blue,
              ),
              _buildSensorCard(
                context,
                icon: Icons.light_mode,
                label: 'Light (LDR)',
                value: mqtt.ldrValue.toStringAsFixed(0),
                unit: 'lux',
                color: Colors.amber,
              ),
              _buildSensorCard(
                context,
                icon: Icons.science,
                label: 'pH Level',
                value: mqtt.ph.toStringAsFixed(2),
                unit: '',
                color: Colors.purple,
              ),
              _buildSensorCard(
                context,
                icon: Icons.water,
                label: 'TDS (Nutrients)',
                value: mqtt.tds.toStringAsFixed(0),
                unit: 'ppm',
                color: Colors.green,
              ),
              _buildSensorCard(
                context,
                icon: Icons.waves,
                label: 'Water Flow',
                value: mqtt.waterFlow.toStringAsFixed(1),
                unit: 'L/min',
                color: Colors.cyan,
              ),
              _buildSensorCard(
                context,
                icon: Icons.device_thermostat,
                label: 'Water Temp',
                value: mqtt.waterTemperature.toStringAsFixed(1),
                unit: '°C',
                color: Colors.teal,
              ),
              _buildSensorCard(
                context,
                icon: Icons.height,
                label: 'Water Level',
                value: mqtt.waterLevel.toStringAsFixed(1),
                unit: '%',
                color: Colors.indigo,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Schedule Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/schedule');
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Manage Schedules'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
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

  // ✅ NEW: Water Status Card
  Widget _buildWaterStatusCard(MqttService mqtt) {
    Color statusColor;
    IconData statusIcon;

    switch (mqtt.waterStatus.toLowerCase()) {
      case 'optimal':
      case 'good':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'critical':
      case 'bad':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Quality Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mqtt.waterStatus,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
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
            Icon(icon, size: 32, color: color),
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
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
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
}
