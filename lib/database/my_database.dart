import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/audit.dart';
import 'entities/store.dart';
import 'entities/user.dart';

/// this class will create the database and will contain
class MyDatabase {
  static late Database myDatabase;

  /// Initialize database factory for desktop platforms
  static void _initDatabaseFactory() {
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// create tables if not exist and triggers
  static Future<void> open() async {
    _initDatabaseFactory();

    String dbPath;
    
    // Get database path
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      dbPath = await getDatabasesPath();
      dbPath = p.join(dbPath, "myDb.db");
    } else {
      // Desktop platforms
      final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(appDocumentsDir.path, "databases", "myDb.db");
      
      // Ensure the directory exists
      final dbDir = io.Directory(p.dirname(dbPath));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }
    }

    // Open database with version control
    myDatabase = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Add currency columns to suppliers and supplier_transactions
          await _migrateToVersion2(db);
        }
      },
      onOpen: (Database db) async {
        // Enable foreign keys with error handling
        try {
          await db.execute("PRAGMA foreign_keys=ON");
        } catch (e) {
          // تجاهل الخطأ إذا فشل تفعيل مفاتيح الربط الأجنبي
          debugPrint('Warning: Could not enable foreign keys: $e');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    // Audits table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS audits(
      date INTEGER PRIMARY KEY, 
      table_name TEXT NOT NULL,
      entity_id INTEGER NOT NULL,
      action TEXT NOT NULL, 
      old_data TEXT, 
      new_data TEXT, 
      user_id INTEGER NOT NULL, 
      user_data TEXT NOT NULL
    )
    ''');
    
    // Currencies table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS currencies (
      name TEXT PRIMARY KEY,
      id INTEGER NOT NULL UNIQUE,
      exchange_rate REAL NOT NULL
    )
    ''');

    // Store table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS store (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      branch TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE,
      image BLOB, 
      updated_at INTEGER NOT NULL
    )
    ''');

    // Users table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      enabled INTEGER  CHECK( enabled IN (1, 0) ) NOT NULL DEFAULT 1,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT CHECK( role IN ('admin','cashier') ) NOT NULL DEFAULT 'cashier'
    )
    ''');
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('users', 100000)
    ''');

    // Units table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS units (
      name TEXT PRIMARY KEY
    )
    ''');
    
    // Insert default units
    await db.insert('units', {'name': 'قطعة'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'كيلو'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'طن'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'جرام'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'متر'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'سم'}, conflictAlgorithm: ConflictAlgorithm.ignore);
    
    // Materials table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      barcode TEXT UNIQUE,
      category TEXT NOT NULL,
      unit TEXT NOT NULL REFERENCES units(name) ON DELETE RESTRICT,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE,
      quantity REAL NOT NULL,
      cost_price REAL NOT NULL,
      sale_price REAL NOT NULL,
      note TEXT,
      larger_material_id INTEGER REFERENCES materials(id) ON DELETE RESTRICT,
      larger_quantity_supplied REAL
    )
    ''');

    // Expiries dates table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS expiries_dates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      date INTEGER NOT NULL,
      notify_before INTEGER NOT NULL
    )
    ''');

    // Customers table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      description TEXT
    )
    ''');
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('customers', 100000)
    ''');

    // Invoices table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT CHECK( type IN ('sale','return') ) NOT NULL,
      customer_id INTEGER REFERENCES customers(id) ON DELETE NO ACTION,
      date INTEGER NOT NULL, 
      discount REAL,
      total REAL NOT NULL,
      note TEXT
    )
    ''');
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('invoices', 100000)
    ''');

    // Invoices materials table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS invoices_materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
      quantity REAL NOT NULL,
      price REAL NOT NULL,
      note TEXT
    )
    ''');

    // Payments table
    await db.execute("""
    CREATE TABLE IF NOT EXISTS payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,    
      customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,  
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE,
      exchange_rate REAL NOT NULL, 
      note TEXT
    )
    """);
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('payments', 100000)
    ''');

    // Debts table
    await db.execute("""
    CREATE TABLE IF NOT EXISTS debts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,    
      customer_id INTEGER REFERENCES customers(id) ON DELETE RESTRICT,  
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      note TEXT
    )
    """);
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('debts', 100000)
    ''');

    // Debt payments table
    await db.execute("""
    CREATE TABLE IF NOT EXISTS debt_payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      debt_id INTEGER NOT NULL REFERENCES debts(id) ON DELETE CASCADE,    
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,  
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      exchange_rate REAL NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE,
      note TEXT
    )
    """);
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('debt_payments', 100000)
    ''');

    // Suppliers table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT NOT NULL,
      description TEXT
    )
    ''');
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('suppliers', 100000)
    ''');

    // Purchases table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS purchases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_id INTEGER REFERENCES suppliers(id) ON DELETE NO ACTION,
      date INTEGER NOT NULL, 
      type TEXT CHECK( type IN ('purchase','return') ) NOT NULL,
      discount REAL,
      note TEXT
    )
    ''');
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('purchases', 100000)
    ''');

    // Purchases materials table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS purchases_materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
      quantity REAL NOT NULL,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE, 
      cost_price REAL NOT NULL
    )
    ''');

    // Purchases payments table
    await db.execute("""
    CREATE TABLE IF NOT EXISTS purchases_payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER REFERENCES purchases(id) ON DELETE CASCADE,    
      supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,  
      date INTEGER NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE, 
      amount REAL NOT NULL, 
      note TEXT
    )
    """);
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('purchases_payments', 100000)
    ''');

    // Purchases debts table
    await db.execute("""
    CREATE TABLE IF NOT EXISTS purchases_debts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER REFERENCES purchases(id) ON DELETE CASCADE,    
      supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,  
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE, 
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      note TEXT
    )
    """);
    
    await db.execute('''
    INSERT OR IGNORE INTO sqlite_sequence (name, seq) VALUES ('purchases_debts', 100000)
    ''');
  }

  /// Migration to version 2: Add currency support to suppliers
  static Future<void> _migrateToVersion2(Database db) async {
    // Check if currency column exists in suppliers table
    final supplierColumns = await db.rawQuery("PRAGMA table_info(suppliers)");
    final hasSupplierCurrency = supplierColumns.any((col) => col['name'] == 'currency');
    
    if (!hasSupplierCurrency) {
      await db.execute("ALTER TABLE suppliers ADD COLUMN currency TEXT DEFAULT 'ر.س'");
      await db.execute("ALTER TABLE suppliers ADD COLUMN balance REAL DEFAULT 0");
      await db.execute("ALTER TABLE suppliers ADD COLUMN createdAt TEXT");
      await db.execute("ALTER TABLE suppliers ADD COLUMN updatedAt TEXT");
    }

    // Create supplier_transactions table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS supplier_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplierId INTEGER NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT DEFAULT 'ر.س',
        description TEXT DEFAULT '',
        invoiceId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (supplierId) REFERENCES suppliers (id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<Store?> getStoreData() async {
    var maps = await myDatabase.rawQuery('''
      SELECT * FROM store ORDER BY id DESC
    ''');
    if (maps.isEmpty) return null;
    return Store.fromMap(maps.first);
  }

  static Future<void> setStoreData(Store store) async {
    await MyDatabase.myDatabase.insert(
      'store',
      store.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> insertUser(User user, User? actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      user.id = await txn.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'users',
          entityId: user.id!,
          oldData: null,
          newData: Audit.mapToString(user.toMap()),
          userId: actionBy?.id! ?? user.id!,
          userData: Audit.mapToString(actionBy?.toMap() ?? user.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return user.id!;
    });
  }

  static Future<User?> getUser(String username, String password) async {
    var maps = await MyDatabase.myDatabase.query(
      'users',
      where: 'username = ? and password = ?',
      whereArgs: [username, password],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  static Future close() async => MyDatabase.myDatabase.close();
}
