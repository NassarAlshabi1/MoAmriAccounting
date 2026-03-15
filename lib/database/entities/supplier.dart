/// Supplier Entity
///
/// Represents a supplier in the system with contact information and account tracking.
class Supplier {
  int? id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String description;
  final double balance; // Positive = we owe them, Negative = they owe us
  final String currency; // Preferred currency for this supplier
  final DateTime createdAt;
  final DateTime? updatedAt;

  Supplier({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.email = '',
    this.description = '',
    this.balance = 0.0,
    this.currency = 'ر.س', // Default: Saudi Riyal
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if supplier has debt (we owe them)
  bool get hasDebt => balance > 0;

  /// Get formatted balance with currency
  String get formattedBalance {
    if (balance == 0) return 'لا يوجد رصيد';
    return '${balance.abs().toStringAsFixed(2)} $currency';
  }

  /// Get balance status text
  String get balanceStatus {
    if (balance > 0) return 'مدين لنا';
    if (balance < 0) return 'دائن لنا';
    return 'لا يوجد رصيد';
  }

  /// Get currency symbol
  String get currencySymbol {
    if (currency == 'ر.س' || currency == 'SAR') return 'ر.س';
    if (currency == '\$' || currency == 'USD') return '\$';
    if (currency == 'د.إ' || currency == 'AED') return 'د.إ';
    if (currency == 'ر.ق' || currency == 'QAR') return 'ر.ق';
    if (currency == 'د.ك' || currency == 'KWD') return 'د.ك';
    if (currency == 'ج.م' || currency == 'EGP') return 'ج.م';
    if (currency == '€' || currency == 'EUR') return '€';
    if (currency == '£' || currency == 'GBP') return '£';
    return currency;
  }

  /// Get currency name in Arabic
  String get currencyName {
    if (currency == 'ر.س' || currency == 'SAR') return 'ريال سعودي';
    if (currency == '\$' || currency == 'USD') return 'دولار أمريكي';
    if (currency == 'د.إ' || currency == 'AED') return 'درهم إماراتي';
    if (currency == 'ر.ق' || currency == 'QAR') return 'ريال قطري';
    if (currency == 'د.ك' || currency == 'KWD') return 'دينار كويتي';
    if (currency == 'ج.م' || currency == 'EGP') return 'جنيه مصري';
    if (currency == '€' || currency == 'EUR') return 'يورو';
    if (currency == '£' || currency == 'GBP') return 'جنيه استرليني';
    return currency;
  }

  /// Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'description': description,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from map
  static Supplier fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      email: map['email'] as String? ?? '',
      description: map['description'] as String? ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'ر.س',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Create a copy with modified fields
  Supplier copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? email,
    String? description,
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      email: email ?? this.email,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Supplier(id: $id, name: $name, balance: $balance $currency)';
}

/// Supplier Transaction Entity
///
/// Represents a transaction with a supplier (purchase, payment, etc.)
class SupplierTransaction {
  int? id;
  final int supplierId;
  final String type; // 'purchase', 'payment', 'return'
  final double amount;
  final String currency; // Currency of transaction
  final String description;
  final int? invoiceId;
  final DateTime createdAt;

  SupplierTransaction({
    this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    this.currency = 'ر.س',
    this.description = '',
    this.invoiceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get transaction type display name
  String get typeDisplayName {
    switch (type) {
      case 'purchase':
        return 'شراء';
      case 'payment':
        return 'سداد';
      case 'return':
        return 'مرتجع';
      default:
        return type;
    }
  }

  /// Check if transaction increases our debt to supplier
  bool get increasesDebt => type == 'purchase';

  /// Get formatted amount with currency
  String get formattedAmount => '${amount.toStringAsFixed(2)} $currency';

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'description': description,
      'invoiceId': invoiceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from map
  static SupplierTransaction fromMap(Map<String, dynamic> map) {
    return SupplierTransaction(
      id: map['id'] as int?,
      supplierId: map['supplierId'] as int,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'ر.س',
      description: map['description'] as String? ?? '',
      invoiceId: map['invoiceId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
