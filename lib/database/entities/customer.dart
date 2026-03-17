/// Customer Entity
///
/// Represents a customer with contact info, account balance, and preferred currency.
class Customer {
  int? id;
  final String name;
  final String phone;
  final String address;
  final String description;
  final double balance; // الرصيد المتبقي (دين للعميل)
  final String currency; // العملة المفضلة للتعامل مع هذا العميل
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.description = '',
    this.balance = 0.0,
    this.currency = 'ر.س', // الافتراضي ريال سعودي
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if customer has debt (owes money)
  bool get hasDebt => balance > 0;

  /// Get formatted balance with currency
  String get formattedBalance {
    return '${balance.abs().toStringAsFixed(2)} $currency';
  }

  /// Get balance status text
  String get balanceStatus {
    if (balance > 0) return 'مدين';
    if (balance < 0) return 'دائن';
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
      'description': description,
      'balance': balance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from map
  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
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
  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? description,
    double? balance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Customer(id: $id, name: $name, balance: $balance $currency)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Available Currencies
class AppCurrency {
  final String code;
  final String symbol;
  final String nameAr;
  final String nameEn;

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.nameAr,
    required this.nameEn,
  });

  static const List<AppCurrency> available = [
    AppCurrency(code: 'SAR', symbol: 'ر.س', nameAr: 'ريال سعودي', nameEn: 'Saudi Riyal'),
    AppCurrency(code: 'USD', symbol: '\$', nameAr: 'دولار أمريكي', nameEn: 'US Dollar'),
    AppCurrency(code: 'AED', symbol: 'د.إ', nameAr: 'درهم إماراتي', nameEn: 'UAE Dirham'),
    AppCurrency(code: 'QAR', symbol: 'ر.ق', nameAr: 'ريال قطري', nameEn: 'Qatari Riyal'),
    AppCurrency(code: 'KWD', symbol: 'د.ك', nameAr: 'دينار كويتي', nameEn: 'Kuwaiti Dinar'),
    AppCurrency(code: 'EGP', symbol: 'ج.م', nameAr: 'جنيه مصري', nameEn: 'Egyptian Pound'),
    AppCurrency(code: 'EUR', symbol: '€', nameAr: 'يورو', nameEn: 'Euro'),
    AppCurrency(code: 'GBP', symbol: '£', nameAr: 'جنيه استرليني', nameEn: 'British Pound'),
  ];

  static AppCurrency fromCode(String code) {
    return available.firstWhere(
      (c) => c.code == code || c.symbol == code,
      orElse: () => available.first,
    );
  }
}
