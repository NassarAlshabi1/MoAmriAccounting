import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'app_colors.dart';

/// Custom Widgets Theme - Material 3 Styling for Custom Components
/// This file defines theme styles for custom widgets and third-party packages
/// like Syncfusion DataGrid.

class CustomWidgetsTheme {
  // Private constructor to prevent instantiation
  CustomWidgetsTheme._();

  // ============== Syncfusion DataGrid Theme ==============
  /// Light theme for Syncfusion DataGrid
  static SfDataGridThemeData get lightDataGridTheme => SfDataGridThemeData(
        headerColor: AppColors.dataGridHeader,
        headerHoverColor: AppColors.primaryContainer,
        currentCellStyle: DataGridCurrentCellStyle(
          borderColor: AppColors.primary,
          borderWidth: 2,
        ),
        frozenPaneElevation: 0,
        frozenPaneLineColor: AppColors.outlineVariant,
        gridLineColor: AppColors.outlineVariant,
        gridLineStrokeWidth: 1,
        sortIconColor: AppColors.primary,
        filterIconColor: AppColors.primary,
        filterIconHoverColor: AppColors.primaryContainer,
      );

  /// Dark theme for Syncfusion DataGrid
  static SfDataGridThemeData get darkDataGridTheme => SfDataGridThemeData(
        headerColor: AppColors.dataGridHeaderDark,
        headerHoverColor: AppColors.primaryContainerDark,
        currentCellStyle: DataGridCurrentCellStyle(
          borderColor: AppColors.primaryDark,
          borderWidth: 2,
        ),
        frozenPaneElevation: 0,
        frozenPaneLineColor: AppColors.outlineVariantDark,
        gridLineColor: AppColors.outlineVariantDark,
        gridLineStrokeWidth: 1,
        sortIconColor: AppColors.primaryDark,
        filterIconColor: AppColors.primaryDark,
        filterIconHoverColor: AppColors.primaryContainerDark,
      );

  // ============== Custom Button Styles ==============
  /// Primary button style - for main actions
  static ButtonStyle primaryButtonStyle({Color? backgroundColor, Color? foregroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.onPrimary,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Secondary button style - for less prominent actions
  static ButtonStyle secondaryButtonStyle({Color? backgroundColor, Color? foregroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.secondaryContainer,
      foregroundColor: foregroundColor ?? AppColors.onSecondaryContainer,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Success button style - for positive actions
  static ButtonStyle successButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.onSuccess,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Danger/Destructive button style
  static ButtonStyle dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.onError,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Warning button style
  static ButtonStyle warningButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.warning,
      foregroundColor: AppColors.onWarning,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============== Outlined Button Styles ==============
  /// Primary outlined button style
  static ButtonStyle primaryOutlinedButtonStyle({Color? foregroundColor}) {
    return OutlinedButton.styleFrom(
      foregroundColor: foregroundColor ?? AppColors.primary,
      side: BorderSide(color: foregroundColor ?? AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Success outlined button style
  static ButtonStyle successOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.success,
      side: const BorderSide(color: AppColors.success, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Danger outlined button style
  static ButtonStyle dangerOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.error,
      side: const BorderSide(color: AppColors.error, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Neutral outlined button style
  static ButtonStyle neutralOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.onSurfaceVariant,
      side: const BorderSide(color: AppColors.outline, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============== Custom Input Decoration ==============
  /// Primary input decoration for forms
  static InputDecoration primaryInputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor ?? AppColors.surface,
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        color: AppColors.onSurfaceVariant,
      ),
      labelStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        color: AppColors.onSurfaceVariant,
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 12,
        color: AppColors.primary,
      ),
    );
  }

  /// Search input decoration
  static InputDecoration searchInputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surface,
      hintText: hintText ?? 'بحث...',
      prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  // ============== Custom Card Styles ==============
  /// Primary card decoration
  static BoxDecoration primaryCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.outlineVariant,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Elevated card decoration with shadow
  static BoxDecoration elevatedCardDecoration({
    Color? backgroundColor,
    double borderRadius = 12.0,
    double elevation = 4.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.1 * elevation / 4),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation / 2),
        ),
      ],
    );
  }

  // ============== Custom Container Styles ==============
  /// Section container decoration
  static BoxDecoration sectionContainerDecoration({
    String? title,
    Color? borderColor,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: borderColor ?? AppColors.primary.withOpacity(0.5),
        width: 1,
      ),
    );
  }

  /// Info box decoration
  static BoxDecoration infoBoxDecoration({
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.primaryContainer.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: borderColor ?? AppColors.primary.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Success box decoration
  static BoxDecoration successBoxDecoration() {
    return BoxDecoration(
      color: AppColors.successContainer.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: AppColors.success.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Error box decoration
  static BoxDecoration errorBoxDecoration() {
    return BoxDecoration(
      color: AppColors.errorContainer.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: AppColors.error.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Warning box decoration
  static BoxDecoration warningBoxDecoration() {
    return BoxDecoration(
      color: AppColors.warningContainer.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: AppColors.warning.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  // ============== Custom Text Styles ==============
  /// Heading text styles
  static TextStyle get headingLarge => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      );

  static TextStyle get headingMedium => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get headingSmall => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  /// Body text styles
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.onSurfaceVariant,
      );

  /// Label text styles
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      );

  // ============== Custom Colors for Application Actions ==============
  /// Action colors
  static Color get addActionColor => AppColors.primary;
  static Color get editActionColor => AppColors.success;
  static Color get deleteActionColor => AppColors.error;
  static Color get printActionColor => AppColors.secondary;
  static Color get searchActionColor => AppColors.primary;

  // ============== Status Colors ==============
  /// Status indicator colors
  static Color get activeStatusColor => AppColors.success;
  static Color get inactiveStatusColor => AppColors.onSurfaceVariant;
  static Color get pendingStatusColor => AppColors.warning;
  static Color get errorStatusColor => AppColors.error;

  // ============== Priority Colors ==============
  /// Priority indicator colors
  static Color get highPriorityColor => AppColors.error;
  static Color get mediumPriorityColor => AppColors.warning;
  static Color get lowPriorityColor => AppColors.success;

  // ============== Helper Methods ==============
  /// Get button style by action type
  static ButtonStyle getButtonStyleByAction(String action) {
    switch (action.toLowerCase()) {
      case 'add':
      case 'create':
        return primaryButtonStyle();
      case 'edit':
      case 'update':
        return successButtonStyle();
      case 'delete':
        return dangerButtonStyle();
      case 'print':
        return secondaryButtonStyle(
          backgroundColor: AppColors.secondaryContainer,
          foregroundColor: AppColors.onSecondaryContainer,
        );
      default:
        return primaryButtonStyle();
    }
  }

  /// Get outlined button style by action type
  static ButtonStyle getOutlinedButtonStyleByAction(String action) {
    switch (action.toLowerCase()) {
      case 'add':
      case 'create':
        return primaryOutlinedButtonStyle();
      case 'edit':
      case 'update':
        return successOutlinedButtonStyle();
      case 'delete':
        return dangerOutlinedButtonStyle();
      case 'print':
        return neutralOutlinedButtonStyle();
      default:
        return primaryOutlinedButtonStyle();
    }
  }
}
