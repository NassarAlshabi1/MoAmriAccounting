import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/customer_transaction.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/database/customer_transactions_database.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Customers Controller
///
/// Manages customers state, account statements, and payment tracking.
class CustomersController extends GetxController {
  // State
  RxList<Customer> customers = <Customer>[].obs;
  RxList<Customer> filteredCustomers = <Customer>[].obs;
  Rx<Customer?> selectedCustomer = Rx(null);
  RxList<CustomerTransaction> customerTransactions = <CustomerTransaction>[].obs;
  
  // Loading states
  RxBool isLoading = false.obs;
  RxBool isLoadingTransactions = false.obs;
  RxBool isSaving = false.obs;
  
  // Error handling
  RxString errorMessage = ''.obs;
  
  // Search and filter
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'all'.obs; // all, withDebt, noDebt
  
  // Pagination
  RxInt currentPage = 0.obs;
  RxInt totalCustomers = 0.obs;
  RxBool hasMore = true.obs;
  
  // Statistics
  RxDouble totalDebts = 0.0.obs;
  RxInt customersWithDebtsCount = 0.obs;
  RxDouble todayPayments = 0.0.obs;
  RxDouble todaySales = 0.0.obs;

  // Account statement
  Rx<DateTime> statementStartDate = Rx(DateTime.now().subtract(const Duration(days: 30)));
  Rx<DateTime> statementEndDate = Rx(DateTime.now());
  RxDouble statementTotalInvoices = 0.0.obs;
  RxDouble statementTotalPayments = 0.0.obs;
  RxDouble statementTotalReturns = 0.0.obs;
  RxDouble statementBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Load initial data
  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load customers count
      totalCustomers.value = await CustomersDatabase.getCustomersCount();

      // Load customers with debts from existing database
      final mainController = Get.find<dynamic>();
      final customersWithDebts = await CustomersDatabase.getCustomersWithDebts(
        mainController,
        0,
      );
      
      customers.value = customersWithDebts.map((item) => item.customer).toList();
      filteredCustomers.value = customers.toList();

