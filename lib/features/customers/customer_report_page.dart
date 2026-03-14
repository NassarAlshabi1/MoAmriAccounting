import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/customer_transaction.dart';
import 'package:moamri_accounting/database/customer_transactions_database.dart';

/// Customer Report Page
///
/// Detailed account statement for a specific customer with date filtering and export.
class CustomerReportPage extends StatefulWidget {
  final Customer customer;

  const CustomerReportPage({super.key, required this.customer});

  @override
  State<CustomerReportPage> createState() => _CustomerReportPageState();
}

class _CustomerReportPageState extends State<CustomerReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<CustomerTransaction> transactions = [];
  Map<String, dynamic> statementSummary = {};
  bool isLoading = true;
  String selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load transactions
      transactions = await CustomerTransactionsDatabase.getCustomerTransactions(
        widget.customer.id!,
        limit: 500,
        startDate: startDate,
        endDate: endDate,
      );

      // Load statement summary
      statementSummary = await CustomerTransactionsDatabase.getCustomerAccountStatement(
        widget.customer.id!,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedPeriod = 'custom';
      });
      await _loadData();
    }
  }

  void _setPeriod(String period) {
    setState(() => selectedPeriod = period);

    final now = DateTime.now();
    switch (period) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = now;
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(
          'كشف حساب: ${widget.customer.name}',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppPalette.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'تصدير PDF',
            onPressed: () {
              Get.snackbar(
                'تصدير',
                'سيتم تصدير التقرير إلى PDF',
                backgroundColor: AppPalette.infoContainer,
                colorText: AppPalette.info,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'طباعة',
            onPressed: () {
              Get.snackbar(
                'طباعة',
                'سيتم طباعة التقرير',
                backgroundColor: AppPalette.infoContainer,
                colorText: AppPalette.info,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPalette.primary,
          unselectedLabelColor: AppPalette.textSecondary,
          indicatorColor: AppPalette.primary,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'كشف الحساب'),
            Tab(text: 'ملخص الحركات'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAccountStatementTab(),
                _buildTransactionsListTab(),
              ],
            ),
    );
  }

  Widget _buildAccountStatementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info Card
          _buildCustomerInfoCard(),
          const SizedBox(height: 16),

          // Period Selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // Summary Cards
          _buildSummaryCards(),
          const SizedBox(height: 16),

          // Account Statement Table
          _buildStatementTable(),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.customer.hasDebt
                  ? AppPalette.expenseContainer
                  : AppPalette.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.person_rounded,
              color: widget.customer.hasDebt ? AppPalette.expense : AppPalette.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (widget.customer.phone.isNotEmpty) ...[
                      Icon(Icons.phone_rounded, size: 16, color: AppPalette.textHint),
                      const SizedBox(width: 4),
                      Text(
                        widget.customer.phone,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(
                      widget.customer.hasDebt ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                      size: 16,
                      color: widget.customer.hasDebt ? AppPalette.expense : AppPalette.income,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.customer.balanceStatus,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: widget.customer.hasDebt ? AppPalette.expense : AppPalette.income,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.customer.hasDebt ? AppPalette.expenseContainer : AppPalette.incomeContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'الرصيد الحالي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: widget.customer.hasDebt ? AppPalette.expense : AppPalette.income,
                  ),
                ),
                Text(
                  widget.customer.formattedBalance,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.customer.hasDebt ? AppPalette.expense : AppPalette.income,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفترة الزمنية',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPeriodChip('اليوم', 'today'),
                const SizedBox(width: 8),
                _buildPeriodChip('الأسبوع', 'week'),
                const SizedBox(width: 8),
                _buildPeriodChip('الشهر', 'month'),
                const SizedBox(width: 8),
                _buildPeriodChip('السنة', 'year'),
                const SizedBox(width: 8),
                _buildPeriodChip('مخصص', 'custom'),
                if (selectedPeriod == 'custom') ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(
                      '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                      style: GoogleFonts.cairo(),
                    ),
                    onPressed: _selectDateRange,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setPeriod(value),
      selectedColor: AppPalette.primaryContainer,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalInvoices = statementSummary['totalInvoices'] as double? ?? 0.0;
    final totalPayments = statementSummary['totalPayments'] as double? ?? 0.0;
    final totalReturns = statementSummary['totalReturns'] as double? ?? 0.0;
    final currentBalance = statementSummary['currentBalance'] as double? ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'إجمالي الفواتير',
            totalInvoices,
            AppPalette.expense,
            Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'إجمالي السداد',
            totalPayments,
            AppPalette.income,
            Icons.payment_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'المرتجعات',
            totalReturns,
            AppPalette.warning,
            Icons.keyboard_return_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'الرصيد',
            currentBalance,
            currentBalance > 0 ? AppPalette.expense : AppPalette.income,
            Icons.account_balance_wallet_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(value),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildStatementTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'كشف الحساب',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppPalette.background,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'التاريخ',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'البيان',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'مدين',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.expense,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'دائن',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.income,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'الرصيد',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppPalette.textHint.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد حركات في هذه الفترة',
                      style: GoogleFonts.cairo(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionRow(transaction);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(CustomerTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              DateFormat('dd/MM/yyyy').format(transaction.createdAt),
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: transaction.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(transaction.icon, color: transaction.color, size: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaction.typeDisplayName,
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              transaction.increasesDebt ? _formatCurrency(transaction.amount) : '',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.expense,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              !transaction.increasesDebt ? _formatCurrency(transaction.amount) : '',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.income,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _formatCurrency(transaction.balanceAfter ?? 0),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: (transaction.balanceAfter ?? 0) > 0 ? AppPalette.expense : AppPalette.income,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter by type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'تصفية حسب النوع:',
                  style: GoogleFonts.cairo(fontSize: 14),
                ),
                const SizedBox(width: 12),
                // Filter chips would go here
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions List
          Container(
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سجل الحركات',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${transactions.length} حركة',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'لا توجد حركات',
                        style: GoogleFonts.cairo(color: AppPalette.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionListItem(transaction);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListItem(CustomerTransaction transaction) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(transaction.icon, color: transaction.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeDisplayName,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy - hh:mm a').format(transaction.createdAt),
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
              Text(
                '${transaction.increasesDebt ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: transaction.color,
                ),
              ),
              Text(
                'الرصيد: ${_formatCurrency(transaction.balanceAfter ?? 0)}',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppPalette.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }
}
