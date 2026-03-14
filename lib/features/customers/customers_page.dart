import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/entities/customer_transaction.dart';
import 'package:moamri_accounting/features/customers/customer_report_page.dart';
import 'customers_controller.dart';

/// Customers Page
///
/// Main page for managing customers with account statements and payment tracking.
class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomersController());
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppPalette.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(context, controller),
        backgroundColor: AppPalette.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'إضافة عميل',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Row(
        children: [
          // Main List
          Expanded(
            flex: isSmallScreen ? 1 : 3,
            child: _buildCustomersList(controller),
          ),
          // Details Panel (Desktop only)
          if (!isSmallScreen)
            Expanded(
              flex: 2,
              child: _buildDetailsPanel(controller),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomersList(CustomersController controller) {
    return Column(
      children: [
        // Header
        Container(
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إدارة العملاء',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  Obx(() => Text(
                    '${controller.totalCustomers.value} عميل',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppPalette.textSecondary,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              // Search Bar
              AppTextField(
                hintText: 'البحث عن عميل...',
                prefixIcon: Icons.search_rounded,
                onChanged: (value) => controller.searchCustomers(value),
              ),
              const SizedBox(height: 12),
              // Filter Chips
              Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(controller, 'الكل', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'لهم ديون', 'withDebt'),
                    const SizedBox(width: 8),
                    _buildFilterChip(controller, 'بدون ديون', 'noDebt'),
                  ],
                ),
              )),
            ],
          ),
        ),
        // Statistics Cards
        Container(
          padding: const EdgeInsets.all(16),
          child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الديون',
                  controller.totalDebts.value,
                  AppPalette.expense,
                  Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'عملاء بديون',
                  controller.customersWithDebtsCount.value.toDouble(),
                  AppPalette.warning,
                  Icons.people_rounded,
                  isCount: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'سداد اليوم',
                  controller.todayPayments.value,
                  AppPalette.income,
                  Icons.payment_rounded,
                ),
              ),
            ],
          )),
        ),
        // Customers List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredCustomers.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = controller.filteredCustomers[index];
                return _buildCustomerCard(controller, customer);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(CustomersController controller, String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(value),
        selectedColor: AppPalette.primaryContainer,
        labelStyle: GoogleFonts.cairo(
          fontSize: 13,
          color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
        ),
      );
    });
  }

  Widget _buildStatCard(String title, double value, Color color, IconData icon,
      {bool isCount = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCount ? value.toInt().toString() : _formatCurrency(value),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80,
            color: AppPalette.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد عملاء',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر "إضافة عميل" للبدء',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomersController controller, Customer customer) {
    return Obx(() {
      final isSelected = controller.selectedCustomer.value?.id == customer.id;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPalette.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.selectCustomer(customer),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: customer.hasDebt
                          ? AppPalette.expenseContainer
                          : AppPalette.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: customer.hasDebt ? AppPalette.expense : AppPalette.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (customer.phone.isNotEmpty) ...[
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppPalette.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Icon(
                              customer.hasDebt
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: customer.hasDebt ? AppPalette.expense : AppPalette.income,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer.balanceStatus,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: customer.hasDebt ? AppPalette.expense : AppPalette.income,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  if (customer.hasDebt)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppPalette.expenseContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        customer.formattedBalance,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.expense,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetailsPanel(CustomersController controller) {
    return Obx(() {
      final customer = controller.selectedCustomer.value;

      if (customer == null) {
        return Container(
          color: AppPalette.surface,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 64,
                  color: AppPalette.textHint.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'اختر عميل لعرض التفاصيل',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        color: AppPalette.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: customer.hasDebt
                          ? AppPalette.expenseContainer
                          : AppPalette.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: customer.hasDebt ? AppPalette.expense : AppPalette.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'عميل',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => controller.clearSelection(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: customer.hasDebt
                        ? [AppPalette.expense, AppPalette.expense.withOpacity(0.8)]
                        : [AppPalette.income, AppPalette.income.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد المتبقي',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      customer.formattedBalance,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.balanceStatus,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Info
              Text(
                'بيانات الاتصال',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone_rounded, 'الهاتف', customer.phone, 'غير محدد'),
              _buildInfoRow(Icons.location_on_rounded, 'العنوان', customer.address, 'غير محدد'),
              _buildInfoRow(Icons.description_rounded, 'ملاحظات', customer.description, 'لا توجد'),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'إجراءات سريعة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'سداد',
                      icon: Icons.payment_rounded,
                      onPressed: () => _showPaymentDialog(Get.context!, controller, customer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'فاتورة',
                      icon: Icons.receipt_long_rounded,
                      onPressed: () {
                        // Navigate to invoice with customer
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'تعديل',
                      icon: Icons.edit_rounded,
                      onPressed: () => _showEditCustomerDialog(Get.context!, controller, customer),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'تقرير',
                      icon: Icons.description_rounded,
                      onPressed: () => Get.to(() => CustomerReportPage(customer: customer)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Statement Summary
              Text(
                'كشف الحساب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppPalette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatementRow(
                      'إجمالي الفواتير',
                      controller.statementTotalInvoices.value,
                      AppPalette.expense,
                    ),
                    const Divider(height: 16),
                    _buildStatementRow(
                      'إجمالي السداد',
                      controller.statementTotalPayments.value,
                      AppPalette.income,
                    ),
                    const Divider(height: 16),
                    _buildStatementRow(
                      'إجمالي المرتجعات',
                      controller.statementTotalReturns.value,
                      AppPalette.warning,
                    ),
                    const Divider(height: 16),
                    _buildStatementRow(
                      'الرصيد الحالي',
                      controller.statementBalance.value,
                      controller.statementBalance.value > 0 ? AppPalette.expense : AppPalette.income,
                      isBold: true,
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'آخر الحركات',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => CustomerReportPage(customer: customer)),
                    child: Text('عرض الكل', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingTransactions.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.customerTransactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppPalette.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'لا توجد حركات',
                        style: GoogleFonts.cairo(
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.customerTransactions.take(5).map((transaction) {
                    return _buildTransactionItem(transaction);
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value, String emptyText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppPalette.textHint),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : emptyText,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: value.isNotEmpty ? AppPalette.textPrimary : AppPalette.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementRow(String label, double value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          _formatCurrency(value),
          style: GoogleFonts.cairo(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(CustomerTransaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: transaction.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(transaction.icon, color: transaction.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeDisplayName,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(transaction.createdAt),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppPalette.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.increasesDebt ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)}',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: transaction.color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showAddCustomerDialog(BuildContext context, CustomersController controller) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    final openingBalanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة عميل جديد', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  hintText: 'اسم العميل *',
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: phoneController,
                  hintText: 'رقم الهاتف',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: addressController,
                  hintText: 'العنوان',
                  prefixIcon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descriptionController,
                  hintText: 'ملاحظات',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                AppCurrencyField(
                  controller: openingBalanceController,
                  hintText: 'الرصيد الافتتاحي (دين)',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isSaving.value
                ? null
                : () async {
                    if (nameController.text.isEmpty) {
                      Get.snackbar(
                        'خطأ',
                        'يرجى إدخال اسم العميل',
                        backgroundColor: AppPalette.expenseContainer,
                        colorText: AppPalette.expense,
                      );
                      return;
                    }

                    final customer = Customer(
                      name: nameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      description: descriptionController.text,
                    );

                    final result = await controller.addCustomer(customer);

                    // Add opening balance if provided
                    if (result.isSuccess && openingBalanceController.text.isNotEmpty) {
                      final balance = double.tryParse(openingBalanceController.text);
                      if (balance != null && balance > 0) {
                        await controller.recordOpeningBalance(
                          customerId: result.data!,
                          amount: balance,
                        );
                      }
                    }

                    Navigator.pop(context);

                    if (result.isSuccess) {
                      Get.snackbar(
                        'تم',
                        'تم إضافة العميل بنجاح',
                        backgroundColor: AppPalette.incomeContainer,
                        colorText: AppPalette.income,
                      );
                    } else {
                      Get.snackbar(
                        'خطأ',
                        result.errorMessage ?? 'فشل في إضافة العميل',
                        backgroundColor: AppPalette.expenseContainer,
                        colorText: AppPalette.expense,
                      );
                    }
                  },
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('حفظ', style: GoogleFonts.cairo()),
          )),
        ],
      ),
    );
  }

  void _showEditCustomerDialog(
    BuildContext context,
    CustomersController controller,
    Customer customer,
  ) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final addressController = TextEditingController(text: customer.address);
    final descriptionController = TextEditingController(text: customer.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل العميل', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: nameController,
                  hintText: 'اسم العميل *',
                  prefixIcon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: phoneController,
                  hintText: 'رقم الهاتف',
                  prefixIcon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: addressController,
                  hintText: 'العنوان',
                  prefixIcon: Icons.location_on_rounded,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descriptionController,
                  hintText: 'ملاحظات',
                  prefixIcon: Icons.description_rounded,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى إدخال اسم العميل',
                  backgroundColor: AppPalette.expenseContainer,
                  colorText: AppPalette.expense,
                );
                return;
              }

              final updatedCustomer = customer.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text,
                description: descriptionController.text,
              );

              final result = await controller.updateCustomer(updatedCustomer, customer);
              Navigator.pop(context);

              if (result.isSuccess) {
                Get.snackbar(
                  'تم',
                  'تم تحديث العميل بنجاح',
                  backgroundColor: AppPalette.incomeContainer,
                  colorText: AppPalette.income,
                );
              } else {
                Get.snackbar(
                  'خطأ',
                  result.errorMessage ?? 'فشل في تحديث العميل',
                  backgroundColor: AppPalette.expenseContainer,
                  colorText: AppPalette.expense,
                );
              }
            },
            child: Text('حفظ', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(
    BuildContext context,
    CustomersController controller,
    Customer customer,
  ) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPaymentMethod = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تسجيل سداد', style: GoogleFonts.cairo()),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current Balance
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.expenseContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الرصيد الحالي:', style: GoogleFonts.cairo()),
                      Text(
                        customer.formattedBalance,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: AppPalette.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCurrencyField(
                  controller: amountController,
                  hintText: 'مبلغ السداد',
                ),
                const SizedBox(height: 12),
                // Payment Method
                Row(
                  children: [
                    Text('طريقة الدفع:', style: GoogleFonts.cairo()),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'cash',
                            groupValue: selectedPaymentMethod,
                            onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                          ),
                          Text('نقدي', style: GoogleFonts.cairo(fontSize: 13)),
                          const SizedBox(width: 12),
                          Radio<String>(
                            value: 'card',
                            groupValue: selectedPaymentMethod,
                            onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                          ),
                          Text('بطاقة', style: GoogleFonts.cairo(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: descriptionController,
                  hintText: 'ملاحظات',
                  prefixIcon: Icons.description_rounded,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) {
                  Get.snackbar(
                    'خطأ',
                    'يرجى إدخال مبلغ صحيح',
                    backgroundColor: AppPalette.expenseContainer,
                    colorText: AppPalette.expense,
                  );
                  return;
                }

                final result = await controller.recordPayment(
                  customerId: customer.id!,
                  amount: amount,
                  paymentMethod: selectedPaymentMethod,
                  description: descriptionController.text,
                );

                Navigator.pop(context);

                if (result.isSuccess) {
                  Get.snackbar(
                    'تم',
                    'تم تسجيل السداد بنجاح',
                    backgroundColor: AppPalette.incomeContainer,
                    colorText: AppPalette.income,
                  );
                } else {
                  Get.snackbar(
                    'خطأ',
                    result.errorMessage ?? 'فشل في تسجيل السداد',
                    backgroundColor: AppPalette.expenseContainer,
                    colorText: AppPalette.expense,
                  );
                }
              },
              child: Text('تأكيد', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
