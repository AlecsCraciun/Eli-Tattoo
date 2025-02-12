// lib/theme/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Culori principale
  static const Color gold = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  
  // Nuanțe de auriu pentru accente
  static const Color goldLight = Color(0xFFFFE55C);
  static const Color goldDark = Color(0xFFC7A900);
}

class AppTextStyles {
  static const TextStyle menuText = TextStyle(
    color: AppColors.white,
    fontSize: 20,
    letterSpacing: 8,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleLarge = TextStyle(
    color: AppColors.white,
    fontSize: 40,
    letterSpacing: 15,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontFamily: 'Poppins',
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.gold,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    
    // Configurare text
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.titleLarge,
      bodyLarge: AppTextStyles.bodyText,
    ),
    
    // Configurare butoane
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Configurare AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.gold,
        fontSize: 24,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
