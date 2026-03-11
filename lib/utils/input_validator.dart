import 'package:flutter/material.dart';

/// Input Validation Helper
/// Provides validation methods for form inputs
class InputValidator {
  InputValidator._();

  /// Validate username
  /// - Required field
  /// - Minimum 3 characters
  /// - Only alphanumeric and underscore allowed
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    if (value.trim().length > 50) {
      return 'اسم المستخدم طويل جداً';
    }
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام فقط';
    }
    return null;
  }

  /// Validate password
  /// - Required field
  /// - Minimum 6 characters
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    if (value.length > 100) {
      return 'كلمة المرور طويلة جداً';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    // Accepts Arabic and international phone formats
    final phoneRegex = RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'رقم الهاتف غير صالح';
    }
    return null;
  }

  /// Validate number (positive)
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) {
      return '$fieldName يجب أن يكون رقماً';
    }
    if (number < 0) {
      return '$fieldName يجب أن يكون رقماً موجباً';
    }
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value, {bool allowZero = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'السعر مطلوب';
    }
    final price = double.tryParse(value.replaceAll(',', ''));
    if (price == null) {
      return 'السعر يجب أن يكون رقماً';
    }
    if (!allowZero && price <= 0) {
      return 'السعر يجب أن يكون أكبر من صفر';
    }
    if (price < 0) {
      return 'السعر لا يمكن أن يكون سالباً';
    }
    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value, {bool allowZero = true}) {
    if (value == null || value.trim().isEmpty) {
      return 'الكمية مطلوبة';
    }
    final quantity = double.tryParse(value.replaceAll(',', ''));
    if (quantity == null) {
      return 'الكمية يجب أن تكون رقماً';
    }
    if (!allowZero && quantity <= 0) {
      return 'الكمية يجب أن تكون أكبر من صفر';
    }
    if (quantity < 0) {
      return 'الكمية لا يمكن أن تكون سالبة';
    }
    return null;
  }

  /// Validate barcode
  static String? validateBarcode(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'الباركود مطلوب';
      return null;
    }
    if (value.length > 50) {
      return 'الباركود طويل جداً';
    }
    return null;
  }

  /// Validate name (Arabic/English)
  static String? validateName(String? value, String fieldName, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب';
    }
    if (value.trim().length < minLength) {
      return '$fieldName يجب أن يكون $minLength أحرف على الأقل';
    }
    if (value.trim().length > 100) {
      return '$fieldName طويل جداً';
    }
    return null;
  }

  /// Validate address
  static String? validateAddress(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'العنوان مطلوب';
      return null;
    }
    if (value.trim().length < 5) {
      return 'العنوان قصير جداً';
    }
    if (value.trim().length > 500) {
      return 'العنوان طويل جداً';
    }
    return null;
  }

  /// Validate note/comment
  static String? validateNote(String? value, {int maxLength = 1000}) {
    if (value == null || value.isEmpty) {
      return null; // Notes are usually optional
    }
    if (value.length > maxLength) {
      return 'الملاحظة طويلة جداً (الحد الأقصى $maxLength حرف)';
    }
    return null;
  }
}
