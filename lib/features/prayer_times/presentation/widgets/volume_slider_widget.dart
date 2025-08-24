import 'package:flutter/material.dart';

/// Widget for controlling Athan volume with visual feedback
class VolumeSliderWidget extends StatefulWidget {

  const VolumeSliderWidget({
    required this.volume, required this.onVolumeChanged, super.key,
  });
  final double volume;
  final Function(double) onVolumeChanged;

  @override
  State<VolumeSliderWidget> createState() => _VolumeSliderWidgetState();
}

class _VolumeSliderWidgetState extends State<VolumeSliderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Volume Control',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(widget.volume * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Volume Slider with Visual Feedback
          Row(
            children: [
              // Volume Icon (Low)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isDragging && widget.volume > 0 ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      widget.volume == 0 ? Icons.volume_off : Icons.volume_down,
                      color: widget.volume > 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      size: 20,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Custom Volume Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: _CustomThumbShape(),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: Theme.of(context).colorScheme.primary,
                    inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: widget.volume,
                    divisions: 20,
                    onChanged: (value) {
                      widget.onVolumeChanged(value);
                    },
                    onChangeStart: (value) {
                      setState(() => _isDragging = true);
                      _pulseController.repeat(reverse: true);
                    },
                    onChangeEnd: (value) {
                      setState(() => _isDragging = false);
                      _pulseController.stop();
                      _pulseController.reset();
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Volume Icon (High)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isDragging && widget.volume > 0.7 ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.volume_up,
                      color: widget.volume > 0.7
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      size: 20,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Volume Level Indicator
          _buildVolumeIndicator(),
          
          const SizedBox(height: 12),
          
          // Volume Presets
          _buildVolumePresets(),
        ],
      ),
    );
  }

  Widget _buildVolumeIndicator() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey.withOpacity(0.2),
      ),
      child: Row(
        children: List.generate(20, (index) {
          final isActive = index < (widget.volume * 20).round();
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: isActive
                    ? _getVolumeColor(index / 20)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVolumePresets() {
    final presets = [
      (0.0, 'Silent', Icons.volume_off),
      (0.3, 'Low', Icons.volume_down),
      (0.6, 'Medium', Icons.volume_up),
      (1.0, 'High', Icons.volume_up),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: presets.map((preset) {
        final volume = preset.$1;
        final label = preset.$2;
        final icon = preset.$3;
        final isSelected = (widget.volume - volume).abs() < 0.1;

        return GestureDetector(
          onTap: () => widget.onVolumeChanged(volume),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getVolumeColor(double percentage) {
    if (percentage < 0.3) {
      return Theme.of(context).colorScheme.primary;
    } else if (percentage < 0.7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    
    // Outer circle
    final outerPaint = Paint()
      ..color = sliderTheme.thumbColor ?? const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    
    // Inner circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw outer circle
    canvas.drawCircle(center, 10, outerPaint);
    
    // Draw inner circle
    canvas.drawCircle(center, 6, innerPaint);
    
    // Draw volume indicator
    if (value > 0) {
      final indicatorPaint = Paint()
        ..color = sliderTheme.thumbColor ?? const Color(0xFF2E7D32)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, 3, indicatorPaint);
    }
  }
}
