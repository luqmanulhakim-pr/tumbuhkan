import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../services/settings_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  bool _isStreamRunning = true;

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttService>(context);
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF29ABFF),
      body: SafeArea(
        child: Column(
          children: [
            // =============================================
            // HEADER
            // =============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'ESP32-CAM Monitor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Connection status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mqtt.isConnected
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mqtt.isConnected ? Icons.wifi : Icons.wifi_off,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          mqtt.isConnected ? 'Online' : 'Offline',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =============================================
            // STATUS CARDS (Plant Class & Water Condition)
            // =============================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Plant Class Card
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.eco,
                      label: 'Kelas Tumbuhan',
                      value: mqtt.status,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Water Condition Card
                  Expanded(
                    child: _buildStatusCard(
                      icon: Icons.water_drop,
                      label: 'Kondisi Air',
                      value: _getWaterCondition(mqtt),
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =============================================
            // CAMERA SECTION
            // =============================================
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera Stream
                    Mjpeg(
                      isLive: _isStreamRunning,
                      stream: settings.streamUrl,
                      error: (context, error, stack) {
                        return _buildOfflinePlaceholder(settings);
                      },
                      loading: (context) {
                        return _buildLoadingIndicator();
                      },
                    ),

                    // LIVE Badge
                    if (_isStreamRunning)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 6),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Stream source badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              settings.useEsp32CamForStream
                                  ? Icons.videocam
                                  : Icons.laptop,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              settings.useEsp32CamForStream
                                  ? 'ESP32-CAM'
                                  : 'Flask',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Capture button
                    // Positioned(
                    //   bottom: 16,
                    //   child: GestureDetector(
                    //     onTap: () => _handleCapture(context, mqtt),
                    //     child: Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 24,
                    //         vertical: 12,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         borderRadius: BorderRadius.circular(30),
                    //         boxShadow: [
                    //           BoxShadow(
                    //             color: Colors.black.withOpacity(0.3),
                    //             blurRadius: 10,
                    //             offset: const Offset(0, 4),
                    //           ),
                    //         ],
                    //       ),
                    //       child: const Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Icon(
                    //             Icons.camera_alt,
                    //             color: Color(0xFF29ABFF),
                    //             size: 22,
                    //           ),
                    //           SizedBox(width: 8),
                    //           Text(
                    //             'Analisis',
                    //             style: TextStyle(
                    //               color: Color(0xFF29ABFF),
                    //               fontWeight: FontWeight.bold,
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getWaterCondition(MqttService mqtt) {
    // Determine water condition based on sensor readings
    final ph = mqtt.ph;
    final tds = mqtt.tds;

    if (ph >= 5.5 && ph <= 7.0 && tds >= 500 && tds <= 1500) {
      return 'Optimal';
    } else if (ph < 5.0 || ph > 7.5 || tds < 300 || tds > 2000) {
      return 'Perlu Dicek';
    } else {
      return 'Baik';
    }
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Menghubungkan...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflinePlaceholder(SettingsService settings) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            settings.useEsp32CamForStream ? Icons.videocam_off : Icons.laptop,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Kamera Offline',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.useEsp32CamForStream
                ? 'Pastikan ESP32-CAM aktif'
                : 'Pastikan Flask server berjalan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _isStreamRunning = false);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _isStreamRunning = true);
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF29ABFF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCapture(BuildContext context, MqttService mqtt) {
    if (mqtt.isConnected) {
      mqtt.publishCaptureCommand();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Mengirim perintah analisis...'),
            ],
          ),
          backgroundColor: const Color(0xFF29ABFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('MQTT tidak terhubung'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
