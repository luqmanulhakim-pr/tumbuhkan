import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MascotWidget extends StatelessWidget {
  const MascotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.18,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFFFFE0B2),
                    Color(0xFFFFECB3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // Mascot
          Positioned(
            bottom: screenHeight * 0.03,
            child: Container(
              // ✅ FIX: Proper BoxDecoration with boxShadow
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                'assets/images/tumu.svg',
                height: screenHeight * 0.24,
                placeholderBuilder: (context) =>
                    _buildFallbackMascot(screenHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackMascot(double screenHeight) {
    return Container(
      height: screenHeight * 0.24,
      width: screenHeight * 0.24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenHeight * 0.12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
          SizedBox(height: 12),
          Text(
            'Tumu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
