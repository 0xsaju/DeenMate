import 'package:flutter/material.dart';

/// Widget for toggling individual prayer notifications
class PrayerNotificationToggle extends StatefulWidget {

  const PrayerNotificationToggle({
    required this.prayerName, required this.arabicName, required this.icon, required this.isEnabled, required this.onToggle, super.key,
  });
  final String prayerName;
  final String arabicName;
  final IconData icon;
  final bool isEnabled;
  final Function(bool) onToggle;

  @override
  State<PrayerNotificationToggle> createState() => _PrayerNotificationToggleState();
}

class _PrayerNotificationToggleState extends State<PrayerNotificationToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);

    if (widget.isEnabled) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PrayerNotificationToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnabled != widget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isEnabled
                      ? Colors.green.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                  width: widget.isEnabled ? 2 : 1,
                ),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Prayer Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.isEnabled
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.isEnabled ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Prayer Names
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.prayerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.isEnabled
                                ? Colors.green
                                : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.arabicName,
                          style: TextStyle(
                            fontFamily: 'NotoSansArabic',
                            fontSize: 14,
                            color: widget.isEnabled
                                ? Colors.green.withOpacity(0.8)
                                : Colors.grey[600],
                            height: 1.4,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status and Toggle
                  Column(
                    children: [
                      Switch(
                        value: widget.isEnabled,
                        onChanged: (value) {
                          widget.onToggle(value);
                          _toggleAnimation();
                        },
                        activeColor: Colors.green,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.isEnabled
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.isEnabled ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.isEnabled
                                ? Colors.green[700]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleAnimation() {
    if (widget.isEnabled) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}
