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

// ─────────────────────────────────────────────────────────────────────────────
// ShamsExtendedColors — ThemeExtension for brand-specific semantic colors
//
// Usage in widgets:
//   final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
//   color: ext.backgroundLight
//
// Both ShamsTheme.light and ShamsTheme.dark register their variant.
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ShamsExtendedColors extends ThemeExtension<ShamsExtendedColors> {
  const ShamsExtendedColors({
    required this.backgroundLight,
    required this.borderLight,
    required this.textHint,
    required this.dividerLight,
    required this.handleBar,
    required this.avatarFallbackBg,
    required this.cardSurface,
    required this.inputFill,
    required this.chipBackground,
    required this.messageBubbleOther,
    required this.imageErrorPlaceholder,
  });

  /// Scaffold / page background (slightly off-surface).
  final Color backgroundLight;

  /// Subtle border for inputs, search bars, and tiles.
  final Color borderLight;

  /// Hint/placeholder text color.
  final Color textHint;

  /// Divider and list separator color.
  final Color dividerLight;

  /// Bottom sheet drag handle color.
  final Color handleBar;

  /// Fallback avatar background.
  final Color avatarFallbackBg;

  /// Elevated card / container surface (slightly above main surface).
  final Color cardSurface;

  /// Text input fill color.
  final Color inputFill;

  /// Filter chip background (unselected).
  final Color chipBackground;

  /// "Other" message bubble background in chat.
  final Color messageBubbleOther;

  /// Placeholder shown when an image fails to load.
  final Color imageErrorPlaceholder;

  // ── Light variant ──────────────────────────────────────────────────────────
  static const light = ShamsExtendedColors(
    backgroundLight: Color(0xFFF5F7FF),
    borderLight: Color(0xFFEEF0F4),
    textHint: Color(0xFF9EA3B0),
    dividerLight: Color(0xFFF0F4FF),
    handleBar: Color(0xFFDDE0E8),
    avatarFallbackBg: Color(0xFFD6E4FF),
    cardSurface: Color(0xFFFFFFFF),
    inputFill: Color(0xFFF5F7FF),
    chipBackground: Color(0xFFF0F4FF),
    messageBubbleOther: Color(0xFFF0F2F5),
    imageErrorPlaceholder: Color(0xFFF0F4FF),
  );

  // ── Dark variant ───────────────────────────────────────────────────────────
  static const dark = ShamsExtendedColors(
    backgroundLight: Color(0xFF0E0E18),
    borderLight: Color(0xFF2C2C3E),
    textHint: Color(0xFF7A7D8C),
    dividerLight: Color(0xFF1E1E2A),
    handleBar: Color(0xFF3A3A4E),
    avatarFallbackBg: Color(0xFF1A2A4A),
    cardSurface: Color(0xFF1A1A28),
    inputFill: Color(0xFF1A1A28),
    chipBackground: Color(0xFF1E1E2A),
    messageBubbleOther: Color(0xFF1E1E2A),
    imageErrorPlaceholder: Color(0xFF1E1E2A),
  );

  @override
  ShamsExtendedColors copyWith({
    Color? backgroundLight,
    Color? borderLight,
    Color? textHint,
    Color? dividerLight,
    Color? handleBar,
    Color? avatarFallbackBg,
    Color? cardSurface,
    Color? inputFill,
    Color? chipBackground,
    Color? messageBubbleOther,
    Color? imageErrorPlaceholder,
  }) {
    return ShamsExtendedColors(
      backgroundLight: backgroundLight ?? this.backgroundLight,
      borderLight: borderLight ?? this.borderLight,
      textHint: textHint ?? this.textHint,
      dividerLight: dividerLight ?? this.dividerLight,
      handleBar: handleBar ?? this.handleBar,
      avatarFallbackBg: avatarFallbackBg ?? this.avatarFallbackBg,
      cardSurface: cardSurface ?? this.cardSurface,
      inputFill: inputFill ?? this.inputFill,
      chipBackground: chipBackground ?? this.chipBackground,
      messageBubbleOther: messageBubbleOther ?? this.messageBubbleOther,
      imageErrorPlaceholder:
          imageErrorPlaceholder ?? this.imageErrorPlaceholder,
    );
  }

  @override
  ShamsExtendedColors lerp(ShamsExtendedColors? other, double t) {
    if (other is! ShamsExtendedColors) return this;
    return ShamsExtendedColors(
      backgroundLight: Color.lerp(backgroundLight, other.backgroundLight, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      dividerLight: Color.lerp(dividerLight, other.dividerLight, t)!,
      handleBar: Color.lerp(handleBar, other.handleBar, t)!,
      avatarFallbackBg:
          Color.lerp(avatarFallbackBg, other.avatarFallbackBg, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t)!,
      messageBubbleOther:
          Color.lerp(messageBubbleOther, other.messageBubbleOther, t)!,
      imageErrorPlaceholder:
          Color.lerp(imageErrorPlaceholder, other.imageErrorPlaceholder, t)!,
    );
  }
}

/// Shams Platform — Domain Constants
///
/// Single source of truth for all domain-specific lists and values.
/// Always reference these instead of duplicating lists in widgets/screens.
class ShamsConstants {
  const ShamsConstants._();

  /// Complete list of Yemeni governorates used in city pickers.
  /// Referenced by [AddWorkshopScreen], [WorkshopDashboardScreen], and [CityMultiSelectFilter].
  static const List<String> yemeniCities = [
    'أمانة العاصمة',
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'حضرموت',
    'ذمار',
    'عمران',
    'الضالع',
    'لحج',
    'أبين',
    'المهرة',
    'شبوة',
    'البيضاء',
    'مأرب',
    'الجوف',
    'صعدة',
    'المحويت',
    'حجة',
    'ريمة',
    'سقطرى',
  ];

  /// Solar service types used for filtering workshops and structuring maintenance requests.
  static const List<String> solarServiceTypes = [
    'تركيب منظومة جديدة',
    'صيانة ألواح شمسية',
    'صيانة عاكس (Inverter)',
    'صيانة بطاريات',
    'مضخات مياه شمسية',
    'فحص شامل للمنظومة',
    'توريد قطع غيار',
  ];

  /// Solar inverter brands commonly used in Yemen.
  static const List<String> inverterBrands = [
    'Growatt',
    'Huawei SUN2000',
    'SMA',
    'Solis',
    'Deye',
    'Goodwe',
    'Voltronic',
    'Sofar',
    'أخرى',
  ];

  /// Battery types for maintenance requests.
  static const List<String> batteryTypes = [
    'ليثيوم (LiFePO4)',
    'جل (Gel)',
    'حمض رصاص (AGM)',
    'أخرى',
  ];
}
