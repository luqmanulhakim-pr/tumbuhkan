import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  static const Color _primaryBlue = Color(0xFF29ABFF);
  static const Color _darkBlue = Color(0xFF1976D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primaryBlue, _darkBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildSectionTitle('CONTROLLING'),
                      const SizedBox(height: 24),
                      _buildMainControls(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('NUTRIENTS'),
                      const SizedBox(height: 24),
                      _buildNutrientControls(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: mqtt.isConnected ? Colors.greenAccent : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: mqtt.isConnected
                              ? Colors.greenAccent.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mqtt.isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => mqtt.connect(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              svgPath: 'assets/images/icon_water.svg',
              label: 'WATERING',
              isActive: mqtt.isPumpOn,
              onTap: () => mqtt.setPump(!mqtt.isPumpOn),
              activeColor: const Color(0xFF29ABFF),
            ),
            _buildControlButton(
              svgPath: 'assets/images/icon_ph.svg',
              label: 'UP',
              isActive: mqtt.isPhUpPumpOn,
              onTap: () => mqtt.setPhUpPump(!mqtt.isPhUpPumpOn),
              activeColor: const Color(0xFF4CAF50),
              showUpArrow: true,
            ),
            _buildControlButton(
              svgPath: 'assets/images/icon_ph.svg',
              label: 'DOWN',
              isActive: mqtt.isPhDownPumpOn,
              onTap: () => mqtt.setPhDownPump(!mqtt.isPhDownPumpOn),
              activeColor: const Color(0xFFFF5722),
              showDownArrow: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutrientControls() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNutrientButton(
              label: 'A',
              isActive: mqtt.isNutrientAPumpOn,
              onTap: () => mqtt.setNutrientAPump(!mqtt.isNutrientAPumpOn),
            ),
            const SizedBox(width: 40),
            _buildNutrientButton(
              label: 'B',
              isActive: mqtt.isNutrientBPumpOn,
              onTap: () => mqtt.setNutrientBPump(!mqtt.isNutrientBPumpOn),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required String svgPath,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
    bool showUpArrow = false,
    bool showDownArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? activeColor : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? activeColor.withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isActive ? 16 : 8,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 36,
                  height: 36,
                  colorFilter: ColorFilter.mode(
                    isActive ? activeColor : _darkBlue,
                    BlendMode.srcIn,
                  ),
                ),
                if (showUpArrow)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 18,
                      color: isActive ? activeColor : _darkBlue,
                    ),
                  ),
                if (showDownArrow)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: isActive ? activeColor : _darkBlue,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const Color nutrientColor = Color(0xFFFCEE21);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? nutrientColor : Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? nutrientColor.withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: isActive ? 16 : 8,
                  spreadRadius: isActive ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/icon_nutrients.svg',
                    width: 36,
                    height: 36,
                    colorFilter: ColorFilter.mode(
                      isActive ? nutrientColor : _darkBlue,
                      BlendMode.srcIn,
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? nutrientColor : _primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? Colors.black87 : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'NUTRIENT $label',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            iconPath: 'assets/images/icon_camera.svg',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, '/camera'),
          ),
          _buildNavItem(
            iconPath: 'assets/images/icon_home.svg',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          _buildNavItem(
            iconPath: 'assets/images/icon_controlling.svg',
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(
              isActive ? _darkBlue : Colors.white.withOpacity(0.7),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
