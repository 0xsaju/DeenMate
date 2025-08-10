import 'package:flutter/material.dart';
import '../theme/islamic_theme.dart';

/// Islamic status bar component matching the design
class IslamicStatusBar extends StatelessWidget implements PreferredSizeWidget {
  
  const IslamicStatusBar({
    super.key,
    this.timeText = '9:41',
    this.batteryText = '100%',
    this.backgroundGradient,
  });
  final String timeText;
  final String batteryText;
  final Gradient? backgroundGradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: backgroundGradient ?? IslamicTheme.islamicGreenGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time
              Text(
                timeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              // Battery and signal
              Row(
                children: [
                  Text(
                    batteryText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 20,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44 + 44); // Status bar + padding
}

/// Islamic app bar that matches the design exactly
class IslamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  const IslamicAppBar({
    required this.title, super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundGradient,
    this.expandedHeight = 56,
    this.showBackButton = false,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Gradient? backgroundGradient;
  final double expandedHeight;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: backgroundGradient ?? IslamicTheme.islamicGreenGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: expandedHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Leading widget or back button
              if (showBackButton)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              else if (leading != null)
                leading!,
              
              // Title and subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Actions
              if (actions != null)
                Row(children: actions!)
              else
                const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(expandedHeight);
}
