import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// Shams Platform — App Theme
///
/// Centralizes all theming decisions. Use [ShamsTheme.light] and
/// [ShamsTheme.dark] when constructing [MaterialApp] to apply the brand
/// design system globally.
class ShamsTheme {
  // Private constructor — this class should not be instantiated.
  const ShamsTheme._();

  // ── Shared helpers ─────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(Color bodyColor, Color labelColor) {
    return GoogleFonts.tajawalTextTheme().copyWith(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: bodyColor,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: bodyColor,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: bodyColor,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: bodyColor,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: labelColor,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: bodyColor,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: bodyColor,
      ),
    );
  }

  // ── Light Theme ─────────────────────────────────────────────────────────────

  /// The primary light theme for the Shams Platform.
  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,

      // Primary
      primary: ShamsColors.primaryBlue,
      onPrimary: ShamsColors.bgWhite,
      primaryContainer: Color(0xFFD6E4FF),
      onPrimaryContainer: Color(0xFF001E6C),

      // Secondary (Solar Yellow)
      secondary: ShamsColors.solarYellow,
      onSecondary: ShamsColors.textGray,
      secondaryContainer: Color(0xFFFFF3CC),
      onSecondaryContainer: Color(0xFF3D2C00),

      // Tertiary (Verified Green)
      tertiary: ShamsColors.verifiedGreen,
      onTertiary: ShamsColors.bgWhite,
      tertiaryContainer: Color(0xFFB7F0CE),
      onTertiaryContainer: Color(0xFF003920),

      // Error
      error: Color(0xFFBA1A1A),
      onError: ShamsColors.bgWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),

      // Surface / Background
      surface: ShamsColors.bgWhite,
      onSurface: ShamsColors.textGray,
      surfaceContainerHighest: Color(0xFFF0F4FF),
      onSurfaceVariant: Color(0xFF44474F),

      // Outline
      outline: Color(0xFF74777F),
      outlineVariant: Color(0xFFC4C7CF),

      // Scrim & Shadow
      scrim: Colors.black,
      inverseSurface: Color(0xFF2F3038),
      onInverseSurface: Color(0xFFF1F0F7),
      inversePrimary: Color(0xFFADC6FF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: ShamsColors.primaryBlue,
      scaffoldBackgroundColor: ShamsColors.backgroundLight,
      textTheme: _buildTextTheme(ShamsColors.textGray, ShamsColors.bgWhite),
      extensions: const [ShamsExtendedColors.light],

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ShamsColors.bgWhite,
        foregroundColor: ShamsColors.textGray,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ShamsColors.textGray,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ShamsColors.primaryBlue,
          foregroundColor: ShamsColors.bgWhite,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ShamsColors.primaryBlue,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: ShamsColors.primaryBlue, width: 1.5),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F7FF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ShamsColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        hintStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: const Color(0xFF9EA3B0),
        ),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: ShamsColors.textGray,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        color: ShamsColors.bgWhite,
        elevation: 2,
        shadowColor: Color(0x1A0052CC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F4FF),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: ShamsColors.primaryBlue,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEF0F4),
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2F3038),
        contentTextStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: ShamsColors.bgWhite,
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ShamsColors.bgWhite,
        modalBackgroundColor: ShamsColors.bgWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: ShamsColors.bgWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────────

  /// The dark theme for the Shams Platform.
  ///
  /// Primary blue is lightened from #0052CC → #6BA3FF (contrast 5.8:1 on dark).
  /// All surface/text pairings meet WCAG AA (≥ 4.5:1 for body text).
  static ThemeData get dark {
    // Dark surface: #121218 — near-black with a blue tint
    const Color darkSurface = Color(0xFF121218);
    // Elevated cards sit slightly lighter
    const Color darkCardSurface = Color(0xFF1A1A28);
    // Lightened primary for dark backgrounds (5.8:1 contrast on #121218)
    const Color darkPrimary = Color(0xFF6BA3FF);
    // On-surface text: off-white (13.6:1 on #121218)
    const Color darkOnSurface = Color(0xFFE4E4EC);
    // On-surface variant: muted (9.2:1 on #121218)
    const Color darkOnSurfaceVariant = Color(0xFFC4C7CF);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,

      // Primary
      primary: darkPrimary,
      onPrimary: Color(0xFF00285E),
      primaryContainer: Color(0xFF003D99),
      onPrimaryContainer: Color(0xFFD6E4FF),

      // Secondary (Solar Yellow — naturally high contrast on dark)
      secondary: Color(0xFFFFD470),
      onSecondary: Color(0xFF3D2C00),
      secondaryContainer: Color(0xFF4A3800),
      onSecondaryContainer: Color(0xFFFFE9A0),

      // Tertiary (Verified Green)
      tertiary: Color(0xFF52C87A),
      onTertiary: Color(0xFF003920),
      tertiaryContainer: Color(0xFF00522E),
      onTertiaryContainer: Color(0xFFB7F0CE),

      // Error
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),

      // Surface / Background
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: Color(0xFF1E1E2A),
      onSurfaceVariant: darkOnSurfaceVariant,

      // Outline
      outline: Color(0xFF8E9099),
      outlineVariant: Color(0xFF44474F),

      // Scrim & Shadow
      scrim: Colors.black,
      inverseSurface: Color(0xFFE4E4EC),
      onInverseSurface: Color(0xFF2F3038),
      inversePrimary: ShamsColors.primaryBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: const Color(0xFF0E0E18),
      textTheme: _buildTextTheme(darkOnSurface, darkOnSurface),
      extensions: const [ShamsExtendedColors.dark],

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkOnSurface,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: const Color(0xFF00285E),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: darkPrimary, width: 1.5),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF44474F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF44474F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        hintStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: const Color(0xFF7A7D8C),
        ),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: darkOnSurfaceVariant,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: darkCardSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E2A),
        labelStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: darkPrimary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C3E),
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2A3A),
        contentTextStyle: GoogleFonts.tajawal(
          fontSize: 14,
          color: darkOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCardSurface,
        modalBackgroundColor: darkCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
