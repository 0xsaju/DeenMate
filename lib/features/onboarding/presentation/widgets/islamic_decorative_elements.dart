import 'package:flutter/material.dart';

/// Islamic decorative elements for onboarding screens
class IslamicDecorativeElements {
  // Islamic geometric patterns
  static Widget buildGeometricPattern({
    double size = 100,
    Color color = const Color(0xFF4CAF50),
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Islamic header icon
  static Widget buildHeaderIcon({
    required String icon,
    double size = 80,
    Color backgroundColor = const Color(0xFF4CAF50),
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  // Islamic progress indicator
  static Widget buildProgressIndicator({
    required int currentStep,
    required int totalSteps,
    Color activeColor = const Color(0xFF4CAF50),
    Color inactiveColor = const Color(0xFFE0E0E0),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive 
                    ? activeColor
                    : inactiveColor,
                shape: BoxShape.circle,
              ),
            ),
            if (index < totalSteps - 1)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive 
                      ? activeColor
                      : inactiveColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        );
      }),
    );
  }
}

/// Onboarding progress indicator widget
class OnboardingProgressIndicator extends StatelessWidget {

  const OnboardingProgressIndicator({
    required this.currentStep, required this.totalSteps, super.key,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          
          return Container(
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? 8 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFF4CAF50)
                        : isCompleted
                            ? const Color(0xFF4CAF50).withOpacity(0.7)
                            : Colors.grey.withOpacity(0.3),
                  ),
                ),
                if (index < totalSteps - 1)
                  Container(
                    width: 20,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF4CAF50).withOpacity(0.7)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
