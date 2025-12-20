import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final _isDark = false.obs;

  bool get isDark => _isDark.value;

  void toggleTheme() {
    _isDark.value = !_isDark.value;
    Get.changeTheme(theme);
  }

  ThemeData get theme => isDark ? darkTheme : lightTheme;

  // =====================
  // LIGHT THEME
  // =====================
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,

      scaffoldBackgroundColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF4CAF50),
        error: Color(0xFFE53935),
        background: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
      ),

      // GLOBAL SHADOW
      shadowColor: Colors.black.withOpacity(0.08),

      // CARD
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // LIST TILE
      listTileTheme: ListTileThemeData(
        tileColor: Colors.white,
        iconColor: Colors.black54,
        textColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      // BUTTON
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: false);
  }
}
