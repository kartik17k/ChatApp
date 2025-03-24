import 'package:flutter/material.dart';
import 'colors.dart';
import 'light_colors.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    background: backgroundColor,
    error: errorColor,
    onPrimary: textColor,
    onSecondary: textColor,
    onSurface: textColor,
    onBackground: textColor,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: textColor),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: textColor,
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      color: textColor,
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: textColor,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: textColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: textColor,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: subtleTextColor,
      fontSize: 12,
    ),
  ),
  cardTheme: CardTheme(
    color: cardColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: lightPrimaryColor,
    secondary: lightSecondaryColor,
    surface: lightSurfaceColor,
    background: lightBackgroundColor,
    error: lightErrorColor,
    onPrimary: lightTextColor,
    onSecondary: lightTextColor,
    onSurface: lightTextColor,
    onBackground: lightTextColor,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: lightBackgroundColor,
  appBarTheme: AppBarTheme(
    backgroundColor: lightSurfaceColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: lightTextColor),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: lightTextColor,
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      color: lightTextColor,
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
    displaySmall: TextStyle(
      color: lightTextColor,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: lightTextColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: lightTextColor,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      color: lightSubtleTextColor,
      fontSize: 12,
    ),
  ),
  cardTheme: CardTheme(
    color: lightCardColor,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
