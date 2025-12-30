import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
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

    // 🆕 Debug print dengan info sumber stream
    debugPrint('═══════════════════════════════════════');
    debugPrint('🟡 [MONITORING SCREEN] Settings loaded:');
    debugPrint(
        '🟡 Stream Source: ${settings.useEsp32CamForStream ? "ESP32-CAM" : "Flask Webcam"}');
    debugPrint('🟡 Stream URL: ${settings.streamUrl}');
    debugPrint('🟡 Stream running: $_isStreamRunning');
    debugPrint('═══════════════════════════════════════');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Live Monitoring'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 🆕 Stream Source Indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  settings.useEsp32CamForStream ? Icons.videocam : Icons.laptop,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  settings.useEsp32CamForStream ? 'ESP32-CAM' : 'Flask',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // MQTT Status
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mqtt.isConnected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mqtt.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 16,
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
          )
        ],
      ),
      body: Column(
        children: [
          // =============================================
          // VIDEO STREAM SECTION (60% height)
          // =============================================
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🆕 Gunakan settings.streamUrl (dynamic)
                  Mjpeg(
                    isLive: _isStreamRunning,
                    stream: settings.streamUrl, // ✅ Pakai streamUrl dynamic
                    error: (context, error, stack) {
                      debugPrint('🔴 [MONITORING SCREEN] Stream error: $error');
                      return _buildOfflinePlaceholder(settings);
                    },
                    loading: (context) {
                      debugPrint('🟡 [MONITORING SCREEN] Stream loading...');
                      return _buildLoadingIndicator(settings);
                    },
                  ),

                  // LIVE Badge
                  if (_isStreamRunning)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
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
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // =============================================
          // STATISTICS SECTION (40% height + scrollable)
          // =============================================
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: Color(0xFF1976D2),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Statistik Pertumbuhan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Berdasarkan analisis AI terakhir',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statistics Cards
                    Row(
                      children: [
                        _buildStatCard(
                          icon: Icons.height,
                          label: 'Tinggi',
                          value: AppConstants.plantHeight,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.eco,
                          label: 'Daun',
                          value: AppConstants.plantLeafCount,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          icon: Icons.health_and_safety,
                          label: 'Sehat',
                          value: AppConstants.plantHealthScore,
                          color: Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Harvest Prediction
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1976D2),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Prediksi Panen: ${AppConstants.harvestPrediction}',
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleAnalysisRequest(context, mqtt),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          'Analisis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🆕 Loading Indicator dengan info sumber
  Widget _buildLoadingIndicator(SettingsService settings) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            'Menghubungkan...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  settings.useEsp32CamForStream ? Icons.videocam : Icons.laptop,
                  size: 12,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  settings.useEsp32CamForStream ? 'ESP32-CAM' : 'Flask Webcam',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Offline Placeholder dengan info sumber
  Widget _buildOfflinePlaceholder(SettingsService settings) {
    final streamUrl = settings.streamUrl;
    final isEsp32Cam = settings.useEsp32CamForStream;

    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEsp32Cam ? Icons.videocam_off : Icons.laptop_chromebook,
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
            isEsp32Cam
                ? 'Pastikan ESP32-CAM aktif\ndan terhubung ke WiFi yang sama.'
                : 'Pastikan Flask server berjalan\ndan IP sudah benar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEsp32Cam ? Icons.videocam : Icons.laptop,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEsp32Cam ? 'ESP32-CAM' : 'Flask Webcam',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  streamUrl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('🟡 [MONITORING SCREEN] Retry stream connection...');
              setState(() {
                _isStreamRunning = false;
              });
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _isStreamRunning = true;
                  });
                }
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAnalysisRequest(BuildContext context, MqttService mqtt) {
    if (mqtt.isConnected) {
      debugPrint('🟢 [MONITORING SCREEN] Sending capture command via MQTT');
      mqtt.publishCaptureCommand();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.send, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mengirim perintah analisis...',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1976D2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      debugPrint('🔴 [MONITORING SCREEN] MQTT not connected');
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
