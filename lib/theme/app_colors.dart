import 'package:flutter/material.dart';

/// App Colors - Material 3 Color Scheme
/// This file defines the color palette for the MoAmri Accounting application
/// following Material Design 3 guidelines.

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============== Primary Colors ==============
  /// Primary brand color - Used for main actions and key UI elements
  static const Color primary = Color(0xFF0066CC);

  /// Primary container - Lighter shade for containers
  static const Color primaryContainer = Color(0xFFD6E4FF);

  /// On primary - Text/icons on primary color
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// On primary container - Text/icons on primary container
  static const Color onPrimaryContainer = Color(0xFF001D38);

  // ============== Secondary Colors ==============
  /// Secondary color - Used for less prominent elements
  static const Color secondary = Color(0xFF535F70);

  /// Secondary container
  static const Color secondaryContainer = Color(0xFFD7E3F7);

  /// On secondary
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// On secondary container
  static const Color onSecondaryContainer = Color(0xFF101C2B);

  // ============== Tertiary Colors ==============
  /// Tertiary color - Used for accents and contrasting elements
  static const Color tertiary = Color(0xFF6B5778);

  /// Tertiary container
  static const Color tertiaryContainer = Color(0xFFF2DAFF);

  /// On tertiary
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// On tertiary container
  static const Color onTertiaryContainer = Color(0xFF251432);

  // ============== Error Colors ==============
  /// Error color - Used for error states and destructive actions
  static const Color error = Color(0xFFBA1A1A);

  /// Error container
  static const Color errorContainer = Color(0xFFFFDAD6);

  /// On error
  static const Color onError = Color(0xFFFFFFFF);

  /// On error container
  static const Color onErrorContainer = Color(0xFF410002);

  // ============== Success Colors ==============
  /// Success color - Used for success states
  static const Color success = Color(0xFF2E7D32);

  /// Success container
  static const Color successContainer = Color(0xFFC8E6C9);

  /// On success
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// On success container
  static const Color onSuccessContainer = Color(0xFF002204);

  // ============== Warning Colors ==============
  /// Warning color - Used for warning states
  static const Color warning = Color(0xFFED6C02);

  /// Warning container
  static const Color warningContainer = Color(0xFFFFE0B2);

  /// On warning
  static const Color onWarning = Color(0xFFFFFFFF);

  /// On warning container
  static const Color onWarningContainer = Color(0xFF3E1E00);

  // ============== Surface Colors (Light Theme) ==============
  /// Surface color - Background color for widgets
  static const Color surface = Color(0xFFFDFCFF);

  /// Surface variant
  static const Color surfaceVariant = Color(0xFFDFE2EB);

  /// Surface tint
  static const Color surfaceTint = Color(0xFF0066CC);

  /// On surface
  static const Color onSurface = Color(0xFF1A1C1E);

  /// On surface variant
  static const Color onSurfaceVariant = Color(0xFF43474E);

  // ============== Outline Colors ==============
  /// Outline - Used for borders
  static const Color outline = Color(0xFF73777F);

  /// Outline variant - Lighter border color
  static const Color outlineVariant = Color(0xFFC3C6CF);

  // ============== Background Colors (Light Theme) ==============
  /// Background color
  static const Color background = Color(0xFFFDFCFF);

  /// On background
  static const Color onBackground = Color(0xFF1A1C1E);

  // ============== Other Colors ==============
  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  /// Scrim color - Used for modal barriers
  static const Color scrim = Color(0xFF000000);

  /// Inverse surface
  static const Color inverseSurface = Color(0xFF2F3033);

  /// On inverse surface
  static const Color onInverseSurface = Color(0xFFF1F0F4);

  /// Inverse primary
  static const Color inversePrimary = Color(0xFFA9C8FF);

  // ============== Dark Theme Colors ==============
  /// Primary dark
  static const Color primaryDark = Color(0xFFA9C8FF);

  /// Primary container dark
  static const Color primaryContainerDark = Color(0xFF004A99);

  /// On primary dark
  static const Color onPrimaryDark = Color(0xFF00325B);

  /// On primary container dark
  static const Color onPrimaryContainerDark = Color(0xFFD6E4FF);

  /// Secondary dark
  static const Color secondaryDark = Color(0xFFBBC7DB);

  /// Secondary container dark
  static const Color secondaryContainerDark = Color(0xFF3D4857);

  /// On secondary dark
  static const Color onSecondaryDark = Color(0xFF253140);

  /// On secondary container dark
  static const Color onSecondaryContainerDark = Color(0xFFD7E3F7);

  /// Tertiary dark
  static const Color tertiaryDark = Color(0xFFD6BEE4);

  /// Tertiary container dark
  static const Color tertiaryContainerDark = Color(0xFF523F5F);

  /// On tertiary dark
  static const Color onTertiaryDark = Color(0xFF3B2948);

  /// On tertiary container dark
  static const Color onTertiaryContainerDark = Color(0xFFF2DAFF);

  /// Error dark
  static const Color errorDark = Color(0xFFFFB4AB);

  /// Error container dark
  static const Color errorContainerDark = Color(0xFF93000A);

  /// On error dark
  static const Color onErrorDark = Color(0xFF690005);

  /// On error container dark
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  /// Surface dark
  static const Color surfaceDark = Color(0xFF1A1C1E);

  /// Surface variant dark
  static const Color surfaceVariantDark = Color(0xFF43474E);

  /// On surface dark
  static const Color onSurfaceDark = Color(0xFFE3E2E6);

  /// On surface variant dark
  static const Color onSurfaceVariantDark = Color(0xFFC3C6CF);

  /// Outline dark
  static const Color outlineDark = Color(0xFF8D9199);

  /// Outline variant dark
  static const Color outlineVariantDark = Color(0xFF43474E);

  /// Background dark
  static const Color backgroundDark = Color(0xFF1A1C1E);

  /// On background dark
  static const Color onBackgroundDark = Color(0xFFE3E2E6);

  /// Inverse surface dark
  static const Color inverseSurfaceDark = Color(0xFFE3E2E6);

  /// On inverse surface dark
  static const Color onInverseSurfaceDark = Color(0xFF2F3033);

  /// Inverse primary dark
  static const Color inversePrimaryDark = Color(0xFF0066CC);

  // ============== Legacy Colors (For backwards compatibility) ==============
  /// Old primary blue color for backwards compatibility
  static const Color legacyBlue = Color(0xFF3d8fdc);

  // ============== Custom Application Colors ==============
  /// Sidebar background
  static const Color sidebarBackground = Color(0xFFF5F5F5);

  /// Sidebar background dark
  static const Color sidebarBackgroundDark = Color(0xFF252525);

  /// Card elevation shadow
  static const Color cardShadow = Color(0x1A000000);

  /// DataGrid header color
  static const Color dataGridHeader = Color(0xFFF5F5F5);

  /// DataGrid header color dark
  static const Color dataGridHeaderDark = Color(0xFF2D2D2D);

  /// DataGrid row alternate color
  static const Color dataGridRowAlt = Color(0xFFFAFAFA);

  /// DataGrid row alternate color dark
  static const Color dataGridRowAltDark = Color(0xFF252525);

  /// Selected row color
  static const Color selectedRow = Color(0xFFE3F2FD);

  /// Selected row color dark
  static const Color selectedRowDark = Color(0xFF1A3A5C);
}

/// Light Color Scheme for Material 3
ColorScheme get lightColorScheme => ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    );

/// Dark Color Scheme for Material 3
ColorScheme get darkColorScheme => ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.onPrimaryContainerDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      secondaryContainer: AppColors.secondaryContainerDark,
      onSecondaryContainer: AppColors.onSecondaryContainerDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      tertiaryContainer: AppColors.tertiaryContainerDark,
      onTertiaryContainer: AppColors.onTertiaryContainerDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
      errorContainer: AppColors.errorContainerDark,
      onErrorContainer: AppColors.onErrorContainerDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceVariant: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurfaceDark,
      onInverseSurface: AppColors.onInverseSurfaceDark,
      inversePrimary: AppColors.inversePrimaryDark,
      surfaceTint: AppColors.primaryDark,
    );
