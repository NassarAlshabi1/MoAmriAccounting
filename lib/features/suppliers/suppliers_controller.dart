import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/supplier.dart';
import 'package:moamri_accounting/database/suppliers_database.dart';
import 'package:moamri_accounting/utils/result.dart';

/// Suppliers Controller
///
/// Manages suppliers state and database operations with reactive programming.
class SuppliersController extends GetxController {
  // State
  RxList<Supplier> suppliers = <Supplier>[].obs;
  RxList<Supplier> filteredSuppliers = <Supplier>[].obs;
  Rx<Supplier?> selectedSupplier = Rx(null);
  RxList<SupplierTransaction> supplierTransactions = <SupplierTransaction>[].obs;
  
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
  RxInt totalSuppliers = 0.obs;
  RxBool hasMore = true.obs;
  static const int pageSize = 20;
  
  // Statistics
  RxDouble totalDebts = 0.0.obs;
  RxInt suppliersWithDebtsCount = 0.obs;

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
      // Load suppliers count
      totalSuppliers.value = await SuppliersDatabase.getSuppliersCount();
      
      // Load suppliers
      final allSuppliers = await SuppliersDatabase.getAllSuppliers();
      suppliers.value = allSuppliers;
      filteredSuppliers.value = allSuppliers;
      
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
    totalDebts.value = await SuppliersDatabase.getTotalDebtsToSuppliers();
    suppliersWithDebtsCount.value = suppliers.where((s) => s.hasDebt).length;
  }

  /// Search suppliers
  Future<void> searchSuppliers(String query) async {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      applyFilter();
      return;
    }
    
    isLoading.value = true;
    try {
      final results = await SuppliersDatabase.searchSuppliers(query);
      filteredSuppliers.value = results;
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
        filteredSuppliers.value = suppliers.where((s) => s.hasDebt).toList();
        break;
      case 'noDebt':
        filteredSuppliers.value = suppliers.where((s) => !s.hasDebt).toList();
        break;
      default:
        filteredSuppliers.value = suppliers.toList();
    }
    
    // Apply search if active
    if (searchQuery.value.isNotEmpty) {
      filteredSuppliers.value = filteredSuppliers
          .where((s) => 
              s.name.contains(searchQuery.value) || 
              s.phone.contains(searchQuery.value))
          .toList();
    }
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  /// Add new supplier
  Future<Result<int>> addSupplier(Supplier supplier) async {
    isSaving.value = true;
    try {
      final id = await SuppliersDatabase.insertSupplier(supplier);
      await loadInitialData();
      isSaving.value = false;
      return Result.success(id);
    } catch (e) {
      isSaving.value = false;
      return Result.failure('فشل في إضافة المورد: $e');
    }
  }

  /// Update supplier
  Future<Result<void>> updateSupplier(Supplier supplier) async {
    isSaving.value = true;
    try {
      await SuppliersDatabase.updateSupplier(supplier);
      await loadInitialData();
      isSaving.value = false;
      return Result.success(null);
    } catch (e) {
      isSaving.value = false;
      return Result.failure('فشل في تحديث المورد: $e');
    }
  }

  /// Delete supplier
  Future<Result<void>> deleteSupplier(int id) async {
    try {
      await SuppliersDatabase.deleteSupplier(id);
      suppliers.removeWhere((s) => s.id == id);
      applyFilter();
      await _calculateStatistics();
      return Result.success(null);
    } catch (e) {
      return Result.failure('فشل في حذف المورد: $e');
    }
  }

  /// Select supplier and load transactions
  Future<void> selectSupplier(Supplier supplier) async {
    selectedSupplier.value = supplier;
    await loadSupplierTransactions(supplier.id!);
  }

  /// Load supplier transactions
  Future<void> loadSupplierTransactions(int supplierId) async {
    isLoadingTransactions.value = true;
    try {
      final transactions = await SuppliersDatabase.getSupplierTransactions(
        supplierId,
        limit: 100,
      );
      supplierTransactions.value = transactions;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل الحركات: $e';
    }
    isLoadingTransactions.value = false;
  }

  /// Add transaction
  Future<Result<int>> addTransaction(SupplierTransaction transaction) async {
    try {
      final id = await SuppliersDatabase.addTransaction(transaction);
      // Reload supplier data
      if (selectedSupplier.value?.id != null) {
        final updatedSupplier = await SuppliersDatabase.getSupplierById(
          selectedSupplier.value!.id!,
        );
        if (updatedSupplier != null) {
          selectedSupplier.value = updatedSupplier;
        }
        await loadSupplierTransactions(selectedSupplier.value!.id!);
      }
      await loadInitialData();
      return Result.success(id);
    } catch (e) {
      return Result.failure('فشل في إضافة الحركة: $e');
    }
  }

  /// Get supplier account statement
  Future<List<Map<String, dynamic>>> getAccountStatement(
    int supplierId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await SuppliersDatabase.getSupplierAccountStatement(
      supplierId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear selection
  void clearSelection() {
    selectedSupplier.value = null;
    supplierTransactions.clear();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadInitialData();
  }

  /// Get supplier by ID
  Future<Supplier?> getSupplierById(int id) async {
    return await SuppliersDatabase.getSupplierById(id);
  }
}
