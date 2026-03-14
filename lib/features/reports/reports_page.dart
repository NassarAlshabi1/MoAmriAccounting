import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/database/invoices_database.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/database/suppliers_database.dart';
import 'package:moamri_accounting/database/debts_database.dart';

/// Reports Controller
///
/// Manages reports state and data loading with reactive programming.
class ReportsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  
  // Period selection
  RxString selectedPeriod = 'month'.obs;
  Rx<DateTime> startDate = Rx(DateTime.now().subtract(const Duration(days: 30)));
  Rx<DateTime> endDate = Rx(DateTime.now());

  // Sales stats
  RxDouble totalSales = 0.0.obs;
  RxDouble totalPurchases = 0.0.obs;
  RxDouble totalReturns = 0.0.obs;
  RxDouble grossProfit = 0.0.obs;
  RxDouble netProfit = 0.0.obs;
  RxInt invoicesCount = 0.obs;
  RxInt returnsCount = 0.obs;

  // Cash movement
  RxDouble cashIn = 0.0.obs;
  RxDouble cashOut = 0.0.obs;
  RxDouble netCashFlow = 0.0.obs;
  RxList<CashMovement> cashMovements = <CashMovement>[].obs;

  // Debts
  RxDouble customerDebts = 0.0.obs;
  RxDouble supplierDebts = 0.0.obs;
  RxInt customersWithDebts = 0.obs;
  RxInt suppliersWithDebts = 0.obs;
  RxList<DebtItem> customerDebtsList = <DebtItem>[].obs;
  RxList<DebtItem> supplierDebtsList = <DebtItem>[].obs;

  // Chart data
  RxList<double> salesChartData = <double>[].obs;
  RxList<String> salesChartLabels = <String>[].obs;
  RxList<CategoryData> categoryData = <CategoryData>[].obs;

  // Loading
  RxBool isLoading = false.obs;
  RxBool isLoadingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(_onTabChanged);
    loadReportData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      // Reload data when tab changes if needed
    }
  }

  /// Load all report data
  Future<void> loadReportData() async {
    isLoading.value = true;

    try {
      await Future.wait([
        _loadSalesStats(),
        _loadCashMovement(),
        _loadDebtsData(),
        _loadChartData(),
      ]);
    } catch (e) {
      debugPrint('Error loading report data: $e');
    }

    isLoading.value = false;
  }

  /// Load sales statistics
  Future<void> _loadSalesStats() async {
    try {
      // Sample data - in production, load from database
      totalSales.value = 285000.0;
      totalPurchases.value = 195000.0;
      totalReturns.value = 12500.0;
      grossProfit.value = totalSales.value - totalPurchases.value;
      netProfit.value = grossProfit.value - 25000.0; // minus expenses
      invoicesCount.value = 47;
      returnsCount.value = 5;
    } catch (e) {
      debugPrint('Error loading sales stats: $e');
    }
  }

  /// Load cash movement data
  Future<void> _loadCashMovement() async {
    try {
      // Sample cash movements
      cashMovements.value = [
        CashMovement(
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'مبيعات نقدية',
          amountIn: 45000.0,
          amountOut: 0.0,
          type: 'sale',
        ),
        CashMovement(
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'شراء بضاعة',
          amountIn: 0.0,
          amountOut: 25000.0,
          type: 'purchase',
        ),
        CashMovement(
          date: DateTime.now().subtract(const Duration(days: 2)),
          description: 'سداد من عميل',
          amountIn: 8500.0,
          amountOut: 0.0,
          type: 'payment',
        ),
        CashMovement(
          date: DateTime.now().subtract(const Duration(days: 2)),
          description: 'رواتب الموظفين',
          amountIn: 0.0,
          amountOut: 15000.0,
          type: 'expense',
        ),
        CashMovement(
          date: DateTime.now().subtract(const Duration(days: 3)),
          description: 'مبيعات آجلة',
          amountIn: 0.0,
          amountOut: 0.0,
          type: 'credit_sale',
          creditAmount: 12000.0,
        ),
      ];

      // Calculate totals
      cashIn.value = cashMovements.fold(0.0, (sum, m) => sum + m.amountIn);
      cashOut.value = cashMovements.fold(0.0, (sum, m) => sum + m.amountOut);
      netCashFlow.value = cashIn.value - cashOut.value;
    } catch (e) {
      debugPrint('Error loading cash movement: $e');
    }
  }

  /// Load debts data
  Future<void> _loadDebtsData() async {
    try {
      // Customer debts
      customerDebts.value = 45000.0;
      customersWithDebts.value = 12;
      customerDebtsList.value = [
        DebtItem(name: 'محمد أحمد', amount: 8500.0, date: DateTime.now().subtract(const Duration(days: 15))),
        DebtItem(name: 'علي محمود', amount: 5200.0, date: DateTime.now().subtract(const Duration(days: 10))),
        DebtItem(name: 'سارة خالد', amount: 12000.0, date: DateTime.now().subtract(const Duration(days: 5))),
        DebtItem(name: 'أحمد علي', amount: 3500.0, date: DateTime.now().subtract(const Duration(days: 20))),
      ];

      // Supplier debts
      supplierDebts.value = 28000.0;
      suppliersWithDebts.value = 5;
      supplierDebtsList.value = [
        DebtItem(name: 'شركة الأمل', amount: 15000.0, date: DateTime.now().subtract(const Duration(days: 8))),
        DebtItem(name: 'مؤسسة النور', amount: 8000.0, date: DateTime.now().subtract(const Duration(days: 12))),
        DebtItem(name: 'مصنع السلام', amount: 5000.0, date: DateTime.now().subtract(const Duration(days: 3))),
      ];
    } catch (e) {
      debugPrint('Error loading debts data: $e');
    }
  }

  /// Load chart data
  Future<void> _loadChartData() async {
    salesChartData.value = [45000, 52000, 38000, 61000, 55000, 48000, 52000];
    salesChartLabels.value = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

    categoryData.value = [
      CategoryData('أجهزة كهربائية', 125000, AppPalette.primary),
      CategoryData('ملابس', 85000, AppPalette.info),
      CategoryData('مواد غذائية', 45000, AppPalette.income),
      CategoryData('أدوات مكتبية', 30000, AppPalette.warning),
    ];
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
        startDate.value = now.subtract(Duration(days: now.weekday));
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
    
    await loadReportData();
  }

  /// Change custom date range
  Future<void> changeDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    selectedPeriod.value = 'custom';
    await loadReportData();
  }
}

