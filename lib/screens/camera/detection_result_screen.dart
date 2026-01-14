import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/disease_detection_result.dart';

class DetectionResultScreen extends StatelessWidget {
  final DiseaseDetectionResult result;

  const DetectionResultScreen({super.key, required this.result});

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
                      'Hasil Deteksi',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status Icon
                      _buildStatusIcon(),
                      const SizedBox(height: 16),

                      // Disease Name
                      Text(
                        result.displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(result.statusColorValue),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Confidence
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Color(result.statusColorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Confidence: ${result.confidencePercent}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(result.statusColorValue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Annotated Image
                      if (result.imageBase64 != null) _buildAnnotatedImage(),

                      const SizedBox(height: 24),

                      // Suggestion Card
                      _buildSuggestionCard(),

                      const SizedBox(height: 24),

                      // Action Buttons
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    final isHealthy = result.isHealthy;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Color(result.statusColorValue).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(result.statusColorValue),
          width: 3,
        ),
      ),
      child: Icon(
        isHealthy ? Icons.check_circle : Icons.warning_rounded,
        size: 48,
        color: Color(result.statusColorValue),
      ),
    );
  }

  Widget _buildAnnotatedImage() {
    try {
      final bytes = base64Decode(result.imageBase64!);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Gagal memuat gambar'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Error decoding image'),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSuggestionCard() {
    final isHealthy = result.isHealthy;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHealthy
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFFFFB74D).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.tips_and_updates : Icons.medical_services,
                color: isHealthy
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF9800),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isHealthy ? 'Tips Perawatan' : 'Saran Penanganan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHealthy
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.suggestion,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Retake button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Ambil Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF29ABFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to home
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.popUntil(
              context,
              ModalRoute.withName('/home'),
            ),
            icon: const Icon(Icons.home),
            label: const Text('Kembali ke Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF29ABFF),
              side: const BorderSide(color: Color(0xFF29ABFF)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
