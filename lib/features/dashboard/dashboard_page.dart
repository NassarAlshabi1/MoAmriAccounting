import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/dashboard_widgets.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Dashboard Page - Modern Home Screen
///
/// Features:
/// - Financial summary cards
/// - Quick actions
/// - Recent transactions
/// - Responsive design
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;

  // Sample data - would come from controller in real app
  final double _todayIncome = 15420.50;
  final double _todayExpense = 8750.00;
  final double _monthlyIncome = 285000.00;
  final double _monthlyExpense = 195000.00;
  final int _invoicesCount = 47;
  final int _customersCount = 156;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context),
                    SizedBox(height: isSmallScreen ? 20 : 32),

                    // Today's Summary
                    _buildSectionTitle('ملخص اليوم'),
                    const SizedBox(height: 16),
                    _buildTodaySummary(context, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Quick Actions
                    _buildSectionTitle('إجراءات سريعة'),
                    const SizedBox(height: 16),
                    _buildQuickActions(context, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Financial Summary
                    _buildSectionTitle('الملخص المالي الشهري'),
                    const SizedBox(height: 16),
                    _buildFinancialSummary(context, isSmallScreen),
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Recent Transactions
                    _buildSectionTitleWithAction(
                      'آخر المعاملات',
                      'عرض الكل',
                      () {},
                    ),
                    const SizedBox(height: 16),
                    _buildRecentTransactions(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً، أحمد 👋',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إليك ملخص حساباتك لليوم',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppPalette.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            AppIconButton(
              icon: Icons.notifications_outlined,
              onPressed: () {},
              tooltip: 'الإشعارات',
            ),
            const SizedBox(width: 12),
            AppIconButton(
              icon: Icons.settings_outlined,
              onPressed: () {},
              tooltip: 'الإعدادات',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppPalette.textPrimary,
      ),
    );
  }

  Widget _buildSectionTitleWithAction(
    String title,
    String actionLabel,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySummary(BuildContext context, bool isSmallScreen) {
    final cards = [
      StatCard(
        title: 'مبيعات اليوم',
        value: '${_formatCurrency(_todayIncome)} ر.س',
        icon: Icons.point_of_sale_rounded,
        backgroundColor: AppPalette.infoContainer,
        iconColor: AppPalette.info,
        showTrend: true,
        trendValue: 12.5,
      ),
      StatCard(
        title: 'مصروفات اليوم',
        value: '${_formatCurrency(_todayExpense)} ر.س',
        icon: Icons.shopping_bag_outlined,
        backgroundColor: AppPalette.expenseContainer,
        iconColor: AppPalette.expense,
        showTrend: true,
        trendValue: -3.2,
      ),
      StatCard(
        title: 'الفواتير',
        value: _invoicesCount.toString(),
        subtitle: 'فاتورة اليوم',
        icon: Icons.receipt_long_rounded,
        backgroundColor: AppPalette.warningContainer,
        iconColor: AppPalette.warning,
      ),
      StatCard(
        title: 'العملاء',
        value: _customersCount.toString(),
        subtitle: 'عميل نشط',
        icon: Icons.people_rounded,
        backgroundColor: AppPalette.primaryContainer,
        iconColor: AppPalette.primary,
      ),
    ];

    if (isSmallScreen) {
      return Column(
        children: [
          Row(children: cards.sublist(0, 2)),
          const SizedBox(height: 12),
          Row(children: cards.sublist(2, 4)),
        ],
      );
    }

    return Row(
      children: cards
          .asMap()
          .entries
          .map((e) => [
                Expanded(child: e.value),
                if (e.key < cards.length - 1) const SizedBox(width: 16),
              ])
          .expand((e) => e)
          .toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isSmallScreen) {
    final actions = [
      QuickActionButton(
        label: 'فاتورة جديدة',
        icon: Icons.add_shopping_cart_rounded,
        color: AppPalette.primary,
        onTap: () => _navigateToInvoice(),
      ),
      QuickActionButton(
        label: 'إضافة منتج',
        icon: Icons.inventory_2_rounded,
        color: AppPalette.income,
        onTap: () {},
      ),
      QuickActionButton(
        label: 'إضافة عميل',
        icon: Icons.person_add_rounded,
        color: AppPalette.info,
        onTap: () {},
      ),
      QuickActionButton(
        label: 'التقارير',
        icon: Icons.analytics_rounded,
        color: AppPalette.warning,
        onTap: () {},
      ),
    ];

    if (isSmallScreen) {
      return Row(
        children: actions
            .asMap()
            .entries
            .map((e) => [
                  Expanded(child: e.value),
                  if (e.key < actions.length - 1) const SizedBox(width: 12),
                ])
            .expand((e) => e)
            .toList(),
      );
    }

    return Row(
      children: actions
          .asMap()
          .entries
          .map((e) => [
                Expanded(child: e.value),
                if (e.key < actions.length - 1) const SizedBox(width: 16),
              ])
          .expand((e) => e)
          .toList(),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          flex: isSmallScreen ? 1 : 2,
          child: FinancialSummaryCard(
            title: 'الإيرادات والمصروفات',
            income: _monthlyIncome,
            expense: _monthlyExpense,
          ),
        ),
        if (!isSmallScreen) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatsOverview(),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
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
            'نظرة عامة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressItem(
            label: 'المخزون',
            current: 75,
            total: 100,
            color: AppPalette.primary,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            label: 'المبيعات المستهدفة',
            current: 285000,
            total: 400000,
            color: AppPalette.income,
          ),
          const SizedBox(height: 16),
          _buildProgressItem(
            label: 'تحصيل الديون',
            current: 45000,
            total: 75000,
            color: AppPalette.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required String label,
    required double current,
    required double total,
    required Color color,
  }) {
    final percentage = (current / total) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppPalette.textSecondary,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final transactions = [
      (
        title: 'فاتورة مبيعات #1234',
        subtitle: 'محمد أحمد',
        amount: 1250.00,
        isIncome: true,
        time: 'منذ 5 دقائق',
      ),
      (
        title: 'فاتورة مشتريات',
        subtitle: 'مورد الأجهزة',
        amount: 3500.00,
        isIncome: false,
        time: 'منذ 15 دقيقة',
      ),
      (
        title: 'فاتورة مبيعات #1233',
        subtitle: 'شركة النور',
        amount: 8750.00,
        isIncome: true,
        time: 'منذ ساعة',
      ),
      (
        title: 'إرجاع منتج',
        subtitle: 'علي محمود',
        amount: 450.00,
        isIncome: false,
        time: 'منذ ساعتين',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: transactions
            .asMap()
            .entries
            .map((e) => [
                  RecentTransactionItem(
                    title: e.value.title,
                    subtitle: e.value.subtitle,
                    amount: e.value.amount,
                    isIncome: e.value.isIncome,
                    time: e.value.time,
                    onTap: () {},
                  ),
                  if (e.key < transactions.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ])
            .expand((e) => e)
            .toList(),
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(2);
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _navigateToInvoice() {
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const InvoicePage()));
  }
}
