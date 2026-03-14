import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:intl/intl.dart';

/// Expenses Page - Modern Expense Management
///
/// Features:
/// - Daily/Monthly expense summary
/// - Expense categories with charts
/// - Add expense quickly
/// - Expense history with filters
class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String _selectedPeriod = 'today'; // today, week, month, custom
  DateTime _selectedDate = DateTime.now();

  // Sample data
  final List<ExpenseCategory> _categories = [
    ExpenseCategory(name: 'رواتب', icon: Icons.people_rounded, color: AppPalette.primary),
    ExpenseCategory(name: 'إيجار', icon: Icons.home_rounded, color: AppPalette.info),
    ExpenseCategory(name: 'فواتير', icon: Icons.receipt_rounded, color: AppPalette.warning),
    ExpenseCategory(name: 'مشتريات', icon: Icons.shopping_cart_rounded, color: AppPalette.income),
    ExpenseCategory(name: 'صيانة', icon: Icons.build_rounded, color: AppPalette.secondary),
    ExpenseCategory(name: 'أخرى', icon: Icons.more_horiz_rounded, color: AppPalette.other),
  ];

  final List<Expense> _expenses = [
    Expense(
      id: 1,
      title: 'راتب الموظفين',
      category: 'رواتب',
      amount: 15000.00,
      currency: 'ريال',
      date: DateTime.now(),
      note: 'رواتب شهر مارس',
    ),
    Expense(
      id: 2,
      title: 'إيجار المحل',
      category: 'إيجار',
      amount: 5000.00,
      currency: 'ريال',
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'إيجار شهر مارس',
    ),
    Expense(
      id: 3,
      title: 'فاتورة الكهرباء',
      category: 'فواتير',
      amount: 850.00,
      currency: 'ريال',
      date: DateTime.now().subtract(const Duration(days: 2)),
      note: '',
    ),
    Expense(
      id: 4,
      title: 'صيانة المكيف',
      category: 'صيانة',
      amount: 350.00,
      currency: 'ريال',
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'صيانة دورية',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildPeriodSelector(),
          _buildSummaryCards(),
          _buildCategoryBreakdown(),
          _buildExpensesList(),
        ],
      ),
      floatingActionButton: AppFAB(
        label: 'إضافة مصروف',
        icon: Icons.add_rounded,
        onPressed: () => _showAddExpenseDialog(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
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
                    'المصروفات',
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
                      const SizedBox(width: 8),
                      AppSecondaryButton(
                        text: 'تصدير',
                        icon: Icons.download_rounded,
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

  Widget _buildPeriodSelector() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PeriodSelectorDelegate(
        selectedPeriod: _selectedPeriod,
        onPeriodChanged: (period) => setState(() => _selectedPeriod = period),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final todayExpenses = _calculateExpensesForPeriod('today');
    final weekExpenses = _calculateExpensesForPeriod('week');
    final monthExpenses = _calculateExpensesForPeriod('month');

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص المصروفات',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildExpenseSummaryCard(
                    title: 'اليوم',
                    amount: todayExpenses,
                    icon: Icons.today_rounded,
                    color: AppPalette.expense,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExpenseSummaryCard(
                    title: 'الأسبوع',
                    amount: weekExpenses,
                    icon: Icons.date_range_rounded,
                    color: AppPalette.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExpenseSummaryCard(
                    title: 'الشهر',
                    amount: monthExpenses,
                    icon: Icons.calendar_month_rounded,
                    color: AppPalette.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
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
            '${_formatCurrency(amount)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 18,
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

  Widget _buildCategoryBreakdown() {
    final categoryTotals = _calculateCategoryTotals();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المصروفات حسب التصنيف',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
              ),
              child: Column(
                children: categoryTotals.entries.map((entry) {
                  final category = _categories.firstWhere(
                    (c) => c.name == entry.key,
                    orElse: () => _categories.last,
                  );
                  final percentage = _calculatePercentage(entry.value);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(category.icon, color: category.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${_formatCurrency(entry.value)} ر.س',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: category.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: category.color.withOpacity(0.15),
                                      valueColor: AlwaysStoppedAnimation(category.color),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    final filteredExpenses = _getFilteredExpenses();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل المصروفات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Text('تصفية', style: GoogleFonts.cairo()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filteredExpenses.map((expense) => _buildExpenseItem(expense)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    final category = _categories.firstWhere(
      (c) => c.name == expense.category,
      orElse: () => _categories.last,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(category.icon, color: category.color),
        ),
        title: Text(
          expense.title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    expense.category,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: category.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time_rounded, size: 12, color: AppPalette.textHint),
                const SizedBox(width: 4),
                Text(
                  _formatDate(expense.date),
                  style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textHint),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(2)} ر.س',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppPalette.expense,
              ),
            ),
            if (expense.note.isNotEmpty)
              Text(
                expense.note,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppPalette.textHint,
                ),
              ),
          ],
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  double _calculateExpensesForPeriod(String period) {
    final now = DateTime.now();
    return _expenses.where((e) {
      switch (period) {
        case 'today':
          return e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day;
        case 'week':
          final weekAgo = now.subtract(const Duration(days: 7));
          return e.date.isAfter(weekAgo);
        case 'month':
          return e.date.year == now.year && e.date.month == now.month;
        default:
          return true;
      }
    }).fold<double>(0, (sum, e) => sum + e.amount);
  }

  Map<String, double> _calculateCategoryTotals() {
    final totals = <String, double>{};
    for (final expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  double _calculatePercentage(double value) {
    final total = _expenses.fold<double>(0, (sum, e) => sum + e.amount);
    return total > 0 ? value / total : 0;
  }

  List<Expense> _getFilteredExpenses() {
    // Apply period filter
    return _expenses;
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
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _showAddExpenseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddExpenseSheet(
        categories: _categories,
        onSaved: (expense) {
          setState(() {
            _expenses.insert(0, expense);
          });
        },
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    // Show expense details
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Period Selector Delegate
class _PeriodSelectorDelegate extends SliverPersistentHeaderDelegate {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  _PeriodSelectorDelegate({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPalette.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildPeriodChip('اليوم', 'today'),
          const SizedBox(width: 8),
          _buildPeriodChip('الأسبوع', 'week'),
          const SizedBox(width: 8),
          _buildPeriodChip('الشهر', 'month'),
          const SizedBox(width: 8),
          _buildPeriodChip('مخصص', 'custom'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onPeriodChanged(value),
      selectedColor: AppPalette.primaryContainer,
      labelStyle: GoogleFonts.cairo(
        fontSize: 13,
        color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant _PeriodSelectorDelegate oldDelegate) {
    return selectedPeriod != oldDelegate.selectedPeriod;
  }
}

/// Add Expense Bottom Sheet
class _AddExpenseSheet extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final Function(Expense) onSaved;

  const _AddExpenseSheet({
    required this.categories,
    required this.onSaved,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'أخرى';
  String _selectedCurrency = 'ريال';

  @override
  Widget build(BuildContext context) {
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
                'إضافة مصروف جديد',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Category selection
              Text(
                'التصنيف',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories.map((cat) {
                  final isSelected = _selectedCategory == cat.name;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                        const SizedBox(width: 4),
                        Text(cat.name),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat.name),
                    selectedColor: cat.color,
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppPalette.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _titleController,
                label: 'عنوان المصروف',
                hint: 'مثال: فاتورة الكهرباء',
                validator: (value) =>
                    value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 16),

              AppCurrencyField(
                controller: _amountController,
                label: 'المبلغ',
                currency: _selectedCurrency,
                validator: (value) {
                  if (value?.isEmpty == true) return 'هذا الحقل مطلوب';
                  if (double.tryParse(value!) == null) return 'أدخل رقم صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _noteController,
                label: 'ملاحظة (اختياري)',
                hint: 'أضف ملاحظة...',
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              AppPrimaryButton(
                text: 'حفظ المصروف',
                icon: Icons.save_rounded,
                isFullWidth: true,
                onPressed: _saveExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        date: DateTime.now(),
        note: _noteController.text,
      );
      widget.onSaved(expense);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

/// Expense Category Model
class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Expense Model
class Expense {
  final int id;
  final String title;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.note,
  });
}
