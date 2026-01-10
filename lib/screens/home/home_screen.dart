import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/mascot_state.dart';
import '../../services/mqtt_service.dart';
import '../../services/mascot_service.dart';
import '../../widgets/home/tumu_mascot.dart';
import '../../widgets/chatbot_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AudioPlayer _audioPlayer;
  late AudioPlayer _introPlayer;
  bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final mqttService = context.read<MqttService>();
      final mascotService = context.read<MascotService>();

      mqttService.setMascotService(mascotService);

      if (!mqttService.isConnected) {
        mqttService.connect();
      }

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && mqttService.isConnected) {
          mascotService.updateState(
            temperature: mqttService.airTemperature,
            phValue: mqttService.ph,
            nutrientLevel: mqttService.tds,
            waterLevel: mqttService.waterLevel,
            isConnected: mqttService.isConnected,
          );
        }
      });
    });
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _introPlayer = AudioPlayer();

    // Setup background music player
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(0.3); // 30% volume

    // Setup intro player (play once)
    _introPlayer.setReleaseMode(ReleaseMode.release);
    _introPlayer.setVolume(0.5); // 50% volume for intro

    // Play intro first, then background music
    _playIntroThenBackground();
  }

  Future<void> _playIntroThenBackground() async {
    try {
      // Play intro audio
      await _introPlayer.play(AssetSource('soundbg/TumuTime.mp3'));
      setState(() => _isMusicPlaying = true);

      // Listen for completion to start background music
      _introPlayer.onPlayerComplete.listen((event) {
        _playBackgroundMusic();
      });
    } catch (e) {
      debugPrint('Error playing intro: $e');
      // If intro fails, try playing background music directly
      _playBackgroundMusic();
    }
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _audioPlayer.play(AssetSource('soundbg/Enjoy.mp3'));
      if (mounted) {
        setState(() => _isMusicPlaying = true);
      }
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  void _toggleMusic() {
    if (_isMusicPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    setState(() => _isMusicPlaying = !_isMusicPlaying);
  }

  @override
  void dispose() {
    _introPlayer.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/bghomescreen.svg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      _buildTopSection(),
                      const SizedBox(height: 10),
                      _buildChatBubbles(),
                    ],
                  ),
                ),
                Expanded(child: _buildMascotSection()),
                _buildBottomNav(),
              ],
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 120,
            child: ChatBotFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: _buildSensorBars(),
        ),
        const Spacer(),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSensorBars() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorBar(
              iconPath: 'assets/images/icon_water.svg',
              label: 'Lv. ${mqtt.waterLevel.toStringAsFixed(0)}',
              value: mqtt.waterLevel,
              maxValue: 100,
              color: const Color(0xFF29ABFF),
            ),
            const SizedBox(height: 6),
            _buildSensorBar(
              iconPath: 'assets/images/icon_ph.svg',
              label: mqtt.ph.toStringAsFixed(1),
              value: mqtt.ph,
              maxValue: 14,
              color: const Color(0xFF00A99D),
            ),
            const SizedBox(height: 6),
            _buildSensorBar(
              iconPath: 'assets/images/icon_nutrients.svg',
              label: '${mqtt.tds.toStringAsFixed(0)} ppm',
              value: mqtt.tds,
              maxValue: 2000,
              color: const Color(0xFFFCEE21),
            ),
            const SizedBox(height: 10),
            _buildTemperatureInfo(mqtt),
          ],
        );
      },
    );
  }

  Widget _buildSensorBar({
    required String iconPath,
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: 16,
              height: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureInfo(MqttService mqtt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Temperature & Humidity row
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/icon_tempereture.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '${mqtt.airTemperature.toStringAsFixed(0)}°, ${mqtt.waterTemperature.toStringAsFixed(0)}°, ${mqtt.airHumidity.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29ABFF),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // LDR & Flow row
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/icon_sun.svg',
              width: 20,
              height: 20,
              color: const Color(0xFFFFA000),
            ),
            const SizedBox(width: 6),
            Text(
              '${mqtt.ldr}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFA000),
              ),
            ),
            const SizedBox(width: 16),
            SvgPicture.asset(
              'assets/images/icon_water.svg',
              width: 20,
              height: 20,
              color: const Color(0xFF00BCD4),
            ),
            const SizedBox(width: 6),
            Text(
              '${mqtt.flow.toStringAsFixed(1)} L/m',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00BCD4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          'assets/images/icon_setting.svg',
          () => Navigator.pushNamed(context, '/settings'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'assets/images/icon_log.svg',
          () => Navigator.pushNamed(context, '/log'),
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          'assets/images/icon_camera.svg',
          () => Navigator.pushNamed(context, '/monitoring'),
        ),
        const SizedBox(height: 8),
        _buildMusicButton(),
      ],
    );
  }

  Widget _buildActionButton(String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonWithIcon(
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMusicButton() {
    return GestureDetector(
      onTap: _toggleMusic,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isMusicPlaying ? const Color(0xFF29ABFF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _isMusicPlaying ? Icons.music_note : Icons.music_off,
            size: 20,
            color: _isMusicPlaying ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubbles() {
    return Consumer2<MascotService, MqttService>(
      builder: (context, mascot, mqtt, _) {
        final state = mascot.currentState;
        final hasAction = state.hasAction;

        return Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main message bubble
              GestureDetector(
                onTap: hasAction ? () => _triggerAction(mascot, mqtt) : null,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: state.color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: state.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Action bubble (if has action) or default message
              GestureDetector(
                onTap: hasAction ? () => _triggerAction(mascot, mqtt) : null,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasAction ? Colors.white : state.color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    border: hasAction
                        ? Border.all(color: state.color, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: state.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasAction) ...[
                        Icon(state.actionIcon, size: 16, color: state.color),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        hasAction ? state.actionLabel : 'Jaga terus ya!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: hasAction ? state.color : Colors.white,
                        ),
                      ),
                      if (hasAction) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.touch_app,
                            size: 14, color: state.color.withOpacity(0.7)),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _triggerAction(MascotService mascot, MqttService mqtt) {
    final state = mascot.currentState;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(state.actionIcon, color: state.color),
            const SizedBox(width: 12),
            Text(state.actionLabel),
          ],
        ),
        content: Text(_getActionDescription(mascot)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeAction(mascot, mqtt);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: state.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Ya, Aktifkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getActionDescription(MascotService mascot) {
    final state = mascot.currentState;

    switch (state) {
      case MascotState.unstablePh:
        if (mascot.isPhLow) {
          return 'pH saat ini ${mascot.lastPhValue.toStringAsFixed(1)} (rendah). Aktifkan pompa pH UP?';
        } else {
          return 'pH saat ini ${mascot.lastPhValue.toStringAsFixed(1)} (tinggi). Aktifkan pompa pH DOWN?';
        }
      case MascotState.lowNutrient:
        return 'Nutrisi saat ini ${mascot.lastNutrientLevel.toStringAsFixed(0)} ppm. Aktifkan pompa nutrisi AB Mix?';
      case MascotState.lowLevelWater:
        return 'Level air saat ini ${mascot.lastWaterLevel.toStringAsFixed(0)} cm. Aktifkan pompa air?';
      case MascotState.highTemperature:
        return 'Suhu saat ini ${mascot.lastTemperature.toStringAsFixed(1)}°C. Aktifkan kipas?';
      default:
        return 'Aktifkan aksi ini?';
    }
  }

  void _executeAction(MascotService mascot, MqttService mqtt) {
    final state = mascot.currentState;

    switch (state) {
      case MascotState.unstablePh:
        if (mascot.isPhLow) {
          mqtt.setPhUpPump(true);
          _showSuccessSnackbar('Pompa pH UP diaktifkan');
        } else {
          mqtt.setPhDownPump(true);
          _showSuccessSnackbar('Pompa pH DOWN diaktifkan');
        }
        break;
      case MascotState.lowNutrient:
        mqtt.setNutrientAPump(true);
        _showSuccessSnackbar('Pompa Nutrisi AB Mix diaktifkan');
        break;
      case MascotState.lowLevelWater:
        mqtt.setPump(true);
        _showSuccessSnackbar('Pompa Air diaktifkan');
        break;
      case MascotState.highTemperature:
        mqtt.setGrowLight(
            true); // FAN menggunakan relay yang sama dengan LED logic
        _showSuccessSnackbar('Kipas diaktifkan');
        break;
      default:
        break;
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildMascotSection() {
    return Consumer<MascotService>(
      builder: (context, mascot, _) {
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxHeight;
              return Transform.translate(
                offset: const Offset(0, -100),
                child: Align(
                  alignment: Alignment.center,
                  child: TumuMascot(
                    state: mascot.currentState,
                    size: size,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Stack(
      children: [
        Container(
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF29ABFF),
            borderRadius: const BorderRadius.vertical(
              top: Radius.elliptical(200, 30),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29ABFF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem('assets/images/icon_camera.svg', false, () {
                  Navigator.pushNamed(context, '/camera');
                }),
                _buildNavItem('assets/images/icon_home.svg', true, () {}),
                _buildNavItem('assets/images/icon_controlling.svg', false, () {
                  Navigator.pushNamed(context, '/controller');
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(String iconPath, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 28,
          height: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

class WaterPipePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.15,
        size.width * 0.7,
        size.height * 0.15,
      )
      ..lineTo(size.width, size.height * 0.15);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
