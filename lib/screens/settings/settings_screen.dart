import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/firebase_auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final settings =
        Provider.of<SettingsService>(context, listen: false).settings;
    _ipController.text = settings.flaskIpAddress;
    _portController.text = settings.flaskPort.toString();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final settingsService =
        Provider.of<SettingsService>(context, listen: false);
    final success = await settingsService.updateFlaskIp(
      _ipController.text.trim(),
      port: int.tryParse(_portController.text) ?? 5000,
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Settings saved successfully!'
            : '❌ Failed to save settings'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
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
    final success = await settingsService.resetToDefault();

    if (success) {
      _loadCurrentSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings reset to default'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
              // Flask Server Settings
              _buildSectionTitle('Flask Server Configuration'),
              const SizedBox(height: 12),
              _buildIpAddressField(),
              const SizedBox(height: 16),
              _buildPortField(),
              const SizedBox(height: 20),

              // Preview URL
              _buildPreviewCard(),
              const SizedBox(height: 20),

              // Action Buttons
              _buildSaveButton(),
              const SizedBox(height: 12),
              _buildResetButton(),
              const SizedBox(height: 40),

              // Logout Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildIpAddressField() {
    return TextFormField(
      controller: _ipController,
      decoration: InputDecoration(
        labelText: 'IP Address',
        hintText: '192.168.1.100',
        prefixIcon: const Icon(Icons.wifi),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildPortField() {
    return TextFormField(
      controller: _portController,
      decoration: InputDecoration(
        labelText: 'Port',
        hintText: '5000',
        prefixIcon: const Icon(Icons.settings_ethernet),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current URLs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildUrlRow('Base URL', settings.flaskBaseUrl),
              _buildUrlRow('Stream', settings.flaskStreamUrl),
              _buildUrlRow('Upload', settings.flaskUploadUrl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUrlRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
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
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Saving...' : 'Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          side: const BorderSide(color: Colors.orange),
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
        ),
      ),
    );
  }
}
