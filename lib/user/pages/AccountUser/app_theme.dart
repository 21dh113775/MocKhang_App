// app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF3498db);
  static const Color accentColor = Color(0xFF2ecc71);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Headline
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Title
      titleLarge: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.8),
      ),

      // Body
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: textColor.withOpacity(0.7),
      ),

      // Label
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor.withOpacity(0.8),
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: primaryColor.withOpacity(0.6),
      ),
    );
  }

  // Thuộc tính để dễ dàng truy cập
  static TextStyle get headline1 => _buildTextTheme().headlineLarge!;
  static TextStyle get headline2 => _buildTextTheme().headlineMedium!;
  static TextStyle get headline3 => _buildTextTheme().headlineSmall!;

  static TextStyle get title1 => _buildTextTheme().titleLarge!;
  static TextStyle get title2 => _buildTextTheme().titleMedium!;
  static TextStyle get title3 => _buildTextTheme().titleSmall!;

  static TextStyle get body1 => _buildTextTheme().bodyLarge!;
  static TextStyle get body2 => _buildTextTheme().bodyMedium!;
  static TextStyle get body3 => _buildTextTheme().bodySmall!;
}
