import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path_provider/path_provider.dart';

import 'entities/audit.dart';
import 'entities/store.dart';
import 'entities/user.dart';

/// this class will create the database and will contain
class MyDatabase {
  static late Database myDatabase;

  /// create tables if not exist and triggers
  static Future<void> open() async {
    String dbPath;

    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      // Desktop platforms - use sqflite_common_ffi
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final io.Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      dbPath = p.join(appDocumentsDir.path, "databases", "myDb.db");

      // Ensure the directory exists
      final dbDir = io.Directory(p.dirname(dbPath));
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      myDatabase = await databaseFactory.openDatabase(dbPath);
    } else {
      // Mobile platforms (Android/iOS) - use regular sqflite
      final databasesPath = await sqflite.getDatabasesPath();
      dbPath = p.join(databasesPath, "myDb.db");
      myDatabase = await sqflite.openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    }

    // this is for making on delete cascade works
    await myDatabase.execute("PRAGMA foreign_keys=ON");

    // Create tables if they don't exist (for mobile platforms, this is handled in onCreate)
    if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
      await _createTables(myDatabase);
    }
  }

  static Future<void> _createTables(Database db) async {
    // data should be store a map data of change
    // user_data should be user map data
    // user_id just in case we want to query all user action
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
    await db.execute('''
    CREATE TABLE IF NOT EXISTS currencies (
      name TEXT PRIMARY KEY,
      id INTEGER NOT NULL UNIQUE,
      exchange_rate REAL NOT NULL
    )
    ''');

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
    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'users';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'users', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );

    await db.execute('''
    CREATE TABLE IF NOT EXISTS units (
      name TEXT PRIMARY KEY
    )
    ''');
    // insert the default units
    await db.insert('units', {'name': 'قطعة'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'كيلو'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'طن'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'جرام'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'متر'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await db.insert('units', {'name': 'سم'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
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

    await db.execute('''
    CREATE TABLE IF NOT EXISTS expiries_dates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      date INTEGER NOT NULL,
      notify_before INTEGER NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      description TEXT
    )
    ''');
    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'customers';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'customers', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );

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
    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'invoices';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'invoices', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );

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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'payments';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'payments', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
    // here we can not delete the customer except if we delete all his/her debts
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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'debts';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'debts', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
    // Debt payments table - for tracking partial debt payments
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
    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'debt_payments';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'debt_payments', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'suppliers';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'suppliers', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'purchases';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'purchases', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'purchases_payments';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'purchases_payments', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
    // here we can not delete the customer except if we delete all his/her debts
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

    await db.execute(
      '''
    BEGIN TRANSACTION;
    UPDATE sqlite_sequence SET seq = 100000 WHERE name = 'purchases_debts';
    INSERT INTO sqlite_sequence (name,seq) SELECT 'purchases_debts', 100000 WHERE NOT EXISTS 
              (SELECT changes() AS change FROM sqlite_sequence WHERE change <> 0);
    COMMIT;
    ''',
    );
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
