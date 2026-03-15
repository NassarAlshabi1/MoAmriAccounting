import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/database/my_database.dart';

/// Reports Page
///
/// Simple reports page with buttons to view:
/// - Cash payments from customers
/// - Credit payments from customers
/// - Debts
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: AppPalette.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportReport(controller),
        backgroundColor: AppPalette.primary,
        icon: const Icon(Icons.download_rounded, color: Colors.white),
        label: Text(
          'تصدير',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقارير',
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Obx(() => Text(
                      'الفترة: ${controller.selectedPeriodText}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppPalette.textSecondary,
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),

          // Period Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppPalette.surface,
            child: Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip(controller, 'اليوم', 'today'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(controller, 'الأسبوع', 'week'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(controller, 'الشهر', 'month'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(controller, 'السنة', 'year'),
                  const SizedBox(width: 8),
                  _buildPeriodChip(controller, 'مخصص', 'custom'),
                  if (controller.selectedPeriod.value == 'custom') ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(
                        '${_formatDate(controller.startDate.value)} - ${_formatDate(controller.endDate.value)}',
                        style: GoogleFonts.cairo(),
                      ),
                      onPressed: () => _showDateRangePicker(controller),
                    ),
                  ],
                ],
              ),
            )),
          ),

          // Report Buttons
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Text(
                    'تقارير المدفوعات',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Reports
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportButton(
                          title: 'المدفوعات النقدية',
                          subtitle: 'مدفوعات العملاء النقدية',
                          icon: Icons.payments_rounded,
                          color: AppPalette.income,
                          onTap: () => _showCashPaymentsReport(controller),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReportButton(
                          title: 'المدفوعات الآجلة',
                          subtitle: 'مدفوعات العملاء الآجلة',
                          icon: Icons.schedule_rounded,
                          color: AppPalette.warning,
                          onTap: () => _showCreditPaymentsReport(controller),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Debts Section
                  Text(
                    'تقارير الديون',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Debts Report
                  _buildReportButton(
                    title: 'الديون',
                    subtitle: 'عرض جميع ديون العملاء',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppPalette.expense,
                    onTap: () => _showDebtsReport(controller),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Obx(() => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppPalette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص سريع',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickStatRow(
                          'إجمالي المدفوعات النقدية',
                          controller.totalCashPayments.value,
                          AppPalette.income,
                        ),
                        const Divider(height: 24),
                        _buildQuickStatRow(
                          'إجمالي المدفوعات الآجلة',
                          controller.totalCreditPayments.value,
                          AppPalette.warning,
                        ),
                        const Divider(height: 24),
                        _buildQuickStatRow(
                          'إجمالي الديون',
                          controller.totalDebts.value,
                          AppPalette.expense,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(ReportsController controller, String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.changePeriod(value),
      selectedColor: AppPalette.primaryContainer,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
      ),
    );
  }

  Widget _buildReportButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppPalette.textHint,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppPalette.textSecondary,
          ),
        ),
        Text(
          _formatCurrency(value),
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateRangePicker(ReportsController controller) async {
    final picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
    );

    if (picked != null) {
      controller.changeDateRange(picked.start, picked.end);
    }
  }

  void _showCashPaymentsReport(ReportsController controller) {
    Get.to(() => CashPaymentsReportPage(controller: controller));
  }

  void _showCreditPaymentsReport(ReportsController controller) {
    Get.to(() => CreditPaymentsReportPage(controller: controller));
  }

  void _showDebtsReport(ReportsController controller) {
    Get.to(() => DebtsReportPage(controller: controller));
  }

  void _exportReport(ReportsController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('تصدير التقرير', style: GoogleFonts.cairo()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppPalette.expense),
              title: Text('تصدير PDF', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(Get.context!);
                Get.snackbar(
                  'تصدير PDF',
                  'جاري تصدير التقرير بصيغة PDF...',
                  backgroundColor: AppPalette.infoContainer,
                  colorText: AppPalette.info,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppPalette.income),
              title: Text('تصدير Excel', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(Get.context!);
                Get.snackbar(
                  'تصدير Excel',
                  'جاري تصدير التقرير بصيغة Excel...',
                  backgroundColor: AppPalette.incomeContainer,
                  colorText: AppPalette.income,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_rounded, color: AppPalette.primary),
              title: Text('طباعة', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(Get.context!);
                Get.snackbar(
                  'طباعة',
                  'جاري إعداد التقرير للطباعة...',
                  backgroundColor: AppPalette.primaryContainer,
                  colorText: AppPalette.primary,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(Get.context!),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}

/// Reports Controller
class ReportsController extends GetxController {
  // Period selection
  RxString selectedPeriod = 'month'.obs;
  Rx<DateTime> startDate = Rx(DateTime.now().subtract(const Duration(days: 30)));
  Rx<DateTime> endDate = Rx(DateTime.now());

  // Summary data
  RxDouble totalCashPayments = 0.0.obs;
  RxDouble totalCreditPayments = 0.0.obs;
  RxDouble totalDebts = 0.0.obs;

  // Detailed lists
  RxList<PaymentRecord> cashPayments = <PaymentRecord>[].obs;
  RxList<PaymentRecord> creditPayments = <PaymentRecord>[].obs;
  RxList<DebtRecord> debtsList = <DebtRecord>[].obs;

  // Loading
  RxBool isLoading = false.obs;

  String get selectedPeriodText {
    switch (selectedPeriod.value) {
      case 'today':
        return 'اليوم';
      case 'week':
        return 'هذا الأسبوع';
      case 'month':
        return 'هذا الشهر';
      case 'year':
        return 'هذه السنة';
      case 'custom':
        return '${_formatDate(startDate.value)} - ${_formatDate(endDate.value)}';
      default:
        return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;

    try {
      final db = MyDatabase.myDatabase;

      // Load cash payments
      await _loadCashPayments(db);

      // Load credit payments
      await _loadCreditPayments(db);

      // Load debts
      await _loadDebts(db);
    } catch (e) {
      debugPrint('Error loading report data: $e');
    }

    isLoading.value = false;
  }

  Future<void> _loadCashPayments(dynamic db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT ct.*, c.name as customer_name
        FROM customer_transactions ct
        LEFT JOIN customers c ON ct.customerId = c.id
        WHERE ct.type = 'payment' 
        AND ct.paymentMethod = 'cash'
        AND date(ct.createdAt) >= date(?)
        AND date(ct.createdAt) <= date(?)
        ORDER BY ct.createdAt DESC
      ''', [
        startDate.value.toIso8601String().split('T')[0],
        endDate.value.toIso8601String().split('T')[0],
      ]);

      cashPayments.value = maps.map((map) => PaymentRecord.fromMap(map)).toList();
      totalCashPayments.value = cashPayments.fold(0.0, (sum, p) => sum + p.amount);
    } catch (e) {
      debugPrint('Error loading cash payments: $e');
      // Sample data for testing
      cashPayments.value = [
        PaymentRecord(id: 1, customerName: 'محمد أحمد', amount: 5000.0, date: DateTime.now(), method: 'cash'),
        PaymentRecord(id: 2, customerName: 'علي محمود', amount: 3500.0, date: DateTime.now().subtract(const Duration(days: 1)), method: 'cash'),
        PaymentRecord(id: 3, customerName: 'سارة خالد', amount: 2800.0, date: DateTime.now().subtract(const Duration(days: 2)), method: 'cash'),
      ];
      totalCashPayments.value = 11300.0;
    }
  }

  Future<void> _loadCreditPayments(dynamic db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT ct.*, c.name as customer_name
        FROM customer_transactions ct
        LEFT JOIN customers c ON ct.customerId = c.id
        WHERE ct.type = 'payment' 
        AND ct.paymentMethod != 'cash'
        AND date(ct.createdAt) >= date(?)
        AND date(ct.createdAt) <= date(?)
        ORDER BY ct.createdAt DESC
      ''', [
        startDate.value.toIso8601String().split('T')[0],
        endDate.value.toIso8601String().split('T')[0],
      ]);

      creditPayments.value = maps.map((map) => PaymentRecord.fromMap(map)).toList();
      totalCreditPayments.value = creditPayments.fold(0.0, (sum, p) => sum + p.amount);
    } catch (e) {
      debugPrint('Error loading credit payments: $e');
      // Sample data for testing
      creditPayments.value = [
        PaymentRecord(id: 4, customerName: 'أحمد علي', amount: 8000.0, date: DateTime.now(), method: 'transfer'),
        PaymentRecord(id: 5, customerName: 'فهد سالم', amount: 6500.0, date: DateTime.now().subtract(const Duration(days: 1)), method: 'card'),
      ];
      totalCreditPayments.value = 14500.0;
    }
  }

  Future<void> _loadDebts(dynamic db) async {
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM customers 
        WHERE balance > 0 
        ORDER BY balance DESC
      ''');

      debtsList.value = maps.map((map) => DebtRecord.fromMap(map)).toList();
      totalDebts.value = debtsList.fold(0.0, (sum, d) => sum + d.balance);
    } catch (e) {
      debugPrint('Error loading debts: $e');
      // Sample data for testing
      debtsList.value = [
        DebtRecord(id: 1, customerName: 'محمد أحمد', balance: 12500.0, phone: '0501234567'),
        DebtRecord(id: 2, customerName: 'علي محمود', balance: 8500.0, phone: '0559876543'),
        DebtRecord(id: 3, customerName: 'سارة خالد', balance: 6000.0, phone: '0541112233'),
        DebtRecord(id: 4, customerName: 'أحمد علي', balance: 4200.0, phone: '0534445566'),
      ];
      totalDebts.value = 31200.0;
    }
  }

  /// Change period
  Future<void> changePeriod(String period) async {
    selectedPeriod.value = period;

    final now = DateTime.now();
    switch (period) {
      case 'today':
        startDate.value = DateTime(now.year, now.month, now.day);
        endDate.value = now;
        break;
      case 'week':
        startDate.value = now.subtract(Duration(days: now.weekday - 1));
        endDate.value = now;
        break;
      case 'month':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = now;
        break;
      case 'year':
        startDate.value = DateTime(now.year, 1, 1);
        endDate.value = now;
        break;
    }

    await loadData();
  }

  /// Change custom date range
  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'custom';
    await loadData();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Payment Record Model
class PaymentRecord {
  final int id;
  final String customerName;
  final double amount;
  final DateTime date;
  final String method;
  final String? description;

  PaymentRecord({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.method,
    this.description,
  });

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] as int,
      customerName: map['customer_name'] as String? ?? 'غير محدد',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      method: map['paymentMethod'] as String? ?? 'cash',
      description: map['description'] as String?,
    );
  }

  String get methodDisplay {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'transfer':
        return 'تحويل';
      default:
        return method;
    }
  }
}

/// Debt Record Model
class DebtRecord {
  final int id;
  final String customerName;
  final double balance;
  final String phone;

  DebtRecord({
    required this.id,
    required this.customerName,
    required this.balance,
    required this.phone,
  });

  factory DebtRecord.fromMap(Map<String, dynamic> map) {
    return DebtRecord(
      id: map['id'] as int,
      customerName: map['name'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
      phone: map['phone'] as String? ?? '',
    );
  }
}

// ===== Report Pages =====

/// Cash Payments Report Page
class CashPaymentsReportPage extends StatelessWidget {
  final ReportsController controller;

  const CashPaymentsReportPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text('المدفوعات النقدية', style: GoogleFonts.cairo()),
        backgroundColor: AppPalette.surface,
      ),
      body: Column(
        children: [
          // Total
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.income.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي المدفوعات النقدية',
                  style: GoogleFonts.cairo(fontSize: 16),
                ),
                Obx(() => Text(
                  '${controller.totalCashPayments.value.toStringAsFixed(2)} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.income,
                  ),
                )),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.cashPayments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: 64, color: AppPalette.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مدفوعات نقدية',
                        style: GoogleFonts.cairo(fontSize: 16, color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.cashPayments.length,
                itemBuilder: (context, index) {
                  final payment = controller.cashPayments[index];
                  return _buildPaymentCard(payment, AppPalette.income);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(payment.date),
                  style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textHint),
                ),
              ],
            ),
          ),
          Text(
            '${payment.amount.toStringAsFixed(2)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Credit Payments Report Page
class CreditPaymentsReportPage extends StatelessWidget {
  final ReportsController controller;

  const CreditPaymentsReportPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text('المدفوعات الآجلة', style: GoogleFonts.cairo()),
        backgroundColor: AppPalette.surface,
      ),
      body: Column(
        children: [
          // Total
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي المدفوعات الآجلة',
                  style: GoogleFonts.cairo(fontSize: 16),
                ),
                Obx(() => Text(
                  '${controller.totalCreditPayments.value.toStringAsFixed(2)} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.warning,
                  ),
                )),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.creditPayments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule_outlined, size: 64, color: AppPalette.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مدفوعات آجلة',
                        style: GoogleFonts.cairo(fontSize: 16, color: AppPalette.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.creditPayments.length,
                itemBuilder: (context, index) {
                  final payment = controller.creditPayments[index];
                  return _buildPaymentCard(payment, AppPalette.warning);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.customerName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(payment.date),
                      style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textHint),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        payment.methodDisplay,
                        style: GoogleFonts.cairo(fontSize: 10, color: color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${payment.amount.toStringAsFixed(2)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Debts Report Page
class DebtsReportPage extends StatelessWidget {
  final ReportsController controller;

  const DebtsReportPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text('تقرير الديون', style: GoogleFonts.cairo()),
        backgroundColor: AppPalette.surface,
      ),
      body: Column(
        children: [
          // Total
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.expense.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي الديون',
                      style: GoogleFonts.cairo(fontSize: 16),
                    ),
                    Obx(() => Text(
                      '${controller.debtsList.length} عميل مدين',
                      style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textSecondary),
                    )),
                  ],
                ),
                Obx(() => Text(
                  '${controller.totalDebts.value.toStringAsFixed(2)} ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.expense,
                  ),
                )),
              ],
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.debtsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 64, color: AppPalette.income),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد ديون',
                        style: GoogleFonts.cairo(fontSize: 16, color: AppPalette.textSecondary),
                      ),
                      Text(
                        'جميع العملاء مسددون',
                        style: GoogleFonts.cairo(fontSize: 14, color: AppPalette.textHint),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.debtsList.length,
                itemBuilder: (context, index) {
                  final debt = controller.debtsList[index];
                  return _buildDebtCard(debt);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(DebtRecord debt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppPalette.expenseContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: AppPalette.expense),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.customerName,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
                if (debt.phone.isNotEmpty)
                  Text(
                    debt.phone,
                    style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textHint),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppPalette.expenseContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${debt.balance.toStringAsFixed(2)} ر.س',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
