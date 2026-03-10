import 'package:moamri_accounting/database/entities/audit.dart';
import 'package:moamri_accounting/database/entities/debt.dart';
import 'package:moamri_accounting/database/entities/debt_payment.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DebtsDatabase {
  // Get all debts with customer info
  static Future<List<Map<String, dynamic>>> getAllDebts({
    int? customerId,
    String? orderBy,
    String? dir,
  }) async {
    String query = '''
      SELECT d.*, c.name as customer_name, c.phone as customer_phone,
             (d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
              FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as remaining_amount
      FROM debts d
      LEFT JOIN customers c ON d.customer_id = c.id
    ''';

    if (customerId != null) {
      query += ' WHERE d.customer_id = $customerId';
    }

    query += ' ORDER BY ${orderBy ?? "d.date"} COLLATE NOCASE ${dir ?? "DESC"}';

    return await MyDatabase.myDatabase.rawQuery(query);
  }

  // Get active debts (with remaining amount > 0)
  static Future<List<Map<String, dynamic>>> getActiveDebts({
    String? orderBy,
    String? dir,
  }) async {
    return await MyDatabase.myDatabase.rawQuery('''
      SELECT d.*, c.name as customer_name, c.phone as customer_phone,
             (d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
              FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as remaining_amount
      FROM debts d
      LEFT JOIN customers c ON d.customer_id = c.id
      WHERE (d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
            FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) > 0
      ORDER BY ${orderBy ?? "d.date"} COLLATE NOCASE ${dir ?? "DESC"}
    ''');
  }

  // Get debt payments for a specific debt
  static Future<List<DebtPayment>> getDebtPayments(int debtId) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
      'debt_payments',
      where: 'debt_id = ?',
      whereArgs: [debtId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => DebtPayment.fromMap(map)).toList();
  }

  // Get total debt for a customer
  static Future<double> getCustomerTotalDebt(int customerId) async {
    List<Map<String, dynamic>> result = await MyDatabase.myDatabase.rawQuery('''
      SELECT SUM(d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
           FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as total_debt
      FROM debts d
      WHERE d.customer_id = $customerId
    ''');

    if (result.isEmpty || result.first['total_debt'] == null) {
      return 0;
    }
    return result.first['total_debt'] as double;
  }

  // Add debt payment
  static Future<int> addDebtPayment(
    DebtPayment payment,
    User actionBy,
  ) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      int paymentId = await txn.insert(
        'debt_payments',
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add_payment',
          table: 'debt_payments',
          entityId: paymentId,
          oldData: null,
          newData: Audit.mapToString(payment.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return paymentId;
    });
  }

  // Update debt
  static Future<void> updateDebt(
    Debt debt,
    Debt oldDebt,
    User actionBy,
  ) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.update(
        'debts',
        debt.toMap(),
        where: 'id = ?',
        whereArgs: [debt.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'update',
          table: 'debts',
          entityId: debt.id!,
          oldData: Audit.mapToString(oldDebt.toMap()),
          newData: Audit.mapToString(debt.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // Delete debt (only if fully paid)
  static Future<bool> deleteDebt(int debtId, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      // Check if debt has remaining amount
      List<Map<String, dynamic>> debtCheck = await txn.rawQuery('''
        SELECT (d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
             FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as remaining_amount
        FROM debts d
        WHERE d.id = $debtId
      ''');

      if (debtCheck.isEmpty) return false;

      double remaining = debtCheck.first['remaining_amount'] as double? ?? 0;
      if (remaining > 0) return false;

      // Delete debt payments first
      await txn.delete(
        'debt_payments',
        where: 'debt_id = ?',
        whereArgs: [debtId],
      );

      // Delete debt
      await txn.delete(
        'debts',
        where: 'id = ?',
        whereArgs: [debtId],
      );

      return true;
    });
  }

  // Get debts count
  static Future<int> getDebtsCount({int? customerId}) async {
    String query = customerId != null
        ? 'SELECT COUNT(id) FROM debts WHERE customer_id = $customerId'
        : 'SELECT COUNT(id) FROM debts';

    List<Map<String, Object?>> result =
        await MyDatabase.myDatabase.rawQuery(query);
    return int.tryParse(result[0]["COUNT(id)"].toString()) ?? 0;
  }

  // Get total debts amount
  static Future<double> getTotalDebtsAmount() async {
    List<Map<String, dynamic>> result = await MyDatabase.myDatabase.rawQuery('''
      SELECT SUM(d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
           FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as total
      FROM debts d
    ''');

    if (result.isEmpty || result.first['total'] == null) {
      return 0;
    }
    return result.first['total'] as double;
  }

  // Get debt by ID
  static Future<Map<String, dynamic>?> getDebtById(int debtId) async {
    List<Map<String, dynamic>> result = await MyDatabase.myDatabase.rawQuery('''
      SELECT d.*, c.name as customer_name, c.phone as customer_phone,
             (d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
              FROM debt_payments dp WHERE dp.debt_id = d.id), 0)) as remaining_amount
      FROM debts d
      LEFT JOIN customers c ON d.customer_id = c.id
      WHERE d.id = $debtId
    ''');

    return result.isEmpty ? null : result.first;
  }

  // Get debts summary by customer for reports
  static Future<List<Map<String, dynamic>>> getDebtsSummaryByCustomer() async {
    return await MyDatabase.myDatabase.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.phone,
        COUNT(d.id) as debts_count,
        IFNULL(SUM(d.amount), 0) as total_debt,
        IFNULL(SUM(d.amount - IFNULL((SELECT SUM(dp.amount * dp.exchange_rate) 
             FROM debt_payments dp WHERE dp.debt_id = d.id), 0)), 0) as remaining_amount
      FROM customers c
      LEFT JOIN debts d ON c.id = d.customer_id
      GROUP BY c.id
      HAVING total_debt > 0
      ORDER BY remaining_amount DESC
    ''');
  }
}
