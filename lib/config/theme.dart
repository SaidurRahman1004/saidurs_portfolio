import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Professional Dark Theme
  static const Color primaryColor = Color(0xFF00D9FF); // Cyan
  static const Color secondaryColor = Color(0xFF6C63FF); // Purple
  static const Color accentColor = Color(0xFFFF6584); // Pink

  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color cardBackground = Color(0xFF1A1F3A);
  static const Color surfaceColor = Color(0xFF252B48);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3C1);
  static const Color textHint = Color(0xFF6B7280);

  // Colors - Modern light theme
  static const Color lightPrimaryColor = Color(0xFF2563EB);
  static const Color lightSecondaryColor = Color(0xFF7C3AED);
  static const Color lightAccentColor = Color(0xFFF97316);

  static const Color lightBackground = Color(0xFFF6F8FC);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFEFF3FA);

  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextHint = Color(0xFF94A3B8);

  // Border colors
  static const Color darkBorderColor = Color(0xFF1E293B);
  static const Color lightBorderColor = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBackground, surfaceColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [lightCardBackground, Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryGradient
        : lightPrimaryGradient;
  }

  static LinearGradient getCardGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardGradient
        : lightCardGradient;
  }

  // Adaptive theme helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getPrimaryColor(BuildContext context) =>
      isDark(context) ? primaryColor : lightPrimaryColor;

  static Color getCardBackground(BuildContext context) =>
      isDark(context) ? cardBackground : lightCardBackground;

  static Color getScaffoldBackground(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color getSurfaceColor(BuildContext context) =>
      isDark(context) ? surfaceColor : lightSurfaceColor;

  static Color getBorderColor(BuildContext context) =>
      isDark(context) ? darkBorderColor : lightBorderColor;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? textPrimary : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? textSecondary : lightTextSecondary;

  static Color getTextHint(BuildContext context) =>
      isDark(context) ? textHint : lightTextHint;

  // Text Themes
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: primary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: secondary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: secondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardBackground,
        error: accentColor,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Text Theme
      textTheme: _buildTextTheme(textPrimary, textSecondary),

      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textHint),
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: lightPrimaryColor,
        secondary: lightSecondaryColor,
        surface: lightCardBackground,
        surfaceContainerHighest: lightSurfaceColor,
        error: lightAccentColor,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: lightCardBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        iconTheme: const IconThemeData(color: lightTextPrimary),
      ),

      // Text Theme
      textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary),

      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 1,
        shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.08),
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),

      // Input Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        hintStyle: GoogleFonts.inter(color: lightTextHint),
      ),
    );
  }
}
