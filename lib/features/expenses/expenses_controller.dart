import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Expense Model
class Expense {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String note;

  Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'currency': currency,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String? ?? '',
    );
  }
}

/// Expense Category Model
class ExpenseCategory {
  final String name;
  final String icon;
  final String color;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Expenses Controller
///
/// Manages expenses state and database operations
class ExpensesController extends GetxController {
  // State
  RxList<Expense> expenses = <Expense>[].obs;
  RxList<ExpenseCategory> categories = <ExpenseCategory>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString selectedPeriod = 'today'.obs; // today, week, month, custom
  RxString selectedCategory = 'all'.obs;

  // Date range for custom filter
  Rx<DateTime> startDate = Rx(DateTime.now().subtract(const Duration(days: 30)));
  Rx<DateTime> endDate = Rx(DateTime.now());

  // Summary stats
  RxDouble todayTotal = 0.0.obs;
  RxDouble weekTotal = 0.0.obs;
  RxDouble monthTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadExpenses();
  }

  /// Load expense categories
  Future<void> loadCategories() async {
    // Default categories
    categories.value = [
      ExpenseCategory(name: 'رواتب', icon: 'people', color: 'primary'),
      ExpenseCategory(name: 'إيجار', icon: 'home', color: 'info'),
      ExpenseCategory(name: 'فواتير', icon: 'receipt', color: 'warning'),
      ExpenseCategory(name: 'مشتريات', icon: 'shopping_cart', color: 'success'),
      ExpenseCategory(name: 'صيانة', icon: 'build', color: 'secondary'),
      ExpenseCategory(name: 'أخرى', icon: 'more', color: 'grey'),
    ];
  }

  /// Load expenses
  Future<void> loadExpenses() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // For now, use a simplified approach
      // In production, this would query from actual expenses table
      final db = MyDatabase.myDatabase;

      // Check if expenses table exists
      try {
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='expenses'",
        );

        if (tables.isEmpty) {
          // Create expenses table
          await db.execute('''
            CREATE TABLE expenses (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              category TEXT NOT NULL,
              amount REAL NOT NULL,
              currency TEXT NOT NULL,
              date INTEGER NOT NULL,
              note TEXT
            )
          ''');
        }

        // Query expenses
        final List<Map<String, dynamic>> maps = await db.query(
          'expenses',
          orderBy: 'date DESC',
        );

        expenses.value = maps.map((map) => Expense.fromMap(map)).toList();
      } catch (e) {
        // Table doesn't exist yet
        expenses.value = [];
      }

      // Calculate summaries
      calculateSummaries();

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل المصروفات: $e';
      isLoading.value = false;
    }
  }

  /// Calculate expense summaries
  void calculateSummaries() {
    final now = DateTime.now();

    // Today
    todayTotal.value = expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Week
    final weekAgo = now.subtract(const Duration(days: 7));
    weekTotal.value = expenses
        .where((e) => e.date.isAfter(weekAgo))
        .fold<double>(0, (sum, e) => sum + e.amount);

    // Month
    monthTotal.value = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  /// Add expense
  Future<bool> addExpense(Expense expense) async {
    try {
      final db = MyDatabase.myDatabase;
      final id = await db.insert('expenses', expense.toMap());
      expenses.insert(0, Expense(
        id: id,
        title: expense.title,
        category: expense.category,
        amount: expense.amount,
        currency: expense.currency,
        date: expense.date,
        note: expense.note,
      ));
      calculateSummaries();
      return true;
    } catch (e) {
      errorMessage.value = 'فشل في إضافة المصروف: $e';
      return false;
    }
  }

  /// Update expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      final db = MyDatabase.myDatabase;
      await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );

      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        expenses[index] = expense;
      }
      calculateSummaries();
      return true;
    } catch (e) {
      errorMessage.value = 'فشل في تحديث المصروف: $e';
      return false;
    }
  }

  /// Delete expense
  Future<bool> deleteExpense(int id) async {
    try {
      final db = MyDatabase.myDatabase;
      await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
      expenses.removeWhere((e) => e.id == id);
      calculateSummaries();
      return true;
    } catch (e) {
      errorMessage.value = 'فشل في حذف المصروف: $e';
      return false;
    }
  }

  /// Get filtered expenses
  List<Expense> getFilteredExpenses() {
    var filtered = expenses.toList();

    // Filter by period
    final now = DateTime.now();
    switch (selectedPeriod.value) {
      case 'today':
        filtered = filtered
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
        break;
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((e) => e.date.isAfter(weekAgo)).toList();
        break;
      case 'month':
        filtered = filtered
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        break;
      case 'custom':
        filtered = filtered
            .where((e) =>
                e.date.isAfter(startDate.value) &&
                e.date.isBefore(endDate.value.add(const Duration(days: 1))))
            .toList();
        break;
    }

    // Filter by category
    if (selectedCategory.value != 'all') {
      filtered = filtered.where((e) => e.category == selectedCategory.value).toList();
    }

    return filtered;
  }

  /// Get category totals
  Map<String, double> getCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in getFilteredExpenses()) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadExpenses();
  }

  /// Set period filter
  void setPeriod(String period) {
    selectedPeriod.value = period;
  }

  /// Set category filter
  void setCategory(String category) {
    selectedCategory.value = category;
  }

  /// Set custom date range
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'custom';
  }
}
