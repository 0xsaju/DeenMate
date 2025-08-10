import 'package:flutter/material.dart';

/// Islamic gradient background with subtle pattern
class IslamicGradientBackground extends StatelessWidget {

  const IslamicGradientBackground({
    required this.child, super.key,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
  });
  final Widget child;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor ?? const Color(0xFFF5F5DC),
            secondaryColor ?? const Color(0xFFFAF0E6),
            accentColor ?? const Color(0xFFFFF8DC),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Islamic pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(),
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}

/// Custom painter for Islamic geometric pattern
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE6D4B7).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFE6D4B7).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw Islamic pattern
    for (var x = 0; x < size.width; x += 80) {
      for (var y = 0; y < size.height; y += 80) {
        final center = Offset(x + 40, y + 40);
        
        // Outer circle
        canvas.drawCircle(center, 25, paint);
        
        // Inner circle
        canvas.drawCircle(center, 12, paint);
        
        // Diamond shape
        final path = Path();
        path.moveTo(center.dx, center.dy - 25);
        path.lineTo(center.dx + 15, center.dy);
        path.lineTo(center.dx, center.dy + 25);
        path.lineTo(center.dx - 15, center.dy);
        path.close();
        canvas.drawPath(path, paint);
        
        // Inner diamond
        final innerPath = Path();
        innerPath.moveTo(center.dx, center.dy - 12);
        innerPath.lineTo(center.dx + 8, center.dy);
        innerPath.lineTo(center.dx, center.dy + 12);
        innerPath.lineTo(center.dx - 8, center.dy);
        innerPath.close();
        canvas.drawPath(innerPath, fillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
