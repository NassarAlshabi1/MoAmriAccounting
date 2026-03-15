import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/database/entities/debt.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/database/entities/user.dart';

/// Debt Status
enum DebtStatus {
  pending,
  overdue,
  paid,
}

/// Debt Model for UI
class DebtModel {
  final int id;
  final String? customerName;
  final String? supplierName;
  final double amount;
  final double paidAmount;
  final String currency;
  final DateTime dueDate;
  final DateTime createdDate;
  final DebtStatus status;
  final String note;
  final int? customerId;
  final int? invoiceId;

  DebtModel({
    required this.id,
    this.customerName,
    this.supplierName,
    required this.amount,
    required this.paidAmount,
    required this.currency,
    required this.dueDate,
    required this.createdDate,
    required this.status,
    required this.note,
    this.customerId,
    this.invoiceId,
  });

  double get remainingAmount => amount - paidAmount;
  bool get isPaid => paidAmount >= amount;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && !isPaid;
}

/// Debts Controller
///
/// Manages debts state and database operations
class DebtsController extends GetxController with GetTickerProviderStateMixin {
  // State
  RxList<DebtModel> receivableDebts = <DebtModel>[].obs;
  RxList<DebtModel> payableDebts = <DebtModel>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString searchQuery = ''.obs;
  RxString selectedFilter = 'all'.obs; // all, overdue, dueSoon, paid

  // Tab controller
  late TabController tabController;

  // Current tab (0 = receivable, 1 = payable)
  RxInt currentTab = 0.obs;

  // User reference
  User? currentUser;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });

    // Get current user from main controller
    try {
      final mainController = Get.find<dynamic>();
      currentUser = mainController.currentUser?.value;
    } catch (_) {}
  }

  /// Load all debts
  Future<void> loadDebts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load receivable debts (customer debts)
      final receivable = await _loadReceivableDebts();
      receivableDebts.value = receivable;

      // Load payable debts (supplier debts) - for future implementation
      // For now, empty list
      payableDebts.value = [];

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'فشل في تحميل الديون: $e';
      isLoading.value = false;
    }
  }

  /// Load receivable debts from database
  Future<List<DebtModel>> _loadReceivableDebts() async {
    try {
      final db = MyDatabase.myDatabase;

      // Query debts with customer info
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT d.*, c.name as customer_name
        FROM debts d
        LEFT JOIN customers c ON d.customer_id = c.id
        ORDER BY d.date DESC
      ''');

      return maps.map((map) {
        final amount = (map['amount'] as num?)?.toDouble() ?? 0;
        final paidAmount = (map['paid_amount'] as num?)?.toDouble() ?? 0;
        final dueDate = map['due_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
            : DateTime.now().add(const Duration(days: 30));
        final createdDate = map['date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int)
            : DateTime.now();

        DebtStatus status;
        if (paidAmount >= amount) {
          status = DebtStatus.paid;
        } else if (dueDate.isBefore(DateTime.now())) {
          status = DebtStatus.overdue;
        } else {
          status = DebtStatus.pending;
        }

        return DebtModel(
          id: map['id'] as int,
          customerName: map['customer_name'] as String?,
          amount: amount,
          paidAmount: paidAmount,
          currency: map['currency'] as String? ?? 'ريال',
          dueDate: dueDate,
          createdDate: createdDate,
          status: status,
          note: map['note'] as String? ?? '',
          customerId: map['customer_id'] as int?,
          invoiceId: map['invoice_id'] as int?,
        );
      }).toList();
    } catch (e) {
      print('Error loading debts: $e');
      return [];
    }
  }

  /// Record payment
  Future<bool> recordPayment(DebtModel debt, double amount, String paymentMethod) async {
    try {
      final db = MyDatabase.myDatabase;

      final newPaidAmount = debt.paidAmount + amount;

      await db.update(
        'debts',
        {
          'paid_amount': newPaidAmount,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [debt.id],
      );

      // Refresh debts
      await loadDebts();

      return true;
    } catch (e) {
      errorMessage.value = 'فشل في تسجيل الدفع: $e';
      return false;
    }
  }

  /// Add new debt
  Future<bool> addDebt(DebtModel debt) async {
    try {
      final db = MyDatabase.myDatabase;

      final id = await db.insert('debts', {
        'customer_id': debt.customerId,
        'amount': debt.amount,
        'paid_amount': debt.paidAmount,
        'currency': debt.currency,
        'date': debt.createdDate.millisecondsSinceEpoch,
        'due_date': debt.dueDate.millisecondsSinceEpoch,
        'note': debt.note,
        'invoice_id': debt.invoiceId,
      });

      await loadDebts();
      return true;
    } catch (e) {
      errorMessage.value = 'فشل في إضافة الدين: $e';
      return false;
    }
  }

  /// Get filtered debts
  List<DebtModel> getFilteredDebts(bool isReceivable) {
    List<DebtModel> debts = isReceivable ? receivableDebts.toList() : payableDebts.toList();

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      debts = debts.where((d) {
        final name = d.customerName ?? d.supplierName ?? '';
        return name.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    // Apply filter
    switch (selectedFilter.value) {
      case 'overdue':
        debts = debts.where((d) => d.status == DebtStatus.overdue).toList();
        break;
      case 'dueSoon':
        debts = debts.where((d) {
          if (d.status == DebtStatus.paid) return false;
          final daysUntilDue = d.dueDate.difference(DateTime.now()).inDays;
          return daysUntilDue > 0 && daysUntilDue <= 7;
        }).toList();
        break;
      case 'paid':
        debts = debts.where((d) => d.status == DebtStatus.paid).toList();
        break;
    }

    return debts;
  }

  /// Calculate total receivable
  double getTotalReceivable() {
    return receivableDebts
        .where((d) => d.status != DebtStatus.paid)
        .fold<double>(0, (sum, d) => sum + d.remainingAmount);
  }

  /// Calculate total payable
  double getTotalPayable() {
    return payableDebts
        .where((d) => d.status != DebtStatus.paid)
        .fold<double>(0, (sum, d) => sum + d.remainingAmount);
  }

  /// Count overdue debts
  int getOverdueCount() {
    return receivableDebts.where((d) => d.status == DebtStatus.overdue).length +
        payableDebts.where((d) => d.status == DebtStatus.overdue).length;
  }

  /// Search debts
  void search(String query) {
    searchQuery.value = query;
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadDebts();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
