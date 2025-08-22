import 'package:flutter/material.dart';

class ThemeHelper {
  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getOnPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getOutlineColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }

  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).colorScheme.error;
  }

  // Legacy color mappings for transition
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline.withOpacity(0.2);
  }

  static Color getAlertPillColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  static Color getHeaderPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getHeaderSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
  }

  static Color getAccentColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  // Prayer-specific colors
  static Color getPrayerColor(String prayer, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (prayer.toLowerCase()) {
      case 'fajr':
      case 'ফজর':
        return colorScheme.primary;
      case 'dhuhr':
      case 'যুহর':
        return colorScheme.secondary;
      case 'asr':
      case 'আসর':
        return colorScheme.tertiary;
      case 'maghrib':
      case 'মাগরিব':
        return colorScheme.error;
      case 'isha':
      case 'ইশা':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  static Color getPrayerBackgroundColor(String prayer, BuildContext context) {
    final baseColor = getPrayerColor(prayer, context);
    return baseColor.withOpacity(0.1);
  }

  static Color getFeatureColor(String feature, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (feature.toLowerCase()) {
      case 'zakat':
      case 'যাকাত':
        return colorScheme.primary;
      case 'prayer':
      case 'নামাজ':
        return colorScheme.secondary;
      case 'qibla':
      case 'কিবলা':
        return colorScheme.tertiary;
      case 'islamic':
      case 'ইসলামিক':
        return colorScheme.primary;
      case 'dua':
      case 'দোয়া':
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }
}
