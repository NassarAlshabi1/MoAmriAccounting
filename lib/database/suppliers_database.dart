import 'package:sqflite/sqflite.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/database/entities/supplier.dart';

/// Suppliers Database
///
/// Handles all database operations for suppliers and their transactions.
class SuppliersDatabase {
  /// Create suppliers table
  static const String createSuppliersTable = '''
    CREATE TABLE suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT DEFAULT '',
      address TEXT DEFAULT '',
      email TEXT DEFAULT '',
      description TEXT DEFAULT '',
      balance REAL DEFAULT 0,
      createdAt TEXT NOT NULL,
      updatedAt TEXT
    )
  ''';

  /// Create supplier transactions table
  static const String createSupplierTransactionsTable = '''
    CREATE TABLE supplier_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplierId INTEGER NOT NULL,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      description TEXT DEFAULT '',
      invoiceId INTEGER,
      createdAt TEXT NOT NULL,
      FOREIGN KEY (supplierId) REFERENCES suppliers (id) ON DELETE CASCADE
    )
  ''';

  /// Insert a new supplier
  static Future<int> insertSupplier(Supplier supplier) async {
    final db = await MyDatabase.getInstance();
    return await db.insert(
      'suppliers',
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing supplier
  static Future<int> updateSupplier(Supplier supplier) async {
    final db = await MyDatabase.getInstance();
    return await db.update(
      'suppliers',
      supplier.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  /// Delete a supplier
  static Future<int> deleteSupplier(int id) async {
    final db = await MyDatabase.getInstance();
    // First delete all transactions
    await db.delete(
      'supplier_transactions',
      where: 'supplierId = ?',
      whereArgs: [id],
    );
    // Then delete the supplier
    return await db.delete(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all suppliers
  static Future<List<Supplier>> getAllSuppliers({
    String orderBy = 'name',
    bool ascending = true,
  }) async {
    final db = await MyDatabase.getInstance();
    final results = await db.query(
      'suppliers',
      orderBy: '$orderBy ${ascending ? 'ASC' : 'DESC'}',
    );
    return results.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Get supplier by ID
  static Future<Supplier?> getSupplierById(int id) async {
    final db = await MyDatabase.getInstance();
    final results = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Supplier.fromMap(results.first);
  }

  /// Search suppliers by name or phone
  static Future<List<Supplier>> searchSuppliers(String query) async {
    final db = await MyDatabase.getInstance();
    final results = await db.query(
      'suppliers',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return results.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Get suppliers with debts
  static Future<List<Supplier>> getSuppliersWithDebts() async {
    final db = await MyDatabase.getInstance();
    final results = await db.query(
      'suppliers',
      where: 'balance > 0',
      orderBy: 'balance DESC',
    );
    return results.map((map) => Supplier.fromMap(map)).toList();
  }

  /// Get suppliers count
  static Future<int> getSuppliersCount() async {
    final db = await MyDatabase.getInstance();
    final results = await db.rawQuery(
      'SELECT COUNT(*) as count FROM suppliers',
    );
    return results.first['count'] as int;
  }

  /// Get total debts to suppliers
  static Future<double> getTotalDebtsToSuppliers() async {
    final db = await MyDatabase.getInstance();
    final results = await db.rawQuery(
      'SELECT SUM(balance) as total FROM suppliers WHERE balance > 0',
    );
    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ===== Transaction Operations =====

  /// Add a transaction for a supplier
  static Future<int> addTransaction(SupplierTransaction transaction) async {
    final db = await MyDatabase.getInstance();
    
    // Start a transaction
    return await db.transaction((txn) async {
      // Insert the transaction
      final id = await txn.insert(
        'supplier_transactions',
        transaction.toMap(),
      );
      
      // Update supplier balance
      final balanceChange = transaction.type == 'purchase' 
          ? transaction.amount 
          : -transaction.amount;
      
      await txn.rawUpdate(
        'UPDATE suppliers SET balance = balance + ?, updatedAt = ? WHERE id = ?',
        [balanceChange, DateTime.now().toIso8601String(), transaction.supplierId],
      );
      
      return id;
    });
  }

  /// Get transactions for a supplier
  static Future<List<SupplierTransaction>> getSupplierTransactions(
    int supplierId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await MyDatabase.getInstance();
    final results = await db.query(
      'supplier_transactions',
      where: 'supplierId = ?',
      whereArgs: [supplierId],
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );
    return results.map((map) => SupplierTransaction.fromMap(map)).toList();
  }

  /// Get all transactions for a supplier (account statement)
  static Future<List<Map<String, dynamic>>> getSupplierAccountStatement(
    int supplierId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await MyDatabase.getInstance();
    
    String whereClause = 'supplierId = ?';
    List<dynamic> whereArgs = [supplierId];
    
    if (startDate != null) {
      whereClause += ' AND createdAt >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereClause += ' AND createdAt <= ?';
      whereArgs.add(endDate.toIso8601String());
    }
    
    final results = await db.query(
      'supplier_transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );
    
    return results;
  }

  /// Get recent supplier transactions (all suppliers)
  static Future<List<Map<String, dynamic>>> getRecentSupplierTransactions({
    int limit = 20,
  }) async {
    final db = await MyDatabase.getInstance();
    final results = await db.rawQuery('''
      SELECT st.*, s.name as supplierName
      FROM supplier_transactions st
      JOIN suppliers s ON st.supplierId = s.id
      ORDER BY st.createdAt DESC
      LIMIT ?
    ''', [limit]);
    return results;
  }
}
