// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({required bool isTest}) {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.emerald,
      onPrimary: AppColors.white,
      secondary: AppColors.violet,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.black,
      error: AppColors.red,
      onError: AppColors.white,
    );

    final textTheme = ThemeData.light().textTheme.apply(
      fontFamily: AppFonts.saira,
    );

    return ThemeData(
      fontFamily: AppFonts.saira,
      textTheme: textTheme,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      useMaterial3: !isTest,
      splashFactory: isTest ? InkRipple.splashFactory : null,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: AppFonts.saira,
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: AppColors.rose,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.emerald,
        selectionColor: AppColors.sky,
        selectionHandleColor: AppColors.emerald,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedLabelStyle: TextStyle(
          fontFamily: AppFonts.saira,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.saira,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}