      // Calculate statistics
      await _calculateStatistics();

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل البيانات: $e';
      isLoading.value = false;
    }
  }

  /// Calculate statistics
  Future<void> _calculateStatistics() async {
    try {
      totalDebts.value = await CustomerTransactionsDatabase.getTotalCustomerDebts();
      customersWithDebtsCount.value = customers.where((c) => c.hasDebt).length;

      // Get today's summary
      final dailySummary = await CustomerTransactionsDatabase.getDailySummary(DateTime.now());
      todaySales.value = dailySummary['totalSales'] ?? 0.0;
      todayPayments.value = dailySummary['totalPayments'] ?? 0.0;
    } catch (e) {
      debugPrint('Error calculating statistics: $e');
    }
  }

  /// Search customers
  Future<void> searchCustomers(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      applyFilter();
      return;
    }

    isLoading.value = true;
    try {
      final mainController = Get.find<dynamic>();
      final results = await CustomersDatabase.getSearchedCustomers(
        mainController,
        0,
        query,
      );
      customers.value = results.map((item) => item.customer).toList();
      filteredCustomers.value = customers.toList();
      hasMore.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في البحث: $e';
    }
    isLoading.value = false;
  }

  /// Apply current filter
  void applyFilter() {
    switch (selectedFilter.value) {
      case 'withDebt':
        filteredCustomers.value = customers.where((c) => c.hasDebt).toList();
        break;
      case 'noDebt':
        filteredCustomers.value = customers.where((c) => !c.hasDebt).toList();
        break;
      default:
        filteredCustomers.value = customers.toList();
    }

    // Apply search if active
    if (searchQuery.value.isNotEmpty) {
      filteredCustomers.value = filteredCustomers
          .where((c) =>
              c.name.contains(searchQuery.value) ||
              c.phone.contains(searchQuery.value))
          .toList();
    }
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  /// Select customer and load transactions
  Future<void> selectCustomer(Customer customer) async {
    selectedCustomer.value = customer;
    await loadCustomerTransactions(customer.id!);
    await loadCustomerAccountStatement(customer.id!);
  }

  /// Load customer transactions
  Future<void> loadCustomerTransactions(int customerId) async {
    isLoadingTransactions.value = true;
    try {
      final transactions = await CustomerTransactionsDatabase.getCustomerTransactions(
        customerId,
        limit: 100,
      );
      customerTransactions.value = transactions;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل الحركات: $e';
    }
    isLoadingTransactions.value = false;
  }

  /// Load customer account statement
  Future<void> loadCustomerAccountStatement(int customerId) async {
    try {
      final statement = await CustomerTransactionsDatabase.getCustomerAccountStatement(
        customerId,
        startDate: statementStartDate.value,
        endDate: statementEndDate.value,
      );

      statementTotalInvoices.value = statement['totalInvoices'] ?? 0.0;
      statementTotalPayments.value = statement['totalPayments'] ?? 0.0;
      statementTotalReturns.value = statement['totalReturns'] ?? 0.0;
      statementBalance.value = statement['currentBalance'] ?? 0.0;
    } catch (e) {
      debugPrint('Error loading account statement: $e');
    }
  }

  /// Record payment from customer
  Future<Result<int>> recordPayment({
    required int customerId,
    required double amount,
    String paymentMethod = 'cash',
    String description = '',
  }) async {
    isSaving.value = true;
    try {
      final transaction = CustomerTransaction(
        customerId: customerId,
        type: 'payment',
        amount: amount,
        paymentMethod: paymentMethod,
        description: description,
      );

      final id = await CustomerTransactionsDatabase.addTransaction(transaction);

      // Update selected customer
      if (selectedCustomer.value?.id == customerId) {
        await loadCustomerTransactions(customerId);
        await loadCustomerAccountStatement(customerId);
        // Reload customer to get updated balance
        final updatedCustomer = await CustomersDatabase.getCustomerByID(customerId);
        if (updatedCustomer != null) {
          selectedCustomer.value = updatedCustomer;
        }
      }

      await _calculateStatistics();
      isSaving.value = false;
      return Result.success(id);
    } catch (e) {
      isSaving.value = false;
      return Result.failure('فشل في تسجيل السداد: $e');
    }
  }

  /// Record opening balance for customer
  Future<Result<int>> recordOpeningBalance({
    required int customerId,
    required double amount,
    String description = 'رصيد افتتاحي',
  }) async {
    isSaving.value = true;
    try {
      final transaction = CustomerTransaction(
        customerId: customerId,
        type: 'opening_balance',
        amount: amount,
        description: description,
      );

      final id = await CustomerTransactionsDatabase.addTransaction(transaction);

      // Update selected customer
      if (selectedCustomer.value?.id == customerId) {
        await loadCustomerTransactions(customerId);
        await loadCustomerAccountStatement(customerId);
        final updatedCustomer = await CustomersDatabase.getCustomerByID(customerId);
        if (updatedCustomer != null) {
          selectedCustomer.value = updatedCustomer;
        }
      }

      await _calculateStatistics();
      isSaving.value = false;
      return Result.success(id);
    } catch (e) {
      isSaving.value = false;
      return Result.failure('فشل في تسجيل الرصيد الافتتاحي: $e');
    }
  }

  /// Set statement date range
  Future<void> setStatementDateRange(DateTime start, DateTime end) async {
    statementStartDate.value = start;
    statementEndDate.value = end;
    
    if (selectedCustomer.value != null) {
      await loadCustomerAccountStatement(selectedCustomer.value!.id!);
      await loadCustomerTransactions(selectedCustomer.value!.id!);
    }
  }

  /// Get customer by ID
  Future<Customer?> getCustomerById(int id) async {
    return await CustomersDatabase.getCustomerByID(id);
  }

  /// Clear selection
  void clearSelection() {
    selectedCustomer.value = null;
    customerTransactions.clear();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadInitialData();
    if (selectedCustomer.value != null) {
      await selectCustomer(selectedCustomer.value!);
    }
  }

  /// Get customers suggestions for search
  Future<List<Customer>> getCustomerSuggestions(String query) async {
    if (query.isEmpty) return [];
    return await CustomersDatabase.getCustomersSuggestions(query);
  }

  /// Get customer balance
  Future<double> getCustomerBalance(int customerId) async {
    return await CustomerTransactionsDatabase.getCustomerBalance(customerId);
  }

  /// Get customers with debts list
  Future<List<Map<String, dynamic>>> getCustomersWithDebtsList() async {
    return await CustomerTransactionsDatabase.getCustomersWithDebts();
  }
}
