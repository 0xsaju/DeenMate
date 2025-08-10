import 'package:flutter/material.dart';

/// Responsive layout widget for handling different screen sizes and platforms
/// Ensures Islamic app works beautifully on mobile, tablet, and desktop
class ResponsiveLayout extends StatelessWidget {
  
  const ResponsiveLayout({
    required this.mobile, super.key,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop breakpoint (1200px+)
        if (constraints.maxWidth >= 1200 && desktop != null) {
          return desktop!;
        }
        // Tablet breakpoint (600px - 1199px)
        else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        // Mobile (< 600px)
        else {
          return mobile;
        }
      },
    );
  }
}

/// Platform-aware Islamic card that adapts to screen size
class IslamicCard extends StatelessWidget {
  
  const IslamicCard({
    required this.child, super.key,
    this.padding,
    this.backgroundColor,
    this.boxShadow,
    this.borderRadius,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust padding and elevation based on screen size
        final isDesktop = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        
        final cardPadding = padding ?? EdgeInsets.all(
          isDesktop ? 24 : (isTablet ? 20 : 16),
        );
        
        final cardElevation = isDesktop ? 8.0 : (isTablet ? 6.0 : 4.0);
        
        return Container(
          padding: cardPadding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(
              isDesktop ? 16 : (isTablet ? 14 : 12),
            ),
            boxShadow: boxShadow ?? [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: cardElevation,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

/// Responsive Islamic gradient background
class IslamicGradientBackground extends StatelessWidget {
  
  const IslamicGradientBackground({
    required this.child, super.key,
    this.colors,
  });
  final Widget child;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xFF2E7D32),
            const Color(0xFF4CAF50),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Platform-aware Islamic text styles
class IslamicTextStyles {
  static TextStyle heading1(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
      fontWeight: FontWeight.bold,
      color: const Color(0xFF2E7D32),
    );
  }
  
  static TextStyle heading2(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2E7D32),
    );
  }
  
  static TextStyle body(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
      color: const Color(0xFF333333),
    );
  }
  
  static TextStyle caption(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 14 : (isTablet ? 12 : 11),
      color: const Color(0xFF666666),
    );
  }
  
  static TextStyle arabic(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2E7D32),
      fontFamily: 'Amiri', // Arabic font
    );
  }
  
  static TextStyle bengali(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1200;
    final isTablet = MediaQuery.of(context).size.width >= 600;
    
    return TextStyle(
      fontSize: isDesktop ? 16 : (isTablet ? 14 : 13),
      color: const Color(0xFF666666),
      fontFamily: 'NotoSansBengali', // Bengali font
    );
  }
}

/// Islamic color palette for consistent theming
class IslamicColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  static const Color secondary = Color(0xFF1565C0);
  static const Color secondaryLight = Color(0xFF42A5F5);
  
  static const Color accent = Color(0xFFFF8F00);
  static const Color accentLight = Color(0xFFFFB74D);
  
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFFFA000);
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
}

/// Safe area wrapper for iOS/Android
class IslamicSafeArea extends StatelessWidget {
  
  const IslamicSafeArea({
    required this.child, super.key,
    this.top = true,
    this.bottom = true,
  });
  final Widget child;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      child: child,
    );
  }
}
