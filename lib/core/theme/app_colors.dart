import 'package:flutter/material.dart';

/// App-specific color tokens exposed via ThemeExtension so widgets
/// can read consistent colors and we can support light/dark themes later
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.headerPrimary,
    required this.headerSecondary,
    required this.accent,
    required this.divider,
    required this.alertPill,
    required this.peachCard,
    required this.mintCard,
    required this.iconMuted,
  });

  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color headerPrimary;
  final Color headerSecondary;
  final Color accent;
  final Color divider;
  final Color alertPill;
  final Color peachCard;
  final Color mintCard;
  final Color iconMuted;

  static const AppColors light = AppColors(
    background: Color(0xFFFEFBFA),
    card: Color(0xFFF9F1EC),
    textPrimary: Color(0xFF626126),
    textSecondary: Color(0xFF7F8C8D),
    textMuted: Color(0xFF7F8C8D),
    headerPrimary: Color(0xFF3E2A1F),
    headerSecondary: Color(0xFF6B5E56),
    accent: Color(0xFFFF6B35),
    divider: Color(0xFFD6CBB3),
    alertPill: Color(0xFFF9F1EC),
    peachCard: Color(0xFFFFEADC),
    mintCard: Color(0xFFEAF5EA),
    iconMuted: Color(0xFF7F8C8D),
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF0F1113),
    card: Color(0xFF171A1E),
    textPrimary: Color(0xFFECEFF1),
    textSecondary: Color(0xFFB0BEC5),
    textMuted: Color(0xFF90A4AE),
    headerPrimary: Color(0xFFE0D3C7),
    headerSecondary: Color(0xFFB8A79B),
    accent: Color(0xFFFF8A50),
    divider: Color(0xFF2A2F34),
    alertPill: Color(0xFF1E2226),
    peachCard: Color(0xFF2A211D),
    mintCard: Color(0xFF1E2A24),
    iconMuted: Color(0xFF90A4AE),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? headerPrimary,
    Color? headerSecondary,
    Color? accent,
    Color? divider,
    Color? alertPill,
    Color? peachCard,
    Color? mintCard,
    Color? iconMuted,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      headerPrimary: headerPrimary ?? this.headerPrimary,
      headerSecondary: headerSecondary ?? this.headerSecondary,
      accent: accent ?? this.accent,
      divider: divider ?? this.divider,
      alertPill: alertPill ?? this.alertPill,
      peachCard: peachCard ?? this.peachCard,
      mintCard: mintCard ?? this.mintCard,
      iconMuted: iconMuted ?? this.iconMuted,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      headerPrimary: Color.lerp(headerPrimary, other.headerPrimary, t)!,
      headerSecondary: Color.lerp(headerSecondary, other.headerSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      alertPill: Color.lerp(alertPill, other.alertPill, t)!,
      peachCard: Color.lerp(peachCard, other.peachCard, t)!,
      mintCard: Color.lerp(mintCard, other.mintCard, t)!,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t)!,
    );
  }
}
