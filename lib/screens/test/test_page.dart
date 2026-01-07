import 'package:flutter/material.dart';
import 'package:tumbuhkan/models/mascot_state.dart';
import 'package:tumbuhkan/widgets/home/tumu_mascot.dart';
import 'package:tumbuhkan/widgets/home/sensor_bar.dart';
import 'package:tumbuhkan/screens/home/sensor_grid.dart';

class TestTumuScreen extends StatefulWidget {
  const TestTumuScreen({super.key});

  @override
  State<TestTumuScreen> createState() => _TestTumuScreenState();
}

class _TestTumuScreenState extends State<TestTumuScreen> {
  MascotState _currentState = MascotState.normal;
  int _selectedTab = 0; // 0 = Mascot Test, 1 = Sensor Test

  // 🆕 Mock sensor data
  double _waterLevel = 75;
  double _phValue = 7.5;
  double _nutrientPpm = 1200;
  double _temperature = 28;
  final double _humidity = 65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF33A8DB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Selector
            _buildTabSelector(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _selectedTab == 0
                    ? _buildMascotTest()
                    : _selectedTab == 1
                        ? _buildSensorTest()
                        : _buildChatTest(), // 🆕 TAB CHAT
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1976D2),
            const Color(0xFF33A8DB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'TUMU TEST LAB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedTab == 0
                ? 'Rive Animation Testing'
                : 'Sensor Widget Testing',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB SELECTOR
  // ═══════════════════════════════════════════════════════════
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab('Mascot', 0, Icons.emoji_nature)),
          Expanded(child: _buildTab('Sensors', 1, Icons.sensors)),
          Expanded(
              child: _buildTab('Chat', 2, Icons.chat_bubble)), // 🆕 TAB BARU
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1976D2) : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MASCOT TEST (Existing)
  // ═══════════════════════════════════════════════════════════
  Widget _buildMascotTest() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildMascot(),
        const SizedBox(height: 30),
        _buildStateInfo(),
        const SizedBox(height: 30),
        _buildStateSelector(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMascot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TumuMascot(
        state: _currentState,
        size: 280,
      ),
    );
  }

  Widget _buildStateInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentState.color.withOpacity(0.1),
            _currentState.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _currentState.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentState.color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _currentState.color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _currentState.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _currentState.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentState.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentState.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSelector() {
    return Column(
      children: [
        Text(
          'TAP TO CHANGE STATE',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: MascotState.values.map((state) {
              final isSelected = state == _currentState;
              return _buildStateButton(state, isSelected);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStateButton(MascotState state, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: state.color.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentState = state),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        state.color,
                        state.color.withOpacity(0.8),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white,
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? state.color : Colors.grey.shade300,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 SENSOR TEST
  // ═══════════════════════════════════════════════════════════
  Widget _buildSensorTest() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Sensor Grid
        SensorGrid(
          waterLevel: _waterLevel,
          phValue: _phValue,
          nutrientPpm: _nutrientPpm,
          temperature: _temperature,
          humidity: _humidity,
        ),

        const SizedBox(height: 30),

        // Controls
        _buildSensorControls(),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSensorControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'ADJUST SENSOR VALUES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildSlider('Water', _waterLevel, 0, 100, (val) {
            setState(() => _waterLevel = val);
          }),
          _buildSlider('pH', _phValue, 0, 14, (val) {
            setState(() => _phValue = val);
          }),
          _buildSlider('Nutrient', _nutrientPpm, 0, 2000, (val) {
            setState(() => _nutrientPpm = val);
          }),
          _buildSlider('Temp', _temperature, 0, 50, (val) {
            setState(() => _temperature = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              activeColor: const Color(0xFF1976D2),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🆕 CHAT BUBBLE TEST
  // ═══════════════════════════════════════════════════════════
  Widget _buildChatTest() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: const Text(
            'CHAT BUBBLE PREVIEW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Chat bubbles untuk semua state
        ...MascotState.values.map((state) {
          return Column(
            children: [
              AnimatedChatBubble(
                message: state.message,
                backgroundColor: state.color,
                showTail: true,
              ),
              const SizedBox(height: 20),
            ],
          );
        }),

        const SizedBox(height: 40),
      ],
    );
  }
}

class AnimatedChatBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final bool showTail;

  const AnimatedChatBubble({
    super.key,
    required this.message,
    required this.backgroundColor,
    this.showTail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tail
              if (showTail)
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                ),

              // Message bubble
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
