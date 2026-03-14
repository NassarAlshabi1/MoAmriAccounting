import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

/// App Design System - Material 3 Theme Configuration
///
/// This class provides a comprehensive theme setup for the accounting app
/// following Material 3 design guidelines.

class AppDesignSystem {
  // ========== Typography ==========
  static TextTheme get _textTheme => TextTheme(
        // Display
        displayLarge: GoogleFonts.cairo(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),

        // Headlines
        headlineLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),

        // Titles
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),

        // Body
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),

        // Labels
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      );

  // ========== Light Theme ==========
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: AppPalette.primary,
          onPrimary: AppPalette.onPrimary,
          primaryContainer: AppPalette.primaryContainer,
          onPrimaryContainer: AppPalette.onPrimaryContainer,
          secondary: AppPalette.secondary,
          onSecondary: AppPalette.onSecondary,
          secondaryContainer: AppPalette.secondaryContainer,
          onSecondaryContainer: AppPalette.onSecondaryContainer,
          error: AppPalette.expense,
          onError: Colors.white,
          errorContainer: AppPalette.expenseContainer,
          onErrorContainer: AppPalette.expenseDark,
          surface: AppPalette.surface,
          onSurface: AppPalette.onSurface,
          surfaceContainerHighest: AppPalette.surfaceVariant,
          onSurfaceVariant: AppPalette.onSurfaceVariant,
          outline: AppPalette.outline,
          outlineVariant: AppPalette.outlineVariant,
        ),
        scaffoldBackgroundColor: AppPalette.background,
        textTheme: _textTheme,
        appBarTheme: _appBarTheme,
        cardTheme: _cardTheme,
        elevatedButtonTheme: _elevatedButtonTheme,
        filledButtonTheme: _filledButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme,
        floatingActionButtonTheme: _floatingActionButtonTheme,
        chipTheme: _chipTheme,
        dividerTheme: _dividerTheme,
        listTileTheme: _listTileTheme,
        navigationBarTheme: _navigationBarTheme,
        bottomSheetTheme: _bottomSheetTheme,
        dialogTheme: _dialogTheme,
        snackBarTheme: _snackBarTheme,
      );

  // ========== Dark Theme ==========
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: AppPaletteDark.primary,
          onPrimary: AppPaletteDark.onPrimary,
          primaryContainer: AppPaletteDark.primaryContainer,
          onPrimaryContainer: AppPaletteDark.onPrimaryContainer,
          secondary: AppPaletteDark.secondary,
          onSecondary: AppPaletteDark.onSecondary,
          secondaryContainer: AppPaletteDark.secondaryContainer,
          onSecondaryContainer: AppPaletteDark.onSecondaryContainer,
          error: AppPalette.expenseLight,
          onError: AppPalette.expenseDark,
          errorContainer: AppPalette.expenseDark,
          onErrorContainer: AppPalette.expenseContainer,
          surface: AppPaletteDark.surface,
          onSurface: AppPaletteDark.onSurface,
          surfaceContainerHighest: AppPaletteDark.surfaceVariant,
          onSurfaceVariant: AppPaletteDark.onSurfaceVariant,
          outline: AppPaletteDark.outline,
          outlineVariant: AppPaletteDark.outlineVariant,
        ),
        scaffoldBackgroundColor: AppPaletteDark.background,
        textTheme: _textTheme,
        appBarTheme: _appBarThemeDark,
        cardTheme: _cardThemeDark,
        elevatedButtonTheme: _elevatedButtonThemeDark,
        filledButtonTheme: _filledButtonThemeDark,
        outlinedButtonTheme: _outlinedButtonThemeDark,
        inputDecorationTheme: _inputDecorationThemeDark,
        dialogTheme: _dialogThemeDark,
        snackBarTheme: _snackBarThemeDark,
      );

  // ========== Component Themes ==========

  // AppBar Theme
  static AppBarTheme get _appBarTheme => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppPalette.surface,
        foregroundColor: AppPalette.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppPalette.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppPalette.onSurface),
      );

  static AppBarTheme get _appBarThemeDark => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: AppPaletteDark.surface,
        foregroundColor: AppPaletteDark.onSurface,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppPaletteDark.onSurface,
        ),
      );

  // Card Theme
  static CardTheme get _cardTheme => CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppPalette.border, width: 1),
        ),
        color: AppPalette.surface,
        surfaceTintColor: Colors.transparent,
      );

  static CardTheme get _cardThemeDark => CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppPaletteDark.border, width: 1),
        ),
        color: AppPaletteDark.surface,
        surfaceTintColor: Colors.transparent,
      );

  // Elevated Button Theme
  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static ElevatedButtonThemeData get _elevatedButtonThemeDark => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPaletteDark.primary,
          foregroundColor: AppPaletteDark.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  // Filled Button Theme
  static FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static FilledButtonThemeData get _filledButtonThemeDark => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPaletteDark.primary,
          foregroundColor: AppPaletteDark.onPrimary,
        ),
      );

  // Outlined Button Theme
  static OutlinedButtonThemeData get _outlinedButtonTheme => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppPalette.primary, width: 1.5),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonThemeDark => OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPaletteDark.primary,
          side: BorderSide(color: AppPaletteDark.primary, width: 1.5),
        ),
      );

  // Text Button Theme
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // Input Decoration Theme
  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.expense),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.expense, width: 2),
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppPalette.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppPalette.textHint,
          fontSize: 14,
        ),
        errorStyle: GoogleFonts.cairo(
          color: AppPalette.expense,
          fontSize: 12,
        ),
        prefixIconColor: AppPalette.textSecondary,
        suffixIconColor: AppPalette.textSecondary,
      );

  static InputDecorationTheme get _inputDecorationThemeDark => InputDecorationTheme(
        filled: true,
        fillColor: AppPaletteDark.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPaletteDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPaletteDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppPaletteDark.primary, width: 2),
        ),
        labelStyle: GoogleFonts.cairo(
          color: AppPaletteDark.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.cairo(
          color: AppPaletteDark.textHint,
          fontSize: 14,
        ),
      );

  // FAB Theme
  static FloatingActionButtonThemeData get _floatingActionButtonTheme => FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.onPrimary,
      );

  // Chip Theme
  static ChipThemeData get _chipTheme => ChipThemeData(
        backgroundColor: AppPalette.surfaceVariant,
        labelStyle: GoogleFonts.cairo(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      );

  // Divider Theme
  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppPalette.border,
        thickness: 1,
        space: 1,
      );

  // ListTile Theme
  static ListTileThemeData get _listTileTheme => ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppPalette.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.cairo(
          fontSize: 13,
          color: AppPalette.textSecondary,
        ),
      );

  // Navigation Bar Theme
  static NavigationBarThemeData get _navigationBarTheme => NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppPalette.surface,
        indicatorColor: AppPalette.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      );

  // Bottom Sheet Theme
  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
        backgroundColor: AppPalette.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      );

  // Dialog Theme
  static DialogTheme get _dialogTheme => DialogTheme(
        backgroundColor: AppPalette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimary,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppPalette.textSecondary,
        ),
      );

  static DialogTheme get _dialogThemeDark => DialogTheme(
        backgroundColor: AppPaletteDark.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      );

  // SnackBar Theme
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppPalette.textPrimary,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      );

  static SnackBarThemeData get _snackBarThemeDark => SnackBarThemeData(
        backgroundColor: AppPaletteDark.surfaceVariant,
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppPaletteDark.textPrimary,
        ),
      );

  // ========== Spacing Constants ==========
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // ========== Border Radius ==========
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;
  static const double radiusFull = 100;

  // ========== Shadows ==========
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];
}
