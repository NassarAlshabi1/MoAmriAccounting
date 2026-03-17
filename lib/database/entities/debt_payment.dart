class DebtPayment {
  int? id;
  final int debtId;
  final int customerId;
  final int date;
  final double amount;
  final double exchangeRate;
  final String currency;
  final String? note;

  DebtPayment({
    this.id,
    required this.debtId,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.exchangeRate,
    required this.currency,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debt_id': debtId,
      'customer_id': customerId,
      'date': date,
      'amount': amount,
      'exchange_rate': exchangeRate,
      'currency': currency,
      'note': note,
    };
  }

  static DebtPayment fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      customerId: map['customer_id'] as int,
      date: map['date'] as int,
      amount: map['amount'] as double,
      exchangeRate: map['exchange_rate'] as double,
      currency: map['currency'] as String,
      note: map['note'] as String?,
    );
  }
}
