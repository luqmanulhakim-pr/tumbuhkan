import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/mqtt_service.dart';
import '../../models/settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Flask Controllers
  final _flaskIpController = TextEditingController();
  final _flaskPortController = TextEditingController();

  // ESP32-CAM Controllers
  final _esp32IpController = TextEditingController();
  final _esp32PortController = TextEditingController();

  // pH Calibration Controllers
  final _v4Controller = TextEditingController(text: '2.6493');
  final _v7Controller = TextEditingController(text: '2.4192');
  final _v9Controller = TextEditingController(text: '2.2839');

  // TDS Calibration Controllers
  final _v500Controller = TextEditingController();
  final _v1000Controller = TextEditingController();

  bool _isSaving = false;
  bool _useEsp32Cam = true;
  bool _isCalibrating = false;
  bool _isCalibratingTds = false;

  // Calculated TDS coefficients
  double? _tdsM;
  double? _tdsC;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final settings =
        Provider.of<SettingsService>(context, listen: false).settings;

    // Flask
    _flaskIpController.text = settings.flaskIpAddress;
    _flaskPortController.text = settings.flaskPort.toString();

    // ESP32-CAM
    _esp32IpController.text = settings.esp32CamIpAddress;
    _esp32PortController.text = settings.esp32CamPort.toString();

    // Toggle
    _useEsp32Cam = settings.useEsp32CamForStream;
  }

  @override
  void dispose() {
    _flaskIpController.dispose();
    _flaskPortController.dispose();
    _esp32IpController.dispose();
    _esp32PortController.dispose();
    _v4Controller.dispose();
    _v7Controller.dispose();
    _v9Controller.dispose();
    _v500Controller.dispose();
    _v1000Controller.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final settingsService =
          Provider.of<SettingsService>(context, listen: false);

      final newSettings = AppSettings(
        flaskIpAddress: _flaskIpController.text.trim(),
        flaskPort: int.tryParse(_flaskPortController.text) ?? 5000,
        esp32CamIpAddress: _esp32IpController.text.trim(),
        esp32CamPort: int.tryParse(_esp32PortController.text) ?? 80,
        useEsp32CamForStream: _useEsp32Cam,
      );

      await settingsService.saveSettings(newSettings);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Settings tersimpan!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Kembalikan ke pengaturan default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final settingsService =
        Provider.of<SettingsService>(context, listen: false);
    await settingsService.resetToDefaults();
    _loadCurrentSettings();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings direset ke default'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _calibratePh() async {
    // Validate input values
    final v4 = double.tryParse(_v4Controller.text);
    final v7 = double.tryParse(_v7Controller.text);
    final v9 = double.tryParse(_v9Controller.text);

    if (v4 == null || v7 == null || v9 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Masukkan nilai voltase yang valid'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final mqtt = Provider.of<MqttService>(context, listen: false);

    if (!mqtt.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Text('MQTT tidak terhubung'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isCalibrating = true);

    mqtt.publishPhCalibration(v4, v7, v9);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isCalibrating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Kalibrasi pH terkirim! V4=$v4, V7=$v7, V9=$v9'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF29ABFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _calculateTdsCoefficients() {
    final v500 = double.tryParse(_v500Controller.text);
    final v1000 = double.tryParse(_v1000Controller.text);

    if (v500 == null || v1000 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Masukkan nilai voltase yang valid'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if ((v1000 - v500).abs() < 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('V500 dan V1000 tidak boleh sama'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Calculate linear coefficients
    // m = (TDS2 - TDS1) / (V2 - V1) = 500 / (V1000 - V500)
    // c = TDS1 - m * V1 = 500 - m * V500
    final m = 500.0 / (v1000 - v500);
    final c = 500.0 - m * v500;

    setState(() {
      _tdsM = m;
      _tdsC = c;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Koefisien: m=${m.toStringAsFixed(2)}, c=${c.toStringAsFixed(2)}'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _calibrateTds() async {
    if (_tdsM == null || _tdsC == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Hitung koefisien terlebih dahulu'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final mqtt = Provider.of<MqttService>(context, listen: false);

    if (!mqtt.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Text('MQTT tidak terhubung'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isCalibratingTds = true);

    mqtt.publishTdsCalibration(_tdsM!, _tdsC!);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isCalibratingTds = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Kalibrasi TDS terkirim! m=${_tdsM!.toStringAsFixed(2)}, c=${_tdsC!.toStringAsFixed(2)}'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final authService =
        Provider.of<FirebaseAuthService>(context, listen: false);
    await authService.signOut();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
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
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =============================================
            // CONTENT
            // =============================================
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ============================================
                        // SENSOR CALIBRATION SECTION
                        // ============================================
                        _buildSectionTitle(Icons.tune, 'Kalibrasi Sensor'),
                        const SizedBox(height: 12),
                        _buildCalibrationCard(),
                        const SizedBox(height: 16),
                        _buildTdsCalibrationCard(),
                        const SizedBox(height: 24),

                        // ============================================
                        // FLASK SERVER SETTINGS
                        // ============================================
                        _buildSectionTitle(Icons.dns, 'FastAPI Backend Server'),
                        const SizedBox(height: 12),
                        _buildIpAddressField(
                          controller: _flaskIpController,
                          label: 'FastAPI IP Address',
                          hint: '192.168.2.80',
                        ),
                        const SizedBox(height: 12),
                        _buildPortField(
                          controller: _flaskPortController,
                          label: 'FastAPI Port',
                          hint: '5000',
                        ),
                        const SizedBox(height: 24),

                        // ============================================
                        // STREAM SOURCE SELECTION
                        // ============================================
                        _buildSectionTitle(
                            Icons.videocam, 'Video Stream Source'),
                        const SizedBox(height: 12),
                        _buildStreamSourceToggle(),
                        const SizedBox(height: 16),

                        // ============================================
                        // ESP32-CAM SETTINGS (Conditional)
                        // ============================================
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _useEsp32Cam
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle(
                                        Icons.camera_alt, 'ESP32-CAM'),
                                    const SizedBox(height: 12),
                                    _buildIpAddressField(
                                      controller: _esp32IpController,
                                      label: 'ESP32-CAM IP Address',
                                      hint: '192.168.43.100',
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPortField(
                                      controller: _esp32PortController,
                                      label: 'ESP32-CAM Port',
                                      hint: '80',
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ============================================
                        // ACTION BUTTONS
                        // ============================================
                        const SizedBox(height: 8),
                        _buildSaveButton(),
                        const SizedBox(height: 12),
                        _buildResetButton(),
                        const SizedBox(height: 24),

                        // ============================================
                        // ACCOUNT SECTION
                        // ============================================
                        _buildSectionTitle(Icons.person, 'Akun'),
                        const SizedBox(height: 12),
                        _buildLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // UI COMPONENTS
  // ============================================

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF29ABFF), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationCard() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF29ABFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF29ABFF).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kalibrasi pH Sensor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: mqtt.isConnected
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: mqtt.isConnected ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mqtt.isConnected ? Icons.check_circle : Icons.error,
                          size: 14,
                          color: mqtt.isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mqtt.isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mqtt.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current pH Voltage Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.electric_bolt,
                            size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'Current pH Voltage',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'pH Value:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          mqtt.ph.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voltage:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${mqtt.phVoltage.toStringAsFixed(4)} V',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Input fields for V4, V7, V9
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _v4Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'V4 (pH 4)',
                        hintText: '2.6493',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _v7Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'V7 (pH 7)',
                        hintText: '2.4192',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _v9Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'V9 (pH 9)',
                        hintText: '2.2839',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isCalibrating || !mqtt.isConnected)
                      ? null
                      : _calibratePh,
                  icon: _isCalibrating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label:
                      Text(_isCalibrating ? 'Mengirim...' : 'Kirim Kalibrasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mqtt.isConnected
                        ? const Color(0xFF29ABFF)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTdsCalibrationCard() {
    return Consumer<MqttService>(
      builder: (context, mqtt, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kalibrasi TDS Sensor',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: mqtt.isConnected
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: mqtt.isConnected ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mqtt.isConnected ? Icons.check_circle : Icons.error,
                          size: 14,
                          color: mqtt.isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mqtt.isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mqtt.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current TDS Voltage Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.electric_bolt,
                            size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'Current TDS Voltage',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TDS Value:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${mqtt.tds.toStringAsFixed(2)} ppm',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voltage:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${mqtt.tdsVoltage.toStringAsFixed(5)} V',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Input fields for V500 and V1000
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _v500Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'V500 (500 ppm)',
                        hintText: '0.8513',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _v1000Controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'V1000 (1000 ppm)',
                        hintText: '1.4548',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Calculate button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _calculateTdsCoefficients,
                  icon: const Icon(Icons.calculate, size: 18),
                  label: Text(
                    _tdsM != null && _tdsC != null
                        ? 'Hitung Ulang (m=${_tdsM!.toStringAsFixed(2)}, c=${_tdsC!.toStringAsFixed(2)})'
                        : 'Hitung Koefisien m & c',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Send calibration button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      (_isCalibratingTds || !mqtt.isConnected || _tdsM == null)
                          ? null
                          : _calibrateTds,
                  icon: _isCalibratingTds
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(_isCalibratingTds
                      ? 'Mengirim...'
                      : 'Kirim Kalibrasi TDS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (mqtt.isConnected && _tdsM != null)
                        ? Colors.orange
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Rumus: TDS = m × voltage + c\nm = 500 / (V1000 - V500)\nc = 500 - m × V500',
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreamSourceToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          RadioListTile<bool>(
            value: true,
            groupValue: _useEsp32Cam,
            onChanged: (value) {
              setState(() => _useEsp32Cam = value ?? true);
            },
            title: const Text('ESP32-CAM'),
            subtitle: const Text('Real-time monitoring from greenhouse'),
            secondary: const Icon(Icons.videocam, color: Color(0xFF2E7D32)),
            activeColor: const Color(0xFF2E7D32),
          ),
          const Divider(height: 1),
          RadioListTile<bool>(
            value: false,
            groupValue: _useEsp32Cam,
            onChanged: (value) {
              setState(() => _useEsp32Cam = value ?? false);
            },
            title: const Text('Flask Webcam'),
            subtitle: const Text('Testing mode with laptop camera'),
            secondary: const Icon(Icons.laptop, color: Color(0xFF1976D2)),
            activeColor: const Color(0xFF1976D2),
          ),
        ],
      ),
    );
  }

  Widget _buildIpAddressField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.wifi),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter IP address';
        }

        final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
        if (!ipRegex.hasMatch(value)) {
          return 'Invalid IP address format';
        }

        final parts = value.split('.');
        for (var part in parts) {
          final num = int.tryParse(part);
          if (num == null || num < 0 || num > 255) {
            return 'IP address octets must be 0-255';
          }
        }

        return null;
      },
    );
  }

  Widget _buildPortField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.settings_ethernet),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter port';
        }

        final port = int.tryParse(value);
        if (port == null || port < 1 || port > 65535) {
          return 'Port must be between 1-65535';
        }

        return null;
      },
    );
  }

  Widget _buildPreviewCard() {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.green.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Current URLs Preview:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildUrlRow(
                'Stream',
                settings.streamUrl,
                _useEsp32Cam ? '📷 ESP32-CAM' : '💻 Flask',
              ),
              _buildUrlRow('Upload', settings.flaskUploadUrl, '🖥️ Flask'),
              _buildUrlRow(
                  'Growth', settings.flaskUploadGrowthUrl, '🖥️ Flask'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUrlRow(String label, String url, String source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ($source):',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            url,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSettings,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _resetSettings,
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Default'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: const BorderSide(color: Colors.orange, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}
