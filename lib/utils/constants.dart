import 'package:flutter/material.dart';

/// Shams Platform — Brand Color Palette
///
/// All color constants are defined here as the single source of truth.
/// Always reference these values instead of using raw hex codes elsewhere.
class ShamsColors {
  // Private constructor — this class should not be instantiated.
  const ShamsColors._();

  /// Primary brand blue — used for buttons, links, and key UI elements.
  static const Color primaryBlue = Color(0xFF0052CC);

  /// Solar yellow — used for highlights, badges, and accents.
  static const Color solarYellow = Color(0xFFffc53d);

  /// Verified green — used for success states and verification indicators.
  static const Color verifiedGreen = Color(0xFF27AE60);

  /// Background white — default surface and scaffold background color.
  static const Color bgWhite = Color(0xFFFFFFFF);

  /// Text gray — primary body text color.
  static const Color textGray = Color(0xFF4A4A4A);

  /// Background light — grayish blue background for scaffolds and sheets.
  static const Color backgroundLight = Color(0xFFF5F7FF);

  /// Border light — used for input borders and light outlines.
  static const Color borderLight = Color(0xFFEEF0F4);

  /// Text hint — used for placeholder texts, unselected icons, and secondary information.
  static const Color textHint = Color(0xFF9EA3B0);

  /// Divider light — used for list separators.
  static const Color dividerLight = Color(0xFFF0F4FF);

  /// Handle bar — color for bottom sheet drag handles.
  static const Color handleBar = Color(0xFFDDE0E8);

  /// Danger red — used for liked icons and standard error states.
  static const Color dangerRed = Color(0xFFE53935);

  /// Danger dark — used for report actions and critical warnings.
  static const Color dangerDark = Color(0xFFBA1A1A);

  /// Avatar fallback background — light blue background for default avatars.
  static const Color avatarFallbackBg = Color(0xFFD6E4FF);
}
