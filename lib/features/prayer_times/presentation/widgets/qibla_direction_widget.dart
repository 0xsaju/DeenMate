import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/prayer_times_providers.dart';

/// Widget showing Qibla direction with compass visualization
class QiblaDirectionWidget extends ConsumerStatefulWidget {
  const QiblaDirectionWidget({super.key});

  @override
  ConsumerState<QiblaDirectionWidget> createState() => _QiblaDirectionWidgetState();
}

class _QiblaDirectionWidgetState extends ConsumerState<QiblaDirectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
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

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaDirectionAsync = ref.watch(qiblaDirectionProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          qiblaDirectionAsync.when(
            data: _buildQiblaCompass,
            loading: _buildLoadingState,
            error: (error, stack) => _buildErrorState(),
          ),
          const SizedBox(height: 12),
          locationAsync.when(
            data: (location) => _buildLocationInfo(location.city, location.country),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.explore,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Qibla Direction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/qibla-finder'),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.open_in_new,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQiblaCompass(double direction) {
    return Column(
      children: [
        // Compass
        SizedBox(
          height: 100,
          width: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass background
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              
              // Cardinal directions
              ...List.generate(4, (index) {
                final angle = index * 90.0;
                final label = ['N', 'E', 'S', 'W'][index];
                return Transform.rotate(
                  angle: angle * math.pi / 180,
                  child: Transform.translate(
                    offset: const Offset(0, -35),
                    child: Transform.rotate(
                      angle: -angle * math.pi / 180,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // Qibla arrow
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Transform.rotate(
                      angle: direction * math.pi / 180,
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CustomPaint(
                          painter: QiblaArrowPainter(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Center dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Direction info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mosque,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${direction.toStringAsFixed(1)}° from North',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to calculate\nQibla direction',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String city, String country) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$city, $country',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing the Qibla arrow
class QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700) // Gold color for Kaaba direction
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Draw arrow pointing upward (North)
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Arrow head
    path.moveTo(centerX, centerY - 25);
    path.lineTo(centerX - 8, centerY - 10);
    path.lineTo(centerX - 3, centerY - 10);
    path.lineTo(centerX - 3, centerY + 20);
    path.lineTo(centerX + 3, centerY + 20);
    path.lineTo(centerX + 3, centerY - 10);
    path.lineTo(centerX + 8, centerY - 10);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
    
    // Add a small Kaaba symbol
    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY - 18),
      width: 6,
      height: 6,
    );
    canvas.drawRect(rect, Paint()..color = const Color(0xFF2E7D32));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
