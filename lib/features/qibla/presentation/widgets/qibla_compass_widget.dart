import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart' as compass;

import '../../../../core/theme/islamic_theme.dart';
import '../../domain/entities/qibla_direction.dart';

/// Beautiful Qibla compass widget with Islamic design
class QiblaCompassWidget extends StatefulWidget {
  const QiblaCompassWidget({
    super.key,
    required this.qiblaDirection,
    required this.pulseAnimation,
  });

  final QiblaDirection qiblaDirection;
  final Animation<double> pulseAnimation;

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget> {
  double? _compassHeading;
  StreamSubscription<compass.CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _startCompassListener();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _startCompassListener() {
    _compassSubscription = compass.FlutterCompass.events?.listen((compass.CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _compassHeading = event.heading;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_compassHeading == null) {
      return _buildCompassPlaceholder();
    }

    final qiblaAngle = widget.qiblaDirection.bearing - _compassHeading!;
    
    return AnimatedBuilder(
      animation: widget.pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.pulseAnimation.value,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle with Islamic pattern
                _buildOuterCircle(),
                
                // Inner circle
                _buildInnerCircle(),
                
                // Compass markings
                ...List.generate(8, (index) => _buildCompassMark(index * 45)),
                
                // Cardinal directions
                ..._buildCardinalDirections(),
                
                // Qibla direction arrow
                Transform.rotate(
                  angle: qiblaAngle * (pi / 180),
                  child: _buildQiblaArrow(),
                ),
                
                // Center Kaaba icon
                _buildCenterIcon(),
                
                // Direction text
                Positioned(
                  bottom: 20,
                  child: _buildDirectionText(qiblaAngle),
                ),
                
                // Accuracy indicator
                Positioned(
                  top: 20,
                  child: _buildAccuracyIndicator(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompassPlaceholder() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildOuterCircle(),
          _buildInnerCircle(),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.compass_calibration,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Calibrating Compass...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOuterCircle() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerCircle() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildCompassMark(double angle) {
    return Transform.rotate(
              angle: angle * (pi / 180),
      child: SizedBox(
        width: 280,
        height: 280,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 2,
            height: 20,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCardinalDirections() {
    const directions = [
      {'label': 'N', 'angle': 0.0, 'arabic': 'شمال', 'bengali': 'উত্তর'},
      {'label': 'E', 'angle': 90.0, 'arabic': 'شرق', 'bengali': 'পূর্ব'},
      {'label': 'S', 'angle': 180.0, 'arabic': 'جنوب', 'bengali': 'দক্ষিণ'},
      {'label': 'W', 'angle': 270.0, 'arabic': 'غرب', 'bengali': 'পশ্চিম'},
    ];

    return directions.map((direction) {
      final angle = direction['angle'] as double;
      final label = direction['label'] as String;
      final arabic = direction['arabic'] as String;
      final bengali = direction['bengali'] as String;
      
      return Transform.rotate(
        angle: angle * (pi / 180),
        child: Transform.translate(
          offset: const Offset(0, -110),
          child: Transform.rotate(
            angle: -angle * (pi / 180),
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  arabic,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  bengali,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildQiblaArrow() {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: QiblaArrowPainter(),
      ),
    );
  }

  Widget _buildCenterIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🕋',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildDirectionText(double angle) {
    final degrees = angle.abs().round();
    String direction;
    String arabicDirection;
    String bengaliDirection;
    
    if (degrees < 15 || degrees > 345) {
      direction = 'Perfect Direction';
      arabicDirection = 'اتجاه مثالي';
      bengaliDirection = 'নিখুঁত দিক';
    } else if (degrees < 90) {
      direction = 'Turn Right';
      arabicDirection = 'اتجه يميناً';
      bengaliDirection = 'ডান দিকে ঘুরুন';
    } else if (degrees < 270) {
      direction = 'Turn Around';
      arabicDirection = 'استدر';
      bengaliDirection = 'ঘুরে যান';
    } else {
      direction = 'Turn Left';
      arabicDirection = 'اتجه يساراً';
      bengaliDirection = 'বাম দিকে ঘুরুন';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            direction,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: IslamicTheme.islamicGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            arabicDirection,
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: IslamicTheme.islamicGreen,
            ),
          ),
          Text(
            bengaliDirection,
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: IslamicTheme.islamicGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyIndicator() {
    final accuracyLevel = widget.qiblaDirection.accuracyLevel;
    Color indicatorColor;
    String accuracyText;
    
    switch (accuracyLevel) {
      case QiblaAccuracy.excellent:
        indicatorColor = Colors.green;
        accuracyText = 'Excellent';
        break;
      case QiblaAccuracy.good:
        indicatorColor = Colors.orange;
        accuracyText = 'Good';
        break;
      case QiblaAccuracy.fair:
        indicatorColor = Colors.red;
        accuracyText = 'Fair';
        break;
      case QiblaAccuracy.poor:
        indicatorColor = Colors.red;
        accuracyText = 'Poor';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        accuracyText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Custom painter for Qibla arrow
class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw arrow shaft
    final shaftPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(
      Offset(center.dx, center.dy + 40),
      Offset(center.dx, 20),
      shaftPaint,
    );
    
    // Draw arrow head
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, 20);
    arrowPath.lineTo(center.dx - 15, 50);
    arrowPath.lineTo(center.dx + 15, 50);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, arrowPaint);
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = IslamicTheme.islamicGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(arrowPath, outlinePaint);
    
    // Draw Islamic star pattern around arrow
    _drawIslamicStar(canvas, center, 80);
  }
  
  void _drawIslamicStar(Canvas canvas, Offset center, double radius) {
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const points = 8;
    final angleStep = 2 * pi / points;
    
    for (int i = 0; i < points; i++) {
      final angle1 = i * angleStep;
      final angle2 = (i + 2) * angleStep;
      
      final point1 = Offset(
        center.dx + radius * cos(angle1),
        center.dy + radius * sin(angle1),
      );
      final point2 = Offset(
        center.dx + radius * cos(angle2),
        center.dy + radius * sin(angle2),
      );
      
      canvas.drawLine(point1, point2, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
