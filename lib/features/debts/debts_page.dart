import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Debts Page - Modern Debt Management
///
/// Features:
/// - Total debts summary (receivable/payable)
/// - Debts list with status
/// - Payment tracking
/// - Due date alerts
/// - Quick payment recording
class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, overdue, due-soon, paid

  // Sample data
  final List<Debt> _receivableDebts = [
    Debt(
      id: 1,
      customerName: 'محمد أحمد العلي',
      amount: 5500.00,
      paidAmount: 1500.00,
      currency: 'ريال',
      dueDate: DateTime.now().add(const Duration(days: 15)),
      createdDate: DateTime.now().subtract(const Duration(days: 10)),
      status: DebtStatus.pending,
      note: 'فاتورة #1234',
    ),
    Debt(
      id: 2,
      customerName: 'شركة النور للتجارة',
      amount: 12500.00,
      paidAmount: 0,
      currency: 'ريال',
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      createdDate: DateTime.now().subtract(const Duration(days: 30)),
      status: DebtStatus.overdue,
      note: 'فاتورة #1198',
    ),
    Debt(
      id: 3,
      customerName: 'فهد سالم القحطاني',
      amount: 3200.00,
      paidAmount: 3200.00,
      currency: 'ريال',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      createdDate: DateTime.now().subtract(const Duration(days: 20)),
      status: DebtStatus.paid,
      note: 'فاتورة #1210',
    ),
  ];

  final List<Debt> _payableDebts = [
    Debt(
      id: 4,
      supplierName: 'مورد الأجهزة الإلكترونية',
      amount: 25000.00,
      paidAmount: 10000.00,
      currency: 'ريال',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdDate: DateTime.now().subtract(const Duration(days: 15)),
      status: DebtStatus.pending,
      note: 'شراء أجهزة',
    ),
    Debt(
      id: 5,
      supplierName: 'شركة المواد الغذائية',
      amount: 8500.00,
      paidAmount: 0,
      currency: 'ريال',
      dueDate: DateTime.now().add(const Duration(days: 20)),
      createdDate: DateTime.now().subtract(const Duration(days: 5)),
      status: DebtStatus.pending,
      note: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
          _buildTabBar(),
          _buildSummaryCards(),
          _buildFilterBar(),
        ],
        body: _buildBody(),
      ),
      floatingActionButton: AppFAB(
        label: 'تسجيل دفع',
        icon: Icons.payment_rounded,
        onPressed: () => _showPaymentDialog(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: AppPalette.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إدارة الديون',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      AppSecondaryButton(
                        text: 'تقرير',
                        icon: Icons.assessment_rounded,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        tabController: _tabController,
        receivableCount: _receivableDebts.length,
        payableCount: _payableDebts.length,
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalReceivable = _calculateTotalDebt(_receivableDebts);
    final totalPayable = _calculateTotalDebt(_payableDebts);
    final overdueCount = _receivableDebts.where((d) => d.status == DebtStatus.overdue).length;

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'ديون مستحقة لك',
                amount: totalReceivable,
                currency: 'ريال',
                icon: Icons.arrow_downward_rounded,
                color: AppPalette.income,
                subtitle: '${_receivableDebts.where((d) => d.status != DebtStatus.paid).length} دين',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'ديون عليك',
                amount: totalPayable,
                currency: 'ريال',
                icon: Icons.arrow_upward_rounded,
                color: AppPalette.expense,
                subtitle: '${_payableDebts.where((d) => d.status != DebtStatus.paid).length} دين',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'متأخرات',
                amount: overdueCount.toDouble(),
                currency: overdueCount == 1 ? 'دين' : 'ديون',
                icon: Icons.warning_rounded,
                color: AppPalette.warning,
                subtitle: 'تجاوزت الموعد',
                isCount: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required String currency,
    required IconData icon,
    required Color color,
    required String subtitle,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isCount ? '${amount.toInt()}' : '${_formatCurrency(amount)} $currency',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildFilterBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterBarDelegate(
        searchController: _searchController,
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
        onSearchChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDebtsList(_receivableDebts, isReceivable: true),
        _buildDebtsList(_payableDebts, isReceivable: false),
      ],
    );
  }

  Widget _buildDebtsList(List<Debt> debts, {required bool isReceivable}) {
    final filteredDebts = _getFilteredDebts(debts);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredDebts.isEmpty) {
      return _buildEmptyState(isReceivable);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredDebts.length,
      itemBuilder: (context, index) => _buildDebtCard(filteredDebts[index], isReceivable),
    );
  }

  Widget _buildEmptyState(bool isReceivable) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReceivable ? Icons.sentiment_satisfied_rounded : Icons.check_circle_outline_rounded,
            size: 80,
            color: AppPalette.income,
          ),
          const SizedBox(height: 16),
          Text(
            isReceivable ? 'لا توجد ديون مستحقة لك' : 'لا توجد ديون عليك',
            style: GoogleFonts.cairo(fontSize: 18, color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'أحسنت! جميع الديون مسددة',
            style: GoogleFonts.cairo(fontSize: 14, color: AppPalette.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(Debt debt, bool isReceivable) {
    final remainingAmount = debt.amount - debt.paidAmount;
    final progress = debt.paidAmount / debt.amount;
    final isOverdue = debt.dueDate.isBefore(DateTime.now()) && debt.status != DebtStatus.paid;
    final daysUntilDue = debt.dueDate.difference(DateTime.now()).inDays;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (debt.status) {
      case DebtStatus.paid:
        statusColor = AppPalette.income;
        statusText = 'مسدد';
        statusIcon = Icons.check_circle_rounded;
        break;
      case DebtStatus.overdue:
        statusColor = AppPalette.expense;
        statusText = 'متأخر';
        statusIcon = Icons.error_rounded;
        break;
      case DebtStatus.pending:
        statusColor = daysUntilDue <= 7 ? AppPalette.warning : AppPalette.info;
        statusText = daysUntilDue <= 0 ? 'مستحق اليوم' : '$daysUntilDue يوم';
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? AppPalette.expense.withOpacity(0.5)
              : debt.status == DebtStatus.paid
                  ? AppPalette.income.withOpacity(0.5)
                  : AppPalette.outline.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDebtDetails(debt),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isReceivable
                            ? AppPalette.incomeContainer
                            : AppPalette.expenseContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isReceivable ? Icons.person_rounded : Icons.store_rounded,
                        color: isReceivable ? AppPalette.income : AppPalette.expense,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isReceivable ? debt.customerName : debt.supplierName,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 14, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            debt.note.isNotEmpty ? debt.note : 'فاتورة #${debt.id}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppPalette.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المبلغ الإجمالي', style: GoogleFonts.cairo(fontSize: 13)),
                          Text(
                            '${debt.amount.toStringAsFixed(2)} ${debt.currency}',
                            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('المسدد', style: GoogleFonts.cairo(fontSize: 13, color: AppPalette.income)),
                          Text(
                            '${debt.paidAmount.toStringAsFixed(2)} ${debt.currency}',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.income,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppPalette.outline.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation(
                            debt.status == DebtStatus.paid
                                ? AppPalette.income
                                : AppPalette.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المتبقي',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          Text(
                            '${remainingAmount.toStringAsFixed(2)} ${debt.currency}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: debt.status == DebtStatus.paid
                                  ? AppPalette.income
                                  : AppPalette.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Due date and actions
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: AppPalette.textHint),
                    const SizedBox(width: 8),
                    Text(
                      'تاريخ الاستحقاق: ${_formatDate(debt.dueDate)}',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isOverdue ? AppPalette.expense : AppPalette.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (debt.status != DebtStatus.paid)
                      AppPrimaryButton(
                        text: isReceivable ? 'استلام دفع' : 'تسديد',
                        icon: Icons.payment_rounded,
                        onPressed: () => _showPaymentDialogForDebt(debt),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateTotalDebt(List<Debt> debts) {
    return debts
        .where((d) => d.status != DebtStatus.paid)
        .fold<double>(0, (sum, d) => sum + (d.amount - d.paidAmount));
  }

  List<Debt> _getFilteredDebts(List<Debt> debts) {
    var filtered = debts;
    final search = _searchController.text.toLowerCase();

    if (search.isNotEmpty) {
      filtered = filtered.where((d) =>
          (d.customerName?.toLowerCase().contains(search) ?? false) ||
          (d.supplierName?.toLowerCase().contains(search) ?? false)).toList();
    }

    switch (_selectedFilter) {
      case 'overdue':
        filtered = filtered.where((d) => d.status == DebtStatus.overdue).toList();
        break;
      case 'due-soon':
        filtered = filtered.where((d) {
          final days = d.dueDate.difference(DateTime.now()).inDays;
          return d.status != DebtStatus.paid && days <= 7 && days > 0;
        }).toList();
        break;
      case 'paid':
        filtered = filtered.where((d) => d.status == DebtStatus.paid).toList();
        break;
    }

    return filtered;
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPaymentDialog() {
    // Show general payment dialog
  }

  void _showPaymentDialogForDebt(Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentSheet(
        debt: debt,
        onPaid: (amount) {
          setState(() {
            final debts = debt.customerName != null ? _receivableDebts : _payableDebts;
            final index = debts.indexWhere((d) => d.id == debt.id);
            if (index != -1) {
              final newPaidAmount = debts[index].paidAmount + amount;
              debts[index] = Debt(
                id: debt.id,
                customerName: debt.customerName,
                supplierName: debt.supplierName,
                amount: debt.amount,
                paidAmount: newPaidAmount,
                currency: debt.currency,
                dueDate: debt.dueDate,
                createdDate: debt.createdDate,
                status: newPaidAmount >= debt.amount ? DebtStatus.paid : debt.status,
                note: debt.note,
              );
            }
          });
        },
      ),
    );
  }

  void _showDebtDetails(Debt debt) {
    // Show debt details
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

/// Tab Bar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final int receivableCount;
  final int payableCount;

  _TabBarDelegate({
    required this.tabController,
    required this.receivableCount,
    required this.payableCount,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPalette.surface,
      child: TabBar(
        controller: tabController,
        indicatorColor: AppPalette.primary,
        indicatorWeight: 3,
        labelColor: AppPalette.primary,
        unselectedLabelColor: AppPalette.textSecondary,
        labelStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 18),
                const SizedBox(width: 8),
                Text('ديون لك ($receivableCount)'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 18),
                const SizedBox(width: 8),
                Text('ديون عليك ($payableCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return receivableCount != oldDelegate.receivableCount ||
        payableCount != oldDelegate.payableCount;
  }
}

/// Filter Bar Delegate
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;

  _FilterBarDelegate({
    required this.searchController,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPalette.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: searchController,
                  hint: 'البحث...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: onSearchChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('متأخرات', 'overdue'),
                const SizedBox(width: 8),
                _buildFilterChip('مستحق قريباً', 'due-soon'),
                const SizedBox(width: 8),
                _buildFilterChip('مسدد', 'paid'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter === value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      selectedColor: AppPalette.primaryContainer,
      labelStyle: GoogleFonts.cairo(
        fontSize: 12,
        color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
      ),
    );
  }

  @override
  double get maxExtent => 110;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) {
    return selectedFilter != oldDelegate.selectedFilter;
  }
}

/// Payment Bottom Sheet
class _PaymentSheet extends StatefulWidget {
  final Debt debt;
  final Function(double) onPaid;

  const _PaymentSheet({required this.debt, required this.onPaid});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    final remaining = widget.debt.amount - widget.debt.paidAmount;
    _amountController.text = remaining.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.debt.amount - widget.debt.paidAmount;
    final isReceivable = widget.debt.customerName != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppPalette.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isReceivable ? 'استلام دفع' : 'تسديد دين',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isReceivable ? widget.debt.customerName! : widget.debt.supplierName!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Amount info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المبلغ المتبقي', style: GoogleFonts.cairo()),
                    Text(
                      '${remaining.toStringAsFixed(2)} ${widget.debt.currency}',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AppCurrencyField(
                controller: _amountController,
                label: 'مبلغ الدفع',
                currency: widget.debt.currency,
                validator: (value) {
                  if (value?.isEmpty == true) return 'هذا الحقل مطلوب';
                  final amount = double.tryParse(value!);
                  if (amount == null) return 'أدخل رقم صحيح';
                  if (amount > remaining) return 'المبلغ أكبر من المتبقي';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment method
              Text(
                'طريقة الدفع',
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethod('cash', 'نقدي', Icons.payments_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentMethod('transfer', 'تحويل', Icons.account_balance_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              AppPrimaryButton(
                text: 'تأكيد الدفع',
                icon: Icons.check_rounded,
                isFullWidth: true,
                onPressed: _processPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.primaryContainer : AppPalette.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppPalette.primary : AppPalette.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      widget.onPaid(double.parse(_amountController.text));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

/// Debt Status Enum
enum DebtStatus {
  pending,
  overdue,
  paid,
}

/// Debt Model
class Debt {
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

  Debt({
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
  });
}
