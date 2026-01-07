import 'package:flutter/material.dart';

/// Widget chat bubble untuk Tumu
class ChatBubble extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final bool showTail;
  final TailPosition tailPosition;

  const ChatBubble({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFF4CAF50),
    this.showTail = true,
    this.tailPosition = TailPosition.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: showTail
          ? ChatBubblePainter(
              color: backgroundColor,
              tailPosition: tailPosition,
            )
          : null,
      child: Container(
        margin: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: showTail ? 12 : 8, // Space for tail
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quote icon
            Icon(
              Icons.format_quote,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),

            const SizedBox(width: 12),

            // Message text
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Posisi tail chat bubble
enum TailPosition {
  bottom, // Tail di bawah (pointing ke mascot)
  left, // Tail di kiri
  right, // Tail di kanan
}

/// Custom painter untuk tail chat bubble
class ChatBubblePainter extends CustomPainter {
  final Color color;
  final TailPosition tailPosition;

  ChatBubblePainter({
    required this.color,
    required this.tailPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (tailPosition) {
      case TailPosition.bottom:
        _drawBottomTail(path, size);
        break;
      case TailPosition.left:
        _drawLeftTail(path, size);
        break;
      case TailPosition.right:
        _drawRightTail(path, size);
        break;
    }

    canvas.drawPath(path, paint);

    // Shadow untuk tail
    canvas.drawShadow(
      path,
      color.withOpacity(0.3),
      8.0,
      true,
    );
  }

  /// Tail pointing ke bawah (untuk mascot di bawah bubble)
  void _drawBottomTail(Path path, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height - 12;

    path.moveTo(centerX - 15, bottomY);
    path.lineTo(centerX, bottomY + 12);
    path.lineTo(centerX + 15, bottomY);
    path.close();
  }

  /// Tail pointing ke kiri
  void _drawLeftTail(Path path, Size size) {
    final leftX = 24.0;
    final centerY = size.height / 2;

    path.moveTo(leftX, centerY - 10);
    path.lineTo(leftX - 12, centerY);
    path.lineTo(leftX, centerY + 10);
    path.close();
  }

  /// Tail pointing ke kanan
  void _drawRightTail(Path path, Size size) {
    final rightX = size.width - 24;
    final centerY = size.height / 2;

    path.moveTo(rightX, centerY - 10);
    path.lineTo(rightX + 12, centerY);
    path.lineTo(rightX, centerY + 10);
    path.close();
  }

  @override
  bool shouldRepaint(ChatBubblePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.tailPosition != tailPosition;
  }
}
