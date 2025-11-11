import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 🆕 Import SVG
import '../../services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default: Home tab (middle)

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MqttService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            // ============================================
            // Header Section
            // ============================================
            _buildHeader(context, mqttService),

            // ============================================
            // Main Content (Scrollable)
            // ============================================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Sensor Values dengan Progress Bar
                    _buildSensorSection(mqttService),

                    const SizedBox(height: 30),

                    // Temperature Display (Big)
                    _buildTemperatureDisplay(mqttService),

                    const SizedBox(height: 30),

                    // Action Buttons
                    _buildActionButtons(mqttService),

                    const SizedBox(height: 40),

                    // Mascot Character
                    _buildMascotSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================
      // Bottom Navigation Bar
      // ============================================
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ============================================
  // Header dengan Logo + Icons
  // ============================================
  Widget _buildHeader(BuildContext context, MqttService mqtt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Tumbuhkan
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/logo_tumbuhkan.svg',
                height: 40,
                // Fallback jika SVG error
                placeholderBuilder: (context) => const Icon(
                  Icons.eco,
                  color: Color(0xFF2E7D32),
                  size: 40,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tumbuhkan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),

          // Right Icons
          Row(
            children: [
              // Settings Icon
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/btn_setting.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1976D2),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  _showSnackBar(context, 'Settings coming soon');
                },
              ),

              // Schedule Icon
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/btn_schedule.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1976D2),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  _showSnackBar(context, 'Schedule coming soon');
                },
              ),

              // Logs Icon
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/btn_log.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1976D2),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () {
                  _showSnackBar(context, 'Logs coming soon');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // Sensor Section dengan Progress Bar
  // ============================================
  Widget _buildSensorSection(MqttService mqtt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Water Level (EC/TDS)
          _buildProgressBar(
            iconPath: 'assets/images/ikon_water.svg',
            iconFallback: Icons.water_drop,
            label: 'EC',
            value: mqtt.moistureLevel,
            maxValue: 100,
            unit: '',
            color: const Color(0xFF42A5F5),
          ),
          const SizedBox(height: 15),

          // pH Level
          _buildProgressBar(
            iconPath: 'assets/images/icon_ph.svg',
            iconFallback: Icons.science,
            label: 'pH',
            value: mqtt.humidity / 10, // Map 0-100 to 0-14
            maxValue: 14,
            unit: '',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(height: 15),

          // Nutrients (N)
          _buildProgressBar(
            iconPath: 'assets/images/icon_nutrients.svg',
            iconFallback: Icons.bolt,
            label: 'N',
            value: mqtt.lightLevel,
            maxValue: 200,
            unit: 'ppm',
            color: const Color(0xFFFDD835),
          ),
        ],
      ),
    );
  }

  // Progress Bar Widget dengan SVG Support
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

    return Row(
      children: [
        // Icon (SVG)
        SizedBox(
          width: 40,
          child: SvgPicture.asset(
            iconPath,
            height: 30,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (context) => Icon(
              iconFallback,
              color: color,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Label
        SizedBox(
          width: 30,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Value
        SizedBox(
          width: 60,
          child: Text(
            '${value.toStringAsFixed(1)}$unit',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // Temperature Display (Large)
  // ============================================
  Widget _buildTemperatureDisplay(MqttService mqtt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Temperature Icon
        SvgPicture.asset(
          'assets/images/ikon_temperature.svg',
          height: 50,
          colorFilter: const ColorFilter.mode(
            Color(0xFFFF5252),
            BlendMode.srcIn,
          ),
          placeholderBuilder: (context) => const Icon(
            Icons.thermostat,
            color: Color(0xFFFF5252),
            size: 50,
          ),
        ),
        const SizedBox(width: 20),

        // Temperature Values
        Text(
          '${mqtt.temperature.toStringAsFixed(0)}°, '
          '${mqtt.humidity.toStringAsFixed(0)}°, '
          '${mqtt.lightLevel.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  // ============================================
  // Action Buttons
  // ============================================
  Widget _buildActionButtons(MqttService mqtt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Button 1: Yesayi kondisi Optimal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: mqtt.isConnected
                  ? () {
                      // Set optimal conditions
                      mqtt.setPump(true);
                      mqtt.setGrowLight(true);
                      _showSnackBar(context, '✅ Setting optimal conditions...');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: mqtt.isConnected ? 3 : 0,
              ),
              child: Text(
                'Yesayi kondisi Optimal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mqtt.isConnected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Button 2: Jaga terus ya!
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: mqtt.isConnected
                  ? () {
                      _showSnackBar(context, '🌱 Monitoring active!');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: mqtt.isConnected ? 3 : 0,
              ),
              child: Text(
                'Jaga terus ya!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: mqtt.isConnected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Mascot Section
  // ============================================
  Widget _buildMascotSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background gradient sand
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFFE0B2),
                  Color(0xFFFFECB3),
                ],
              ),
            ),
          ),
        ),

        // Mascot Image (SVG)
        Column(
          children: [
            SvgPicture.asset(
              'assets/images/Tumu.svg',
              height: 200,
              placeholderBuilder: (context) => Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
                    SizedBox(height: 10),
                    Text(
                      'Tumu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // Bottom Navigation Bar
  // ============================================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF29B6F6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            switch (index) {
              case 0:
                _showSnackBar(context, '📷 Camera feature coming soon');
                break;
              case 1:
                // Already on home
                break;
              case 2:
                _showSnackBar(context, '🎮 Controller feature coming soon');
                break;
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            // Camera
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/btn_cam.svg',
                height: 30,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0 ? Colors.white : Colors.white70,
                  BlendMode.srcIn,
                ),
              ),
              label: '',
            ),

            // Home
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/btn_home.svg',
                height: 30,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1 ? Colors.white : Colors.white70,
                  BlendMode.srcIn,
                ),
              ),
              label: '',
            ),

            // Controller
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/btn_controlling.svg',
                height: 30,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2 ? Colors.white : Colors.white70,
                  BlendMode.srcIn,
                ),
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
