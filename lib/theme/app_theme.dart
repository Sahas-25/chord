import 'package:flutter/material.dart';

/// All colours of the app in one place.
class AppColors {
  static const Color background = Color(0xFF1C1C21); // dark charcoal
  static const Color card = Color(0xFF2A2A31);
  static const Color cardLight = Color(0xFF35353E);
  static const Color purple = Color(0xFF9D6BFF); // accent colour
  static const Color purpleDark = Color(0xFF4B3A7A);
  static const Color textPrimary = Color(0xFFF2F2F5);
  static const Color textMuted = Color(0xFFA0A0AB);
  static const Color error = Color(0xFFEF5350);
}

class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.purple,
      onPrimary: Colors.white,
      secondary: AppColors.purple,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true, // Material 3
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.purpleDark,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.purpleDark,
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        activeTrackColor: AppColors.purple,
        inactiveTrackColor: AppColors.cardLight,
        thumbColor: AppColors.purple,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.cardLight,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// One shared style for every text field in the app.
  static InputDecoration inputDecoration({
    String? label,
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textMuted),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.card,
      border: border(AppColors.card, 0),
      enabledBorder: border(AppColors.card, 0),
      focusedBorder: border(AppColors.purple, 1.5),
      errorBorder: border(AppColors.error, 1),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }
}
