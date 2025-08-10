import 'package:flutter/material.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Quick action card for the home screen grid
class QuickActionCard extends StatelessWidget {
  
  const QuickActionCard({
    required this.icon, required this.title, required this.titleBengali, required this.subtitle, required this.backgroundColor, required this.iconBackgroundColor, required this.titleColor, super.key,
    this.onTap,
    this.height = 100,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and background
              Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
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
                          style: const TextStyle(fontSize: 18),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Bengali title
              Text(
                titleBengali,
                style: IslamicTheme.bengaliSmall.copyWith(
                  color: IslamicTheme.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
              Text(
                subtitle,
                style: IslamicTheme.textTheme.bodySmall?.copyWith(
                  color: IslamicTheme.textHint,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large feature card for main actions (alternative layout)
class LargeFeatureCard extends StatelessWidget {
  
  const LargeFeatureCard({
    required this.icon, required this.title, required this.titleBengali, required this.description, required this.features, required this.backgroundGradient, super.key,
    this.onTap,
  });
  final String icon;
  final String title;
  final String titleBengali;
  final String description;
  final List<String> features;
  final Gradient backgroundGradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title and Bengali
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titleBengali,
                        style: IslamicTheme.bengaliMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Features list
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),),
          ],
        ),
      ),
    );
  }
}
