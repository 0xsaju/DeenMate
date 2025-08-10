import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/prayer_times_api_service.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Beautiful Islamic Qibla Compass Screen
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with TickerProviderStateMixin {
  
  double? _qiblaDirection;
  double? _compassHeading;
  bool _hasPermissions = false;
  bool _isLoading = true;
  String _locationStatus = 'Getting location...';
  Position? _currentPosition;
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  
  final PrayerTimesApiService _prayerService = PrayerTimesApiService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCompass();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeCompass() async {
    setState(() {
      _isLoading = true;
      _locationStatus = 'Checking permissions...';
    });

    // Check permissions
    final permissionStatus = await _checkPermissions();
    if (!permissionStatus) {
      setState(() {
        _isLoading = false;
        _locationStatus = 'Permissions required for compass';
        _hasPermissions = false;
      });
      return;
    }

    // Get location
    setState(() {
      _locationStatus = 'Getting your location...';
    });
    
    final position = await _getCurrentLocation();
    if (position == null) {
      setState(() {
        _isLoading = false;
        _locationStatus = 'Unable to get location';
      });
      return;
    }

    // Calculate Qibla direction
    final qiblaDirection = _prayerService.calculateQiblaDirection(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentPosition = position;
      _qiblaDirection = qiblaDirection;
      _locationStatus = 'Compass ready';
      _hasPermissions = true;
      _isLoading = false;
    });

    // Start listening to compass
    _startCompassListener();
  }

  Future<bool> _checkPermissions() async {
    final locationStatus = await Permission.location.request();
    return locationStatus.isGranted;
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  void _startCompassListener() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _compassHeading = event.heading;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              IslamicTheme.islamicGreen,
              IslamicTheme.islamicGreen.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _hasPermissions
                        ? _buildCompassView()
                        : _buildPermissionState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qibla Compass',
                  style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'কিবলার দিক | اتجاه القبلة',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _initializeCompass,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            _locationStatus,
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Location Permission Required',
              style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To show the direction to Mecca, we need access to your location and device compass.',
              style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initializeCompass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: IslamicTheme.islamicGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView() {
    if (_qiblaDirection == null || _compassHeading == null) {
      return _buildLoadingState();
    }

    final qiblaAngle = _qiblaDirection! - _compassHeading!;
    final distance = _calculateDistanceToMecca();

    return Column(
      children: [
        _buildLocationInfo(),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: _buildCompass(qiblaAngle),
          ),
        ),
        _buildDistanceInfo(distance),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (_currentPosition == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Location',
                  style: IslamicTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
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

  Widget _buildCompass(double qiblaAngle) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                ),
                
                // Inner circle
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                
                // Compass markings
                ...List.generate(8, (index) => _buildCompassMark(index * 45)),
                
                // Qibla direction arrow
                Transform.rotate(
                  angle: qiblaAngle * (math.pi / 180),
                  child: _buildQiblaArrow(),
                ),
                
                // Center Kaaba icon
                _buildCenterIcon(),
                
                // Direction text
                Positioned(
                  bottom: 20,
                  child: _buildDirectionText(qiblaAngle),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompassMark(double angle) {
    return Transform.rotate(
      angle: angle * (math.pi / 180),
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
    
    if (degrees < 15 || degrees > 345) {
      direction = 'Perfect Direction';
    } else if (degrees < 90) {
      direction = 'Turn Right';
    } else if (degrees < 270) {
      direction = 'Turn Around';
    } else {
      direction = 'Turn Left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        direction,
        style: IslamicTheme.textTheme.bodyMedium?.copyWith(
          color: IslamicTheme.islamicGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDistanceInfo(double distance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Distance to Mecca', '${distance.toStringAsFixed(0)} km'),
          _buildInfoItem('Qibla Direction', '${_qiblaDirection!.toStringAsFixed(1)}°'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: IslamicTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  double _calculateDistanceToMecca() {
    if (_currentPosition == null) return 0;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      21.4225, // Kaaba latitude
      39.8262, // Kaaba longitude
    ) / 1000; // Convert to kilometers
  }
}

/// Custom painter for Qibla arrow
class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final arrowPath = Path();
    
    // Draw arrow pointing up
    arrowPath.moveTo(center.dx, 20);
    arrowPath.lineTo(center.dx - 15, 50);
    arrowPath.lineTo(center.dx - 5, 45);
    arrowPath.lineTo(center.dx - 5, center.dy + 40);
    arrowPath.lineTo(center.dx + 5, center.dy + 40);
    arrowPath.lineTo(center.dx + 5, 45);
    arrowPath.lineTo(center.dx + 15, 50);
    arrowPath.close();

    canvas.drawPath(arrowPath, paint);
    
    // Draw outline
    final outlinePaint = Paint()
      ..color = IslamicTheme.islamicGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(arrowPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
