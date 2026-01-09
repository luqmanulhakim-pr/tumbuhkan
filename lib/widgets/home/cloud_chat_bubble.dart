import 'package:flutter/material.dart';

class CloudChatBubble extends StatelessWidget {
  final String message;
  final Color accentColor;

  const CloudChatBubble({
    super.key,
    required this.message,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white.withOpacity(0.95);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withOpacity(0.6),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            maxLines: 4, // ✅ Allow more lines
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF16324F),
              fontSize: 12, // ✅ Smaller font for better fit
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: 0.2,
            ),
          ),
        ),

        // Cloud bumps - ✅ Adjusted positions
        Positioned(
          top: -8,
          left: 16,
          child: _CloudBump(
            color: bg,
            borderColor: accentColor.withOpacity(0.6),
            size: 16,
          ),
        ),
        Positioned(
          top: -12,
          left: 34,
          child: _CloudBump(
            color: bg,
            borderColor: accentColor.withOpacity(0.6),
            size: 20,
          ),
        ),
        Positioned(
          top: -8,
          left: 56,
          child: _CloudBump(
            color: bg,
            borderColor: accentColor.withOpacity(0.6),
            size: 14,
          ),
        ),

        // Tail pointing left - ✅ Better position
        Positioned(
          left: -8,
          top: 20,
          child: CustomPaint(
            size: const Size(14, 12),
            painter: _TailPainter(
              fill: bg,
              stroke: accentColor.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloudBump extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final double size;

  const _CloudBump({
    required this.color,
    required this.borderColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2.5),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color fill;
  final Color stroke;

  _TailPainter({required this.fill, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
