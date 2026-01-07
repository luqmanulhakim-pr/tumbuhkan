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
    final bg = Colors.white.withOpacity(0.92);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withOpacity(0.55), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF16324F),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),

        // Cloud bumps (top decorations)
        Positioned(
          top: -10,
          left: 14,
          child: _CloudBump(color: bg, borderColor: accentColor.withOpacity(0.55), size: 18),
        ),
        Positioned(
          top: -16,
          left: 34,
          child: _CloudBump(color: bg, borderColor: accentColor.withOpacity(0.55), size: 24),
        ),
        Positioned(
          top: -10,
          left: 62,
          child: _CloudBump(color: bg, borderColor: accentColor.withOpacity(0.55), size: 18),
        ),

        // Tail pointing left (toward sensor panel)
        Positioned(
          left: -10,
          top: 18,
          child: CustomPaint(
            size: const Size(16, 14),
            painter: _TailPainter(fill: bg, stroke: accentColor.withOpacity(0.55)),
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
        border: Border.all(color: borderColor, width: 2),
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
    final fillPaint = Paint()..color = fill..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = stroke..style = PaintingStyle.stroke..strokeWidth = 2;

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
