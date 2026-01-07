import 'package:flutter/material.dart';

class AnimatedChatBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final bool showTail;

  const AnimatedChatBubble({
    super.key,
    required this.message,
    required this.backgroundColor,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Chat Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quote icon
                const Icon(
                  Icons.format_quote,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),

                // Message text
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Tail (triangle)
          if (showTail)
            CustomPaint(
              size: const Size(20, 10),
              painter: _TrianglePainter(backgroundColor),
            ),
        ],
      ),
    );
  }
}

/// Custom painter untuk chat bubble tail (triangle)
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2 - 10, 0) // Top left
      ..lineTo(size.width / 2, size.height) // Bottom center (point)
      ..lineTo(size.width / 2 + 10, 0) // Top right
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
