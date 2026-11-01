import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/dashboard.dart';

void main() {
  runApp(const MindScroll());
}

/// Design tokens from the Figma prototype.
class AppColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E24);
  static const navigation = Color(0xFF1A1A1E);
  static const divider = Color(0xFF2A2A31);
  static const primary = Color(0xFF6200EE);
  static const accent = Color(0xFFBB86FC);
  static const secondaryText = Color(0xFFA4A4AF);
  static const fieldBorder = Color(0xFF4A4A55);
}

class MindScroll extends StatelessWidget {
  const MindScroll({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark(useMaterial3: true).textTheme,
    );

    return MaterialApp(
      title: 'MindScroll',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          onSurface: Color(0xFFECEFF1),
        ),
        textTheme: textTheme,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          contentTextStyle: textTheme.bodySmall?.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const Dashboard(),
    );
  }
}
