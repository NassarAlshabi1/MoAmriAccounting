import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/customer_transaction.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Debts Controller
///
/// Manages customer debts, payments, and account statements.
class DebtsController extends GetxController {
  // State
  RxList<Customer> customersWithDebts = <Customer>[].obs;
  RxList<Customer> filteredCustomers = <Customer>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'all'.obs;

  // Selected customer for details panel
  Rx<Customer?> selectedCustomer = Rx<Customer?>(null);
  RxList<CustomerTransaction> customerTransactions = <CustomerTransaction>[].obs;
  RxBool isLoadingTransactions = false.obs;

  // Statement summary
  RxDouble statementTotalInvoices = 0.0.obs;
  RxDouble statementTotalPayments = 0.0.obs;
  RxDouble statementTotalReturns = 0.0.obs;
  RxDouble statementBalance = 0.0.obs;

  // Statistics
  RxDouble totalDebts = 0.0.obs;
  RxDouble todayPayments = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDebts();
  }

  /// Load all customers with debts
  Future<void> loadDebts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final db = MyDatabase.myDatabase;

      // Get customers with debts (balance > 0)
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM customers 
        WHERE balance > 0 
        ORDER BY balance DESC
      ''');

      customersWithDebts.value = maps.map((map) => Customer.fromMap(map)).toList();
      filteredCustomers.value = customersWithDebts.toList();

      // Calculate totals
      totalDebts.value = customersWithDebts.fold<double>(
        0, (sum, c) => sum + c.balance,
      );

      // Get today's payments
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final paymentMaps = await db.rawQuery('''
        SELECT SUM(amount) as total FROM customer_transactions
        WHERE type = 'payment' 
        AND createdAt >= ? 
        AND createdAt < ?
      ''', [
        todayStart.toIso8601String(),
        todayEnd.toIso8601String(),
      ]);

      todayPayments.value = (paymentMaps.first['total'] as num?)?.toDouble() ?? 0;

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل الديون: $e';
      isLoading.value = false;
    }
  }

  /// Select a customer to view details
  Future<void> selectCustomer(Customer customer) async {
    selectedCustomer.value = customer;
    await loadCustomerTransactions(customer.id!);
    await loadCustomerStatement(customer.id!);
  }

  /// Clear selection
  void clearSelection() {
    selectedCustomer.value = null;
    customerTransactions.clear();
    statementTotalInvoices.value = 0;
    statementTotalPayments.value = 0;
    statementTotalReturns.value = 0;
    statementBalance.value = 0;
  }

  /// Load customer transactions
  Future<void> loadCustomerTransactions(int customerId) async {
    isLoadingTransactions.value = true;

    try {
      final db = MyDatabase.myDatabase;

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM customer_transactions
        WHERE customerId = ?
        ORDER BY createdAt DESC
        LIMIT 20
      ''', [customerId]);

      customerTransactions.value = maps.map((map) => CustomerTransaction.fromMap(map)).toList();
      isLoadingTransactions.value = false;
    } catch (e) {
      isLoadingTransactions.value = false;
    }
  }

  /// Load customer statement summary
  Future<void> loadCustomerStatement(int customerId) async {
    try {
      final db = MyDatabase.myDatabase;

      // Total invoices
      final invoiceResult = await db.rawQuery('''
        SELECT SUM(amount) as total FROM customer_transactions
        WHERE customerId = ? AND type = 'invoice'
      ''', [customerId]);
      statementTotalInvoices.value = (invoiceResult.first['total'] as num?)?.toDouble() ?? 0;

      // Total payments
      final paymentResult = await db.rawQuery('''
        SELECT SUM(amount) as total FROM customer_transactions
        WHERE customerId = ? AND type = 'payment'
      ''', [customerId]);
      statementTotalPayments.value = (paymentResult.first['total'] as num?)?.toDouble() ?? 0;

      // Total returns
      final returnResult = await db.rawQuery('''
        SELECT SUM(amount) as total FROM customer_transactions
        WHERE customerId = ? AND type = 'return'
      ''', [customerId]);
      statementTotalReturns.value = (returnResult.first['total'] as num?)?.toDouble() ?? 0;

      // Balance
      final customer = selectedCustomer.value;
      statementBalance.value = customer?.balance ?? 0;
    } catch (e) {
      // Handle error
    }
  }

  /// Record a payment from customer
  Future<Result<bool>> recordPayment(
    Customer customer,
    double amount,
    String paymentMethod,
    String description,
  ) async {
    try {
      final db = MyDatabase.myDatabase;

      // Update customer balance
      final newBalance = customer.balance - amount;
      await db.update(
        'customers',
        {
          'balance': newBalance,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [customer.id],
      );

      // Add payment transaction
      await db.insert('customer_transactions', {
        'customerId': customer.id,
        'type': 'payment',
        'amount': amount,
        'balanceAfter': newBalance,
        'description': description,
        'paymentMethod': paymentMethod,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update today's payments
      todayPayments.value += amount;

      // Refresh data
      await loadDebts();

      // Update selected customer
      if (selectedCustomer.value?.id == customer.id) {
        selectedCustomer.value = customer.copyWith(balance: newBalance);
        await loadCustomerTransactions(customer.id!);
        await loadCustomerStatement(customer.id!);
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure('فشل في تسجيل السداد: $e');
    }
  }

  /// Search customers
  void searchCustomers(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  /// Apply filters
  void applyFilters() {
    var result = customersWithDebts.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      result = result.where((c) {
        return c.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            c.phone.contains(searchQuery.value);
      }).toList();
    }

    // Apply filter
    switch (selectedFilter.value) {
      case 'overdue':
        // Customers with debts older than 30 days (simplified logic)
        result = result.where((c) {
          // In a real app, you'd check last transaction date
          return c.balance > 0;
        }).toList();
        break;
      case 'dueSoon':
        // Customers with debts within next 7 days (simplified logic)
        result = result.where((c) => c.balance > 0).toList();
        break;
      case 'large':
        // Large debts (over 5000)
        result = result.where((c) => c.balance > 5000).toList();
        break;
    }

    filteredCustomers.value = result;
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadDebts();
    if (selectedCustomer.value != null) {
      await selectCustomer(selectedCustomer.value!);
    }
  }
}
