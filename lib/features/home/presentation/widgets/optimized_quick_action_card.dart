import 'package:flutter/material.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Optimized quick action card with better overflow handling
class OptimizedQuickActionCard extends StatelessWidget {
  
  const OptimizedQuickActionCard({
    required this.icon, required this.title, required this.titleBengali, required this.subtitle, required this.backgroundColor, required this.iconBackgroundColor, required this.titleColor, super.key,
    this.onTap,
    this.height = 125, // Optimized height to prevent overflow
  });
  final String icon;
  final String title;
  final String titleBengali;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color titleColor;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with icon and background (fixed height)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Title in the colored header
                    Expanded(
                      child: Text(
                        title,
                        style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                          color: titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content area (expanded to fill remaining space)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bengali title
                    Flexible(
                      child: Text(
                        titleBengali,
                        style: IslamicTheme.bengaliSmall.copyWith(
                          color: IslamicTheme.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Subtitle
                    Flexible(
                      child: Text(
                        subtitle,
                        style: IslamicTheme.textTheme.bodySmall?.copyWith(
                          color: IslamicTheme.textHint,
                          fontSize: 9,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact action card for smaller spaces
class CompactActionCard extends StatelessWidget {
  
  const CompactActionCard({
    required this.icon, required this.title, required this.titleBengali, required this.accentColor, super.key,
    this.onTap,
  });
  final String icon;
  final String title;
  final String titleBengali;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with accent background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              title,
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Bengali title
            Text(
              titleBengali,
              style: IslamicTheme.bengaliSmall.copyWith(
                color: IslamicTheme.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
