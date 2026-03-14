import 'package:flutter/material.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';

/// Customer Transaction Entity
///
/// Represents a financial transaction for a customer (invoice, payment, return).
class CustomerTransaction {
  int? id;
  final int customerId;
  final String type; // 'invoice', 'payment', 'return', 'opening_balance'
  final double amount;
  final double? balanceAfter; // الرصيد بعد العملية
  final String description;
  final int? invoiceId;
  final String? invoiceNumber;
  final String paymentMethod; // 'cash', 'card', 'credit'
  final DateTime createdAt;
  final int? createdBy;

  CustomerTransaction({
    this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.balanceAfter,
    this.description = '',
    this.invoiceId,
    this.invoiceNumber,
    this.paymentMethod = 'cash',
    DateTime? createdAt,
    this.createdBy,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get transaction type display name
  String get typeDisplayName {
    switch (type) {
      case 'invoice':
        return 'فاتورة بيع';
      case 'payment':
        return 'سداد';
      case 'return':
        return 'مرتجع';
      case 'opening_balance':
        return 'رصيد افتتاحي';
      default:
        return type;
    }
  }

  /// Get transaction type icon
  IconData get icon {
    switch (type) {
      case 'invoice':
        return Icons.receipt_long_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'return':
        return Icons.keyboard_return_rounded;
      case 'opening_balance':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  /// Get transaction color
  Color get color {
    switch (type) {
      case 'invoice':
        return AppPalette.expense; // يزيد الدين
      case 'payment':
        return AppPalette.income; // يقلل الدين
      case 'return':
        return AppPalette.warning; // يقلل الدين
      case 'opening_balance':
        return AppPalette.info;
      default:
        return AppPalette.textSecondary;
    }
  }

  /// Check if transaction increases customer's debt
  bool get increasesDebt => type == 'invoice' || type == 'opening_balance';

  /// Get signed amount (negative for payments/returns)
  double get signedAmount => increasesDebt ? amount : -amount;

  /// Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'description': description,
      'invoiceId': invoiceId,
      'invoiceNumber': invoiceNumber,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  /// Create from map
  static CustomerTransaction fromMap(Map<String, dynamic> map) {
    return CustomerTransaction(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      balanceAfter: (map['balanceAfter'] as num?)?.toDouble(),
      description: map['description'] as String? ?? '',
      invoiceId: map['invoiceId'] as int?,
      invoiceNumber: map['invoiceNumber'] as String?,
      paymentMethod: map['paymentMethod'] as String? ?? 'cash',
      createdAt: DateTime.parse(map['createdAt'] as String),
      createdBy: map['createdBy'] as int?,
    );
  }

  /// Create a copy with modified fields
  CustomerTransaction copyWith({
    int? id,
    int? customerId,
    String? type,
    double? amount,
    double? balanceAfter,
    String? description,
    int? invoiceId,
    String? invoiceNumber,
    String? paymentMethod,
    DateTime? createdAt,
    int? createdBy,
  }) {
    return CustomerTransaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() => 'CustomerTransaction(id: $id, type: $type, amount: $amount)';
}
