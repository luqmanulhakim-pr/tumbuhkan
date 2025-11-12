import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import '../../widgets/home/connection_status_indicator.dart';
import '../../widgets/home/bottom_nav_bar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final int _selectedIndex = 0; // Camera tab
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage; // Store captured photo

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // ============================================
  // Initialize Camera
  // ============================================
  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        _showSnackBar('No camera found');
        return;
      }

      // Use back camera (index 0)
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      debugPrint('✅ Camera initialized');
    } catch (e) {
      debugPrint('❌ Camera error: $e');
      _showSnackBar('Failed to initialize camera');
    }
  }

  // ============================================
  // Take Picture
  // ============================================
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showSnackBar('Camera not ready');
      return;
    }

    try {
      // Capture image
      final image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
      });

      debugPrint('📸 Photo captured: ${image.path}');
      _showSnackBar('Photo captured! ✅');

      // TODO: Nanti kirim ke backend
      // await _uploadToBackend(image.path);
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _showSnackBar('Failed to capture photo');
    }
  }

  // ============================================
  // Switch Camera (Front/Back)
  // ============================================
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      _showSnackBar('No other camera available');
      return;
    }

    try {
      // Get current camera index
      final currentIndex = _cameras!.indexOf(_cameraController!.description);
      final newIndex = (currentIndex + 1) % _cameras!.length;

      // Dispose old controller
      await _cameraController?.dispose();

      // Initialize new camera
      _cameraController = CameraController(
        _cameras![newIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
      }

      debugPrint('🔄 Switched to camera: $newIndex');
    } catch (e) {
      debugPrint('❌ Switch camera error: $e');
      _showSnackBar('Failed to switch camera');
    }
  }

  // ============================================
  // Retake Photo
  // ============================================
  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  // TODO: Upload to Backend (implement later)
  // Future<void> _uploadToBackend(String imagePath) async {
  //   // Implementation here
  // }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqtt = Provider.of<MqttService>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(mqtt),
            Expanded(
              child: _capturedImage != null
                  ? _buildPreview()
                  : _isCameraInitialized
                      ? _buildCameraView()
                      : _buildLoading(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index != _selectedIndex) {
            if (index == 1) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 2) {
              Navigator.pushReplacementNamed(context, '/controller');
            }
          }
        },
      ),
    );
  }

  // ============================================
  // Header
  // ============================================
  Widget _buildHeader(MqttService mqtt) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Take plant photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              if (_capturedImage == null && _isCameraInitialized)
                IconButton(
                  icon: const Icon(Icons.flip_camera_android),
                  onPressed: _switchCamera,
                  color: Colors.white,
                  iconSize: 28,
                ),
            ],
          ),
          const SizedBox(height: 12),
          const ConnectionStatusIndicator(),
        ],
      ),
    );
  }

  // ============================================
  // Loading State
  // ============================================
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Camera View
  // ============================================
  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),

        // Capture Button (Bottom center)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),

        // Grid overlay (optional guide)
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(),
          ),
        ),
      ],
    );
  }

  // ============================================
  // Preview Captured Image
  // ============================================
  Widget _buildPreview() {
    return Stack(
      children: [
        // Full screen image
        Positioned.fill(
          child: Image.network(
            _capturedImage!.path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback for file:// path
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Preview not available',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),

        // Action buttons (Bottom)
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Retake button
              _buildActionButton(
                icon: Icons.refresh,
                label: 'Retake',
                onTap: _retakePhoto,
              ),

              // Use/Upload button (TODO: implement)
              _buildActionButton(
                icon: Icons.check,
                label: 'Use Photo',
                onTap: () {
                  _showSnackBar('Ready to upload! (Feature coming soon)');
                  // TODO: Implement upload to backend
                },
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // Action Button Widget
  // ============================================
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF2E7D32)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Show SnackBar
  // ============================================
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}

// ============================================
// Grid Overlay Painter (Optional guide lines)
// ============================================
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
