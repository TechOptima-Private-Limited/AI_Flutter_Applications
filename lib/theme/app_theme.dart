// lib/theme/app_theme.dart (POLISHED & ATTRACTIVE)
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - More vibrant and medical-inspired
  static const Color primaryRed = Color(0xFFE53935); // Vibrant Medical Red
  static const Color accentRed = Color(0xFFFF5252); // Bright accent
  static const Color darkRed = Color(0xFFB71C1C); // Deep red
  static const Color lightRedTint = Color(0xFFFFEBEE); // Very light red tint

  // Gradient colors
  static const Color gradientStart = Color(0xFFEF5350);
  static const Color gradientEnd = Color(0xFFE53935);

  // Light mode complementary colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCardBg = Color(0xFF252525);

  // Success/Info colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color warningOrange = Color(0xFFFF9800);

  // Light Theme - Modern Red & White with Gradients
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,

    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      onPrimary: Colors.white,
      primaryContainer: lightRedTint,
      onPrimaryContainer: darkRed,

      secondary: accentRed,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFCDD2),
      onSecondaryContainer: darkRed,

      tertiary: Color(0xFFFF6F61), // Coral accent
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE0DD),
      onTertiaryContainer: Color(0xFF8C3A2B),

      error: Color(0xFFDC2626),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF5F0F0F),

      surface: lightSurface,
      onSurface: Color(0xFF1F1F1F),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      surfaceContainer: Color(0xFFFCFCFC),

      outline: Color(0xFFE0E0E0),
      outlineVariant: Color(0xFFF0F0F0),

      shadow: Color(0x1A000000),
      scrim: Color(0x80000000),

      inverseSurface: Color(0xFF2D2D2D),
      onInverseSurface: Color(0xFFF5F5F5),
      inversePrimary: accentRed,

      surfaceTint: primaryRed,
    ),

    // Modern AppBar with gradient support
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryRed,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: primaryRed, size: 24),
      actionsIconTheme: IconThemeData(color: primaryRed, size: 24),
      titleTextStyle: TextStyle(
        color: Color(0xFF1F1F1F),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 64,
    ),

    // Beautiful Card Theme with shadow
    cardTheme: CardThemeData(
      color: lightCardBg,
      elevation: 0,
      shadowColor: const Color(0x0D000000),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFF0F0F0),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button - Gradient style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryRed.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Filled Button - Modern style
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryRed,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: primaryRed, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryRed,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Modern Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),

      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF666666),
      ),

      hintStyle: const TextStyle(
        fontSize: 15,
        color: Color(0xFFAAAAAA),
      ),
    ),

    // Modern SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D2D2D),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      actionTextColor: accentRed,
    ),

    // Modern Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 8,
      height: 70,
      indicatorColor: lightRedTint,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryRed, size: 28);
        }
        return const IconThemeData(color: Color(0xFF9E9E9E), size: 24);
      }),

      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: primaryRed,
            letterSpacing: 0.2,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF9E9E9E),
        );
      }),
    ),

    // Modern FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryRed,
      foregroundColor: Colors.white,
      elevation: 6,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
    ),

    // Modern Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        color: Color(0xFF1F1F1F),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xFF4A4A4A),
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF5F5F5),
      selectedColor: lightRedTint,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryRed,
      linearTrackColor: Color(0xFFFFEBEE),
      circularTrackColor: Color(0xFFFFEBEE),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0F0F0),
      thickness: 1,
      space: 1,
    ),

    // ListTile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: primaryRed,
      size: 24,
    ),
  );

  // Dark Theme - Sleek Black & Red with Glow Effects
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: accentRed,
      onPrimary: Color(0xFF0A0A0A),
      primaryContainer: darkRed,
      onPrimaryContainer: Color(0xFFFFB4AB),

      secondary: Color(0xFFFF6B6B),
      onSecondary: Color(0xFF0A0A0A),
      secondaryContainer: Color(0xFF8B0000),
      onSecondaryContainer: Color(0xFFFFCDD2),

      tertiary: Color(0xFFFF8A80),
      onTertiary: Color(0xFF0A0A0A),
      tertiaryContainer: Color(0xFF5D1F1A),
      onTertiaryContainer: Color(0xFFFFCDD2),

      error: Color(0xFFFF6B6B),
      onError: Color(0xFF0A0A0A),
      errorContainer: Color(0xFF8B0000),
      onErrorContainer: Color(0xFFFFCDD2),

      surface: darkSurface,
      onSurface: Color(0xFFE8E8E8),
      surfaceContainerHighest: darkCardBg,
      surfaceContainer: Color(0xFF1F1F1F),

      outline: Color(0xFF3A3A3A),
      outlineVariant: Color(0xFF2A2A2A),

      shadow: Color(0x40000000),
      scrim: Color(0xCC000000),

      inverseSurface: Color(0xFFE8E8E8),
      onInverseSurface: Color(0xFF1F1F1F),
      inversePrimary: primaryRed,

      surfaceTint: accentRed,
    ),

    // Dark AppBar with subtle glow
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: accentRed,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: accentRed, size: 24),
      actionsIconTheme: IconThemeData(color: accentRed, size: 24),
      titleTextStyle: TextStyle(
        color: Color(0xFFE8E8E8),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      toolbarHeight: 64,
    ),

    // Dark Cards with glow
    cardTheme: CardThemeData(
      color: darkCardBg,
      elevation: 0,
      shadowColor: accentRed.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Dark Elevated Button with glow
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        shadowColor: accentRed.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Dark Filled Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accentRed,
        foregroundColor: const Color(0xFF0A0A0A),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Dark Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentRed,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        side: const BorderSide(color: accentRed, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Dark Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentRed,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Dark Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1F1F),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: accentRed, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),

      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF9E9E9E),
      ),

      hintStyle: const TextStyle(
        fontSize: 15,
        color: Color(0xFF666666),
      ),
    ),

    // Dark SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D2D2D),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      actionTextColor: accentRed,
    ),

    // Dark Navigation Bar with glow
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: darkSurface,
      elevation: 8,
      height: 70,
      indicatorColor: const Color(0xFF2D2D2D),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: accentRed, size: 28);
        }
        return const IconThemeData(color: Color(0xFF666666), size: 24);
      }),

      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: accentRed,
            letterSpacing: 0.2,
          );
        }
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF666666),
        );
      }),
    ),

    // Dark FAB with glow
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentRed,
      foregroundColor: Color(0xFF0A0A0A),
      elevation: 8,
      highlightElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      sizeConstraints: BoxConstraints.tightFor(width: 64, height: 64),
    ),

    // Dark Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: darkCardBg,
      elevation: 24,
      shadowColor: accentRed.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        color: Color(0xFFE8E8E8),
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xFFB3B3B3),
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),

    // Dark Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2D2D2D),
      selectedColor: darkRed,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE8E8E8),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Dark Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentRed,
      linearTrackColor: Color(0xFF2D2D2D),
      circularTrackColor: Color(0xFF2D2D2D),
    ),

    // Dark Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 1,
    ),

    // Dark ListTile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      textColor: Color(0xFFE8E8E8),
      iconColor: accentRed,
    ),

    // Dark Icon Theme
    iconTheme: const IconThemeData(
      color: accentRed,
      size: 24,
    ),
  );
}

