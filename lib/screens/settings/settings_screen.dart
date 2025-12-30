import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/firebase_auth_service.dart';
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

  bool _isSaving = false;
  bool _useEsp32Cam = true;

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
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('✅ Settings saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
              Expanded(child: Text('❌ Error: $e')),
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
        content:
            const Text('Are you sure you want to reset to default settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
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
      const SnackBar(
        content: Text('✅ Settings reset to default'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
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
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // FLASK SERVER SETTINGS
              // ============================================
              _buildSectionTitle('🖥️ Flask Backend Server'),
              const SizedBox(height: 8),
              const Text(
                'For uploading photos and disease detection',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildIpAddressField(
                controller: _flaskIpController,
                label: 'Flask IP Address',
                hint: '192.168.2.80',
              ),
              const SizedBox(height: 16),
              _buildPortField(
                controller: _flaskPortController,
                label: 'Flask Port',
                hint: '5000',
              ),
              const SizedBox(height: 30),

              // ============================================
              // STREAM SOURCE SELECTION
              // ============================================
              _buildSectionTitle('📹 Video Stream Source'),
              const SizedBox(height: 16),
              _buildStreamSourceToggle(),
              const SizedBox(height: 20),

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
                          _buildSectionTitle('📷 ESP32-CAM Configuration'),
                          const SizedBox(height: 8),
                          const Text(
                            'For real-time plant monitoring',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          _buildIpAddressField(
                            controller: _esp32IpController,
                            label: 'ESP32-CAM IP Address',
                            hint: '192.168.43.100',
                          ),
                          const SizedBox(height: 16),
                          _buildPortField(
                            controller: _esp32PortController,
                            label: 'ESP32-CAM Port',
                            hint: '80',
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              // ============================================
              // PREVIEW URLs
              // ============================================
              _buildPreviewCard(),
              const SizedBox(height: 20),

              // ============================================
              // ACTION BUTTONS
              // ============================================
              _buildSaveButton(),
              const SizedBox(height: 12),
              _buildResetButton(),
              const SizedBox(height: 40),

              // ============================================
              // ACCOUNT SECTION
              // ============================================
              _buildSectionTitle('👤 Account'),
              const SizedBox(height: 12),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // UI COMPONENTS
  // ============================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1976D2),
      ),
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
