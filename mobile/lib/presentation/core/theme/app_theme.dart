import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double _smallRadius = 8.0;
  static const double _mediumRadius = 12.0;
  static const double _largeRadius = 16.0;

  static const Duration _shortAnimation = Duration(milliseconds: 200);
  static const Duration _mediumAnimation = Duration(milliseconds: 300);
  static const Duration _longAnimation = Duration(milliseconds: 500);

  static ThemeData get lightTheme {
    const primaryColor = Color(0xFF2E7D32); // Verde para foco e concentração
    const secondaryColor = Color(0xFF1565C0); // Azul para confiança
    const backgroundColor = Color(0xFFF5F5F5);
    const surfaceColor = Colors.white;
    const errorColor = Color(0xFFD32F2F);

    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: errorColor,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: Colors.black87,
        surface: surfaceColor,
        onSurface: Colors.black87,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mediumRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_smallRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    const primaryColor = Color(0xFF81C784); // Verde mais suave
    const secondaryColor = Color(0xFF64B5F6); // Azul mais suave
    const backgroundColor = Color(0xFF121212);
    const surfaceColor = Color(0xFF1E1E1E);
    const errorColor = Color(0xFFEF5350);

    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        height: 1.5,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        height: 1.5,
        color: Colors.white,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.black87,
        secondary: secondaryColor,
        onSecondary: Colors.black87,
        error: errorColor,
        onError: Colors.black87,
        background: backgroundColor,
        onBackground: Colors.white,
        surface: surfaceColor,
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mediumRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_smallRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // Constantes de animação para uso em todo o app
  static Duration get shortAnimation => _shortAnimation;
  static Duration get mediumAnimation => _mediumAnimation;
  static Duration get longAnimation => _longAnimation;

  // Constantes de raio para uso em todo o app
  static double get smallRadius => _smallRadius;
  static double get mediumRadius => _mediumRadius;
  static double get largeRadius => _largeRadius;

  // Espaçamentos consistentes
  static const spacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
  };

  // Elevações consistentes
  static const elevation = {
    'none': 0.0,
    'low': 2.0,
    'medium': 4.0,
    'high': 8.0,
  };
}
