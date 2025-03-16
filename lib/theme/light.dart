import 'package:flutter/material.dart';

ThemeData creamTheme = ThemeData(
    colorScheme: ColorScheme.light(
        primary: Color(0xFFF77F64),        // Primary color
        secondary: Color(0xFFE5CFC0),      // Secondary color
        background: Color(0xFFFFF9F0),     // Background color
        surface: Color(0xFFFFE8A3),        // Surface color, used as an accent
        onPrimary: Color(0xFF2D3436),      // Text color on primary
        onSecondary: Color(0xFF2D3436),    // Text color on secondary
        onBackground: Color(0xFF2D3436),   // Text color on background
        onSurface: Color(0xFF2D3436),      // Text color on surface
    ),
    scaffoldBackgroundColor: Color(0xFFFFF9F0),  // Scaffold background
    textTheme: TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF2D3436)),
        bodyMedium: TextStyle(color: Color(0xFF2D3436)),
        titleLarge: TextStyle(color: Color(0xFF2D3436)),
    ),
);
