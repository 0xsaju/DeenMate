import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/theme/islamic_theme.dart';

class QiblaCompassScreen extends ConsumerStatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  ConsumerState<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends ConsumerState<QiblaCompassScreen> {
  double? _compassDirection;
  double? _qiblaDirection;
  bool _isCalibrating = false;
  String _calibrationMessage = '';
  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    try {
      // Check if compass is available
      final compassAvailable = await FlutterCompass.events?.first;
      if (compassAvailable == null) {
        setState(() {
          _calibrationMessage = 'Compass not available on this device';
        });
        return;
      }

      // Listen to compass events
      _compassSubscription = FlutterCompass.events?.listen((event) {
        setState(() {
          _compassDirection = event.heading;
          
          // Check if compass needs calibration
          if (event.heading == null) {
            _isCalibrating = true;
            _calibrationMessage = 'Please calibrate your compass by moving your device in a figure-8 pattern';
          } else {
            _isCalibrating = false;
            _calibrationMessage = '';
          }
        });
      });
    } catch (e) {
      setState(() {
        _calibrationMessage = 'Error initializing compass: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      
      // Calculate Qibla direction (simplified calculation)
      _calculateQiblaDirection();
    } catch (e) {
      setState(() {
        _calibrationMessage = 'Error getting location: $e';
      });
    }
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;
    
    // Kaaba coordinates
    const kaabaLat = 21.4225;
    const kaabaLng = 39.8262;
    
    // Current position
    final currentLat = _currentPosition!.latitude;
    final currentLng = _currentPosition!.longitude;
    
    // Calculate Qibla direction (simplified)
    final latDiff = kaabaLat - currentLat;
    final lngDiff = kaabaLng - currentLng;
    
    final qiblaAngle = (atan2(lngDiff, latDiff) * 180 / pi);
    
    setState(() {
      _qiblaDirection = qiblaAngle;
    });
  }

  double? get arrowAngle {
    if (_compassDirection == null || _qiblaDirection == null) return null;
    
    // Calculate the angle between compass direction and Qibla direction
    double angle = _qiblaDirection! - _compassDirection!;
    
    // Normalize to 0-360 degrees
    while (angle < 0) angle += 360;
    while (angle >= 360) angle -= 360;
    
    return angle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status indicator
              _buildStatusIndicator(),
              
              // Main compass content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Compass circle
                      _buildCompassCircle(),
                      
                      const SizedBox(height: 30),
                      
                      // Direction text
                      _buildDirectionText(),
                      
                      const SizedBox(height: 20),
                      
                      // Location info
                      _buildLocationInfo(),
                    ],
                  ),
                ),
              ),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_isCalibrating) {
      statusColor = Colors.orange;
      statusText = 'Calibrating Compass';
      statusIcon = Icons.compass_calibration;
    } else if (_compassDirection == null) {
      statusColor = Colors.red;
      statusText = 'Compass Unavailable';
      statusIcon = Icons.error;
    } else {
      statusColor = Colors.green;
      statusText = 'Compass Active';
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassCircle() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Compass markings
          _buildCompassMarkings(),
          
          // Qibla arrow
          if (arrowAngle != null)
            Transform.rotate(
              angle: (arrowAngle! * pi / 180),
              child: _buildQiblaArrow(),
            ),
          
          // Center dot
          Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassMarkings() {
    return CustomPaint(
      size: const Size(280, 280),
      painter: CompassMarkingsPainter(
        primaryColor: Theme.of(context).primaryColor,
        compassHeading: _compassDirection,
      ),
    );
  }

  Widget _buildQiblaArrow() {
    return Center(
      child: Container(
        width: 4,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDirectionText() {
    if (arrowAngle == null) {
      return Text(
        'Calibrating...',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    return Column(
      children: [
        Text(
          'Qibla Direction',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${arrowAngle!.toStringAsFixed(1)}° towards Kaaba',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          if (_currentPosition != null)
            Text(
              '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            Text(
              'Getting location...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _isCalibrating ? null : _recalibrateCompass,
            icon: const Icon(Icons.refresh),
            label: const Text('Recalibrate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.location_on),
            label: const Text('Update Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _recalibrateCompass() {
    setState(() {
      _isCalibrating = true;
      _calibrationMessage = 'Please move your device in a figure-8 pattern to calibrate the compass';
    });
    
    // Reset calibration after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isCalibrating = false;
          _calibrationMessage = '';
        });
      }
    });
  }
}

class CompassMarkingsPainter extends CustomPainter {
  final Color primaryColor;
  final double? compassHeading;
  
  CompassMarkingsPainter({
    required this.primaryColor,
    this.compassHeading,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Draw outer circle
    canvas.drawCircle(center, radius, paint);
    
    // Draw cardinal directions - these should rotate with compass
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];
    
    for (int i = 0; i < directions.length; i++) {
      // Apply compass rotation to the direction markers
      final baseAngle = angles[i] * pi / 180;
      final rotatedAngle = baseAngle - (compassHeading ?? 0) * pi / 180;
      
      final x = center.dx + (radius - 30) * sin(rotatedAngle);
      final y = center.dy - (radius - 30) * cos(rotatedAngle);
      
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
    
    // Draw degree markings
    for (int i = 0; i < 360; i += 30) {
      final angle = i * pi / 180;
      final startRadius = radius - (i % 90 == 0 ? 20 : 10);
      final endRadius = radius;
      
      final startX = center.dx + startRadius * sin(angle);
      final startY = center.dy - startRadius * cos(angle);
      final endX = center.dx + endRadius * sin(angle);
      final endY = center.dy - endRadius * cos(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
