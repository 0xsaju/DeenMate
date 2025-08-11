import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart' as compass;

import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/localization/strings.dart';

/// Qibla compass calibration widget
class QiblaCalibrationWidget extends StatefulWidget {
  const QiblaCalibrationWidget({super.key});

  @override
  State<QiblaCalibrationWidget> createState() => _QiblaCalibrationWidgetState();
}

class _QiblaCalibrationWidgetState extends State<QiblaCalibrationWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  double? _compassHeading;
  StreamSubscription<compass.CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCompassListener();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ),);
    
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);
    
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCalibrationCompass(),
          const SizedBox(height: 32),
          _buildCalibrationInstructions(),
          const SizedBox(height: 24),
          _buildCalibrationProgress(),
        ],
      ),
    );
  }

  Widget _buildCalibrationCompass() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                
                // Inner circle
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                
                // Rotating calibration indicator
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 3,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                
                // Center icon
                Container(
                  width: 50,
                  height: 50,
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
                    child: Icon(
                      Icons.compass_calibration,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
                
                // Compass heading indicator
                if (_compassHeading != null)
                  Transform.rotate(
                    angle: (_compassHeading! * 3.14159) / 180,
                    child: Container(
                      width: 180,
                      height: 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 4,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalibrationInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.8),
            size: 32,
          ),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'calibration_title', 'Calibrating Compass'),
              style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'calibration_instructions', 'Please move your device in a figure-8 pattern to calibrate the compass sensor. This will improve the accuracy of the Qibla direction.'),
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 16),
          _buildCalibrationSteps(),
        ],
      ),
    );
  }

  Widget _buildCalibrationSteps() {
    return Column(
      children: [
        _buildCalibrationStep(
          icon: Icons.rotate_right,
          text: S.t(context, 'step_1', 'Hold your device flat'),
          isCompleted: true,
        ),
        _buildCalibrationStep(
          icon: Icons.gesture,
          text: S.t(context, 'step_2', 'Move in a figure-8 pattern'),
          isCompleted: _compassHeading != null,
        ),
        _buildCalibrationStep(
          icon: Icons.check_circle,
          text: S.t(context, 'step_3', 'Wait for calibration to complete'),
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildCalibrationStep({
    required IconData icon,
    required String text,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.white.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: IslamicTheme.textTheme.bodySmall?.copyWith(
                color: isCompleted ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildCalibrationProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Builder(builder: (context) {
            return Text(
              S.t(context, 'calibration_progress', 'Calibration Progress'),
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            );
          }),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _compassHeading != null ? 0.6 : 0.3,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            return Text(
              _compassHeading != null 
                  ? S.t(context, 'compass_detected', 'Compass sensor detected')
                  : S.t(context, 'detecting_compass', 'Detecting compass sensor...'),
              style: IslamicTheme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            );
          }),
        ],
      ),
    );
  }
}