/// Cash Movement Model
class CashMovement {
  final DateTime date;
  final String description;
  final double amountIn;
  final double amountOut;
  final String type;
  final double? creditAmount;

  CashMovement({
    required this.date,
    required this.description,
    required this.amountIn,
    required this.amountOut,
    required this.type,
    this.creditAmount,
  });

  IconData get icon {
    switch (type) {
      case 'sale':
        return Icons.point_of_sale_rounded;
      case 'purchase':
        return Icons.shopping_cart_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'expense':
        return Icons.money_off_rounded;
      case 'credit_sale':
        return Icons.receipt_long_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color get color {
    if (amountIn > 0) return AppPalette.income;
    if (amountOut > 0) return AppPalette.expense;
    return AppPalette.warning;
  }
}

/// Debt Item Model
class DebtItem {
  final String name;
  final double amount;
  final DateTime date;

  DebtItem({
    required this.name,
    required this.amount,
    required this.date,
  });
}

/// Category Data Model
class CategoryData {
  final String label;
  final double value;
  final Color color;

  CategoryData(this.label, this.value, this.color);
}

/// Reports Page
///
/// Comprehensive reports page with sales, cash movement, and debts tabs.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Column(
        children: [
          _buildHeader(controller),
          _buildPeriodSelector(controller),
          _buildTabBar(controller),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: controller.tabController,
                    children: [
                      _buildSalesTab(controller),
                      _buildCashMovementTab(controller),
                      _buildCustomerDebtsTab(controller),
                      _buildSupplierDebtsTab(controller),
                    ],
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ReportsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'التقارير والاستعلامات',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPalette.textPrimary,
            ),
          ),
          Row(
            children: [
              AppSecondaryButton(
                text: 'تصدير PDF',
                icon: Icons.picture_as_pdf_rounded,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              AppSecondaryButton(
                text: 'طباعة',
                icon: Icons.print_rounded,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ReportsController controller) {
    return Container(
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
    );
  }

  Widget _buildPeriodChip(ReportsController controller, String label, String value) {
    return Obx(() {
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
    });
  }

  Widget _buildTabBar(ReportsController controller) {
    return Container(
      color: AppPalette.surface,
      child: TabBar(
        controller: controller.tabController,
        labelColor: AppPalette.primary,
        unselectedLabelColor: AppPalette.textSecondary,
        indicatorColor: AppPalette.primary,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'المبيعات والأرباح'),
          Tab(text: 'حركة الصندوق'),
          Tab(text: 'ديون العملاء'),
          Tab(text: 'ديون الموردين'),
        ],
      ),
    );
  }

  // ===== Sales Tab =====
  Widget _buildSalesTab(ReportsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المبيعات',
                  controller.totalSales.value,
                  AppPalette.income,
                  Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'تكلفة المشتريات',
                  controller.totalPurchases.value,
                  AppPalette.expense,
                  Icons.trending_down_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'المرتجعات',
                  controller.totalReturns.value,
                  AppPalette.warning,
                  Icons.keyboard_return_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'صافي الربح',
                  controller.netProfit.value,
                  controller.netProfit.value >= 0 ? AppPalette.primary : AppPalette.expense,
                  Icons.account_balance_wallet_rounded,
                ),
              ),
            ],
          )),
          const SizedBox(height: 24),

          // Sales Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المبيعات اليومية',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppPalette.incomeContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+12.5%',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.income,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  height: 200,
                  child: _buildSimpleBarChart(
                    controller.salesChartData,
                    controller.salesChartLabels,
                    AppPalette.income,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Sales
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبيعات حسب التصنيف',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => Column(
                  children: controller.categoryData.map((entry) {
                    final total = controller.categoryData.fold<double>(0, (sum, e) => sum + e.value);
                    final percentage = total > 0 ? (entry.value / total * 100) : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: entry.color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(entry.label, style: GoogleFonts.cairo(fontSize: 13)),
                                ],
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: entry.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: entry.color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation(entry.color),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Cash Movement Tab =====
  Widget _buildCashMovementTab(ReportsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الوارد',
                  controller.cashIn.value,
                  AppPalette.income,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'الصادر',
                  controller.cashOut.value,
                  AppPalette.expense,
                  Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'صافي التدفق',
                  controller.netCashFlow.value,
                  controller.netCashFlow.value >= 0 ? AppPalette.primary : AppPalette.expense,
                  Icons.account_balance_rounded,
                ),
              ),
            ],
          )),
          const SizedBox(height: 24),

          // Transactions List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'حركات الصندوق',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('عرض الكل', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => Column(
                  children: controller.cashMovements.map((movement) {
                    return _buildCashMovementItem(movement);
                  }).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashMovementItem(CashMovement movement) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppPalette.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: movement.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(movement.icon, color: movement.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(movement.date),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppPalette.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (movement.amountIn > 0)
                Text(
                  '+ ${movement.amountIn.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.income,
                  ),
                ),
              if (movement.amountOut > 0)
                Text(
                  '- ${movement.amountOut.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.expense,
                  ),
                ),
              if (movement.creditAmount != null)
                Text(
                  'آجل: ${movement.creditAmount!.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppPalette.warning,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Customer Debts Tab =====
  Widget _buildCustomerDebtsTab(ReportsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الديون',
                  controller.customerDebts.value,
                  AppPalette.expense,
                  Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'عملاء بديون',
                  controller.customersWithDebts.value.toDouble(),
                  AppPalette.warning,
                  Icons.people_rounded,
                  isCount: true,
                ),
              ),
            ],
          )),
          const SizedBox(height: 24),

          // Debts List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ديون العملاء',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSecondaryButton(
                      text: 'تقرير مفصل',
                      icon: Icons.description_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => Column(
                  children: controller.customerDebtsList.map((debt) {
                    return _buildDebtItem(debt, true);
                  }).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Supplier Debts Tab =====
  Widget _buildSupplierDebtsTab(ReportsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الديون',
                  controller.supplierDebts.value,
                  AppPalette.warning,
                  Icons.local_shipping_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'موردين بديون',
                  controller.suppliersWithDebts.value.toDouble(),
                  AppPalette.info,
                  Icons.local_shipping_rounded,
                  isCount: true,
                ),
              ),
            ],
          )),
          const SizedBox(height: 24),

          // Debts List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ديون الموردين',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSecondaryButton(
                      text: 'تقرير مفصل',
                      icon: Icons.description_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => Column(
                  children: controller.supplierDebtsList.map((debt) {
                    return _buildDebtItem(debt, false);
                  }).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtItem(DebtItem debt, bool isCustomer) {
    final daysSince = DateTime.now().difference(debt.date).inDays;
    final isOverdue = daysSince > 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue ? AppPalette.expense.withOpacity(0.5) : AppPalette.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCustomer
                  ? AppPalette.primaryContainer
                  : AppPalette.warningContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCustomer ? Icons.person_rounded : Icons.local_shipping_rounded,
              color: isCustomer ? AppPalette.primary : AppPalette.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.name,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'منذ $daysSince يوم',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isOverdue ? AppPalette.expense : AppPalette.textHint,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppPalette.expenseContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'متأخر',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: AppPalette.expense,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${debt.amount.toStringAsFixed(2)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppPalette.expense,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helper Widgets =====
  Widget _buildStatCard(
    String title,
    double value,
    Color color,
    IconData icon, {
    bool isCount = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            isCount ? value.toInt().toString() : _formatCurrency(value),
            style: GoogleFonts.cairo(
              fontSize: isCount ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (!isCount) const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(List<double> data, List<String> labels, Color color) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height = maxValue > 0 ? (data[index] / maxValue) * 150 : 0.0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[index],
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppPalette.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M ر.س';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K ر.س';
    }
    return '${value.toStringAsFixed(0)} ر.س';
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
}
