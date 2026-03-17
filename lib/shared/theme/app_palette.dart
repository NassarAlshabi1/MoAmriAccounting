import 'package:flutter/material.dart';

/// App Color Palette - Professional Accounting App Theme
///
/// Based on Material 3 Design System
/// Primary: Deep Blue for trust and professionalism
/// Secondary: Slate Gray for neutrality
/// Accent colors for financial operations

class AppPalette {
  // ========== Primary Colors (Deep Blue) ==========
  static const Color primary = Color(0xFF1A5F7A);
  static const Color primaryLight = Color(0xFF2E8BA8);
  static const Color primaryDark = Color(0xFF0D3D4F);
  static const Color primaryContainer = Color(0xFFE0F4F8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001F2A);

  // ========== Secondary Colors (Slate Gray) ==========
  static const Color secondary = Color(0xFF4A5568);
  static const Color secondaryLight = Color(0xFF718096);
  static const Color secondaryDark = Color(0xFF2D3748);
  static const Color secondaryContainer = Color(0xFFE2E8F0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1A202C);

  // ========== Financial Status Colors ==========
  // Income / Profit (Green)
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFF34D399);
  static const Color incomeDark = Color(0xFF059669);
  static const Color incomeContainer = Color(0xFFD1FAE5);

  // Expense / Loss (Red)
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFF87171);
  static const Color expenseDark = Color(0xFFDC2626);
  static const Color expenseContainer = Color(0xFFFEE2E2);

  // Warning / Pending (Amber)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);

  // Info (Blue)
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // ========== Neutral Colors ==========
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color onBackground = Color(0xFF1E293B);
  static const Color onSurface = Color(0xFF1E293B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);

  // ========== Text Colors ==========
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ========== Border Colors ==========
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderFocus = Color(0xFF1A5F7A);
  static const Color borderError = Color(0xFFEF4444);

  // ========== Currency Colors ==========
  static const Color riyal = Color(0xFF1A5F7A); // Saudi Riyal - Blue
  static const Color dollar = Color(0xFF059669); // US Dollar - Green
  static const Color other = Color(0xFF6B7280); // Other currencies - Gray
}

/// Dark Theme Colors
class AppPaletteDark {
  static const Color primary = Color(0xFF2E8BA8);
  static const Color primaryContainer = Color(0xFF0D3D4F);
  static const Color onPrimary = Color(0xFF001F2A);
  static const Color onPrimaryContainer = Color(0xFFE0F4F8);

  static const Color secondary = Color(0xFF718096);
  static const Color secondaryContainer = Color(0xFF2D3748);
  static const Color onSecondary = Color(0xFF1A202C);
  static const Color onSecondaryContainer = Color(0xFFE2E8F0);

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);

  static const Color outline = Color(0xFF475569);
  static const Color outlineVariant = Color(0xFF334155);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFF64748B);

  static const Color border = Color(0xFF334155);
}

/// Helper extension for context
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Financial status colors
  Color get incomeColor => isDarkMode ? AppPalette.incomeLight : AppPalette.income;
  Color get expenseColor => isDarkMode ? AppPalette.expenseLight : AppPalette.expense;
  Color get warningColor => isDarkMode ? AppPalette.warningLight : AppPalette.warning;
  Color get infoColor => isDarkMode ? AppPalette.infoLight : AppPalette.info;

  // Currency colors
  Color getCurrencyColor(String currency) {
    switch (currency.toLowerCase()) {
      case 'ريال':
      case 'sar':
      case 'riyal':
        return AppPalette.riyal;
      case 'دولار':
      case 'usd':
      case 'dollar':
        return AppPalette.dollar;
      default:
        return AppPalette.other;
    }
  }
}
