import 'package:flutter/material.dart';

// Define the color palette
class AppColors {
  static const Color royalBlue = Color(0xFF0760FB);
  static const Color lightBlue = Color(0xFF8DBCF6);
  static const Color red = Color(0xFFFF4242);
  static const Color orange = Color(0xFFFFA947);
  static const Color green = Color(0xFF65B520);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFEAEAEA);
  static const Color darkGray = Color(0xFF808080);
  static const Color black = Color(0xFF333333);
}

// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.white,
  primaryColor: AppColors.royalBlue,
  fontFamily: 'Poppins', // Set the default font to Poppins
  colorScheme: const ColorScheme.light(
    primary: AppColors.royalBlue,
    secondary: AppColors.orange,
    surface: AppColors.lightGray,
    onPrimary: AppColors.white,
    onSecondary: AppColors.darkGray,
    onSurface: AppColors.black,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.black,
  primaryColor: AppColors.royalBlue,
  fontFamily: 'Poppins', // Set the default font to Poppins
  colorScheme: const ColorScheme.dark(
    primary: AppColors.royalBlue,
    secondary: AppColors.orange,
    surface: AppColors.darkGray,
    onPrimary: AppColors.white,
    onSecondary: AppColors.darkGray,
    onSurface: AppColors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.white,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.white,
    ),
  ),
);
