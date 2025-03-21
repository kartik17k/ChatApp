import 'package:flutter/material.dart';
import 'colors.dart';

final retroTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'VT323',
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
      fontFamily: 'PressStart2P',
      color: Colors.white,
      fontSize: 16,
      height: 1.5,
    ),
    iconTheme: IconThemeData(color: textColor),
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: textColor,
      fontSize: 32,
      fontFamily: 'PressStart2P',
      height: 1.5,
    ),
    displayMedium: TextStyle(
      color: textColor,
      fontSize: 24,
      fontFamily: 'PressStart2P',
      height: 1.5,
    ),
    displaySmall: TextStyle(
      color: textColor,
      fontSize: 20,
      fontFamily: 'PressStart2P',
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      color: textColor,
      fontSize: 18,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: textColor,
      fontSize: 16,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      color: textColor,
      fontSize: 16,
      fontFamily: 'PressStart2P',
      height: 1.5,
    ),
    titleSmall: TextStyle(
      color: subtleTextColor,
      fontSize: 14,
      height: 1.5,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: cardColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.zero, // Pixel perfect borders
      borderSide: BorderSide(
        color: dividerColor,
        width: 2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: dividerColor,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: errorColor,
        width: 2,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: errorColor,
        width: 2,
      ),
    ),
    hintStyle: TextStyle(
      color: placeholderColor,
      fontSize: 16,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: textColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: dividerColor,
          width: 2,
        ),
      ),
      textStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 14,
        height: 1.5,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: textColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      textStyle: const TextStyle(
        fontFamily: 'PressStart2P',
        fontSize: 12,
        height: 1.5,
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: textColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(
        color: dividerColor,
        width: 2,
      ),
    ),
  ),
  iconTheme: IconThemeData(
    color: textColor,
    size: 24,
  ),
  cardTheme: CardTheme(
    color: cardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(
        color: dividerColor,
        width: 2,
      ),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: dividerColor,
    thickness: 2,
    space: 2,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: cardColor,
    contentTextStyle: TextStyle(
      color: textColor,
      fontFamily: 'PressStart2P',
      fontSize: 12,
      height: 1.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
      side: BorderSide(
        color: dividerColor,
        width: 2,
      ),
    ),
    behavior: SnackBarBehavior.floating,
  ),
);
