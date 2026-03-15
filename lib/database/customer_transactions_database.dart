import 'package:sqflite/sqflite.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/database/entities/customer_transaction.dart';

/// Customer Transactions Database
///
/// Handles all database operations for customer transactions and account statements.
class CustomerTransactionsDatabase {
  /// Create customer transactions table
  static const String createCustomerTransactionsTable = '''
    CREATE TABLE customer_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId INTEGER NOT NULL,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      balanceAfter REAL,
      description TEXT DEFAULT '',
      invoiceId INTEGER,
      invoiceNumber TEXT,
      paymentMethod TEXT DEFAULT 'cash',
      createdAt TEXT NOT NULL,
      createdBy INTEGER,
      FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
    )
  ''';

  /// Add a transaction for a customer
  static Future<int> addTransaction(CustomerTransaction transaction) async {
    final db = MyDatabase.myDatabase;
    
    return await db.transaction((txn) async {
      // Insert the transaction
      final id = await txn.insert(
        'customer_transactions',
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // Update customer balance
      final balanceChange = transaction.signedAmount;
      
      await txn.rawUpdate('''
        UPDATE customers 
        SET balance = IFNULL(balance, 0) + ?, 
            updatedAt = ? 
        WHERE id = ?
      ''', [balanceChange, DateTime.now().toIso8601String(), transaction.customerId]);
      
      // Get the new balance and update the transaction
      final balanceResult = await txn.rawQuery(
        'SELECT IFNULL(balance, 0) as balance FROM customers WHERE id = ?',
        [transaction.customerId],
      );
      
      if (balanceResult.isNotEmpty) {
        final newBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0.0;
        await txn.update(
          'customer_transactions',
          {'balanceAfter': newBalance},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      
      return id;
    });
  }

  /// Get transactions for a customer
  static Future<List<CustomerTransaction>> getCustomerTransactions(
    int customerId, {
    int limit = 50,
    int offset = 0,
    String? typeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = MyDatabase.myDatabase;
    
    String whereClause = 'customerId = ?';
    List<dynamic> whereArgs = [customerId];
    
    if (typeFilter != null && typeFilter != 'all') {
      whereClause += ' AND type = ?';
      whereArgs.add(typeFilter);
    }
    
    if (startDate != null) {
      whereClause += ' AND createdAt >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND createdAt <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final results = await db.query(
      'customer_transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    
    return results.map((map) => CustomerTransaction.fromMap(map)).toList();
  }

  /// Get customer account statement
  static Future<Map<String, dynamic>> getCustomerAccountStatement(
    int customerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = MyDatabase.myDatabase;
    
    String whereClause = 'customerId = ?';
    List<dynamic> whereArgs = [customerId];
    
    if (startDate != null) {
      whereClause += ' AND createdAt >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND createdAt <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    // Get transactions
    final transactions = await db.query(
      'customer_transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt ASC',
    );
    
    // Calculate totals
    double totalInvoices = 0;
    double totalPayments = 0;
    double totalReturns = 0;
    
    for (var t in transactions) {
      final amount = (t['amount'] as num).toDouble();
      final type = t['type'] as String;
      
      switch (type) {
        case 'invoice':
        case 'opening_balance':
          totalInvoices += amount;
          break;
        case 'payment':
          totalPayments += amount;
          break;
        case 'return':
          totalReturns += amount;
          break;
      }
    }
    
    // Get current balance
    final balanceResult = await db.rawQuery(
      'SELECT IFNULL(balance, 0) as balance FROM customers WHERE id = ?',
      [customerId],
    );
    
    final currentBalance = (balanceResult.first['balance'] as num?)?.toDouble() ?? 0.0;
    
    return {
      'transactions': transactions,
      'totalInvoices': totalInvoices,
      'totalPayments': totalPayments,
      'totalReturns': totalReturns,
      'currentBalance': currentBalance,
      'transactionsCount': transactions.length,
    };
  }

  /// Get customer balance
  static Future<double> getCustomerBalance(int customerId) async {
    final db = MyDatabase.myDatabase;
    final result = await db.rawQuery(
      'SELECT IFNULL(balance, 0) as balance FROM customers WHERE id = ?',
      [customerId],
    );
    return (result.first['balance'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get recent transactions for all customers
  static Future<List<Map<String, dynamic>>> getRecentTransactions({
    int limit = 20,
  }) async {
    final db = MyDatabase.myDatabase;
    final results = await db.rawQuery('''
      SELECT ct.*, c.name as customerName, c.phone as customerPhone
      FROM customer_transactions ct
      JOIN customers c ON ct.customerId = c.id
      ORDER BY ct.createdAt DESC
      LIMIT ?
    ''', [limit]);
    return results;
  }

  /// Delete a transaction (with balance adjustment)
  static Future<void> deleteTransaction(int transactionId) async {
    final db = MyDatabase.myDatabase;
    
    await db.transaction((txn) async {
      // Get the transaction first
      final transaction = await txn.query(
        'customer_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
        limit: 1,
      );
      
      if (transaction.isEmpty) return;
      
      final t = CustomerTransaction.fromMap(transaction.first);
      
      // Reverse the balance change
      final reverseChange = -t.signedAmount;
      
      await txn.rawUpdate('''
        UPDATE customers 
        SET balance = IFNULL(balance, 0) + ?
        WHERE id = ?
      ''', [reverseChange, t.customerId]);
      
      // Delete the transaction
      await txn.delete(
        'customer_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });
  }

  /// Get total debts for all customers
  static Future<double> getTotalCustomerDebts() async {
    final db = MyDatabase.myDatabase;
    final result = await db.rawQuery(
      'SELECT SUM(IFNULL(balance, 0)) as total FROM customers WHERE balance > 0',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get customers with debts
  static Future<List<Map<String, dynamic>>> getCustomersWithDebts({
    double minDebt = 0,
    String orderBy = 'balance',
    bool descending = true,
    int limit = 50,
  }) async {
    final db = MyDatabase.myDatabase;
    final results = await db.rawQuery('''
      SELECT id, name, phone, address, IFNULL(balance, 0) as balance
      FROM customers
      WHERE IFNULL(balance, 0) > ?
      ORDER BY $orderBy ${descending ? 'DESC' : 'ASC'}
      LIMIT ?
    ''', [minDebt, limit]);
    return results;
  }

  /// Get daily sales summary
  static Future<Map<String, dynamic>> getDailySummary(DateTime date) async {
    final db = MyDatabase.myDatabase;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.rawQuery('''
      SELECT 
        type,
        SUM(amount) as total,
        COUNT(*) as count
      FROM customer_transactions
      WHERE createdAt >= ? AND createdAt < ?
      GROUP BY type
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);
    
    double totalSales = 0;
    double totalPayments = 0;
    double totalReturns = 0;
    int invoicesCount = 0;
    
    for (var row in result) {
      final type = row['type'] as String;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      final count = (row['count'] as int?) ?? 0;
      
      switch (type) {
        case 'invoice':
          totalSales = total;
          invoicesCount = count;
          break;
        case 'payment':
          totalPayments = total;
          break;
        case 'return':
          totalReturns = total;
          break;
      }
    }
    
    return {
      'totalSales': totalSales,
      'totalPayments': totalPayments,
      'totalReturns': totalReturns,
      'invoicesCount': invoicesCount,
    };
  }

  /// Get total sales for a period
  static Future<double> getTotalSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = MyDatabase.myDatabase;
    
    String whereClause = "type = 'invoice'";
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND createdAt >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND createdAt <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM customer_transactions WHERE $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total payments for a period
  static Future<double> getTotalPayments({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = MyDatabase.myDatabase;
    
    String whereClause = "type = 'payment'";
    List<dynamic> whereArgs = [];
    
    if (startDate != null) {
      whereClause += ' AND createdAt >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClause += ' AND createdAt <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM customer_transactions WHERE $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Count customers with debts
  static Future<int> countCustomersWithDebts() async {
    final db = MyDatabase.myDatabase;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM customers WHERE IFNULL(balance, 0) > 0',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get overdue debts (debts older than specified days)
  static Future<List<Map<String, dynamic>>> getOverdueDebts({
    int overdueDays = 30,
    int limit = 50,
  }) async {
    final db = MyDatabase.myDatabase;
    final cutoffDate = DateTime.now().subtract(Duration(days: overdueDays));
    
    final results = await db.rawQuery('''
      SELECT c.id, c.name, c.phone, IFNULL(c.balance, 0) as balance,
             MAX(ct.createdAt) as lastTransaction
      FROM customers c
      LEFT JOIN customer_transactions ct ON c.id = ct.customerId
      WHERE IFNULL(c.balance, 0) > 0
      GROUP BY c.id
      HAVING MAX(ct.createdAt) < ?
      ORDER BY c.balance DESC
      LIMIT ?
    ''', [cutoffDate.toIso8601String(), limit]);
    
    return results;
  }

  /// Search customers by name or phone
  static Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    final db = MyDatabase.myDatabase;
    final trimQuery = query.trim();
    
    final results = await db.rawQuery('''
      SELECT id, name, phone, address, IFNULL(balance, 0) as balance
      FROM customers
      WHERE name LIKE ? OR phone LIKE ?
      ORDER BY name ASC
      LIMIT 50
    ''', ['%$trimQuery%', '%$trimQuery%']);
    
    return results;
  }
}
