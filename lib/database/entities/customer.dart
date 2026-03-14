/// Customer Entity
///
/// Represents a customer with contact info and account balance.
class Customer {
  int? id;
  final String name;
  final String phone;
  final String address;
  final String description;
  final double balance; // الرصيد المتبقي (دين للعميل)
  final DateTime createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.description = '',
    this.balance = 0.0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if customer has debt (owes money)
  bool get hasDebt => balance > 0;

  /// Get formatted balance
  String get formattedBalance {
    return '${balance.abs().toStringAsFixed(2)} ر.س';
  }

  /// Get balance status text
  String get balanceStatus {
    if (balance > 0) return 'مدين';
    if (balance < 0) return 'دائن';
    return 'لا يوجد رصيد';
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'Customer(id: $id, name: $name, balance: $balance)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
