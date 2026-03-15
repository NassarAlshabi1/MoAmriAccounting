import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/database/entities/supplier.dart';
import 'suppliers_controller.dart';

/// Suppliers Page
///
/// Main page for managing suppliers with contact info and account tracking.
class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SuppliersController());
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppPalette.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierDialog(context, controller),
        backgroundColor: AppPalette.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'إضافة مورد',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Row(
        children: [
          // Main List
          Expanded(
            flex: isSmallScreen ? 1 : 3,
            child: _buildSuppliersList(controller),
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

  Widget _buildSuppliersList(SuppliersController controller) {
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
                    'الموردين',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  Obx(() => Text(
                    '${controller.totalSuppliers.value} مورد',
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
                hintText: 'البحث عن مورد...',
                prefixIconData: Icons.search_rounded,
                onChanged: (value) => controller.searchSuppliers(value),
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
                  '${controller.totalDebts.value.toStringAsFixed(2)} ر.س',
                  AppPalette.expense,
                  Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'موردين بديون',
                  '${controller.suppliersWithDebtsCount.value}',
                  AppPalette.warning,
                  Icons.warning_amber_rounded,
                ),
              ),
            ],
          )),
        ),
        // Suppliers List
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredSuppliers.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredSuppliers.length,
              itemBuilder: (context, index) {
                final supplier = controller.filteredSuppliers[index];
                return _buildSupplierCard(controller, supplier);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip(SuppliersController controller, String label, String value) {
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
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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
                  value,
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
            Icons.local_shipping_outlined,
            size: 80,
            color: AppPalette.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد موردين',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر "إضافة مورد" للبدء',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard(SuppliersController controller, Supplier supplier) {
    return Obx(() {
      final isSelected = controller.selectedSupplier.value?.id == supplier.id;
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
            onTap: () => controller.selectSupplier(supplier),
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
                      color: supplier.hasDebt
                          ? AppPalette.expenseContainer
                          : AppPalette.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: supplier.hasDebt ? AppPalette.expense : AppPalette.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (supplier.phone.isNotEmpty) ...[
                              Icon(
                                Icons.phone_rounded,
                                size: 14,
                                color: AppPalette.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                supplier.phone,
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Icon(
                              supplier.hasDebt
                                  ? Icons.arrow_upward_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: supplier.hasDebt ? AppPalette.expense : AppPalette.income,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              supplier.balanceStatus,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: supplier.hasDebt ? AppPalette.expense : AppPalette.income,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Balance
                  if (supplier.hasDebt)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppPalette.expenseContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        supplier.formattedBalance,
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

  Widget _buildDetailsPanel(SuppliersController controller) {
    return Obx(() {
      final supplier = controller.selectedSupplier.value;
      
      if (supplier == null) {
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
                  'اختر مورد لعرض التفاصيل',
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
                      color: AppPalette.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: AppPalette.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'مورد',
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
                    colors: supplier.hasDebt
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
                      'الرصيد الحالي',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supplier.formattedBalance,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.balanceStatus,
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
              _buildInfoRow(Icons.phone_rounded, 'الهاتف', supplier.phone, 'غير محدد'),
              _buildInfoRow(Icons.location_on_rounded, 'العنوان', supplier.address, 'غير محدد'),
              _buildInfoRow(Icons.email_rounded, 'البريد', supplier.email, 'غير محدد'),
              _buildInfoRow(Icons.description_rounded, 'ملاحظات', supplier.description, 'لا توجد'),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'تعديل',
                      icon: Icons.edit_rounded,
                      onPressed: () => _showEditSupplierDialog(
                        Get.context!,
                        controller,
                        supplier,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppSecondaryButton(
                      text: 'سداد',
                      icon: Icons.payment_rounded,
                      onPressed: () => _showPaymentDialog(Get.context!, controller, supplier),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Transactions
              Text(
                'الحركات الأخيرة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingTransactions.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.supplierTransactions.isEmpty) {
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
                  children: controller.supplierTransactions.take(10).map((transaction) {
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

  Widget _buildTransactionItem(SupplierTransaction transaction) {
    Color typeColor;
    IconData typeIcon;
    
    switch (transaction.type) {
      case 'purchase':
        typeColor = AppPalette.expense;
        typeIcon = Icons.shopping_cart_rounded;
        break;
      case 'payment':
        typeColor = AppPalette.income;
        typeIcon = Icons.payment_rounded;
        break;
      case 'return':
        typeColor = AppPalette.warning;
        typeIcon = Icons.keyboard_return_rounded;
        break;
      default:
        typeColor = AppPalette.textSecondary;
        typeIcon = Icons.receipt_rounded;
    }

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
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 18),
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
            '${transaction.amount.toStringAsFixed(2)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddSupplierDialog(BuildContext context, SuppliersController controller) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مورد جديد', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                hintText: 'اسم المورد *',
                prefixIconData: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: phoneController,
                hintText: 'رقم الهاتف',
                prefixIconData: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: addressController,
                hintText: 'العنوان',
                prefixIconData: Icons.location_on_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: emailController,
                hintText: 'البريد الإلكتروني',
                prefixIconData: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: descriptionController,
                hintText: 'ملاحظات',
                prefixIconData: Icons.description_rounded,
                maxLines: 2,
              ),
            ],
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
                        'يرجى إدخال اسم المورد',
                        backgroundColor: AppPalette.expenseContainer,
                        colorText: AppPalette.expense,
                      );
                      return;
                    }
                    
                    final supplier = Supplier(
                      name: nameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      email: emailController.text,
                      description: descriptionController.text,
                    );
                    
                    final result = await controller.addSupplier(supplier);
                    Navigator.pop(context);
                    
                    if (result.isSuccess) {
                      Get.snackbar(
                        'تم',
                        'تم إضافة المورد بنجاح',
                        backgroundColor: AppPalette.incomeContainer,
                        colorText: AppPalette.income,
                      );
                    } else {
                      Get.snackbar(
                        'خطأ',
                        result.errorMessage ?? 'فشل في إضافة المورد',
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

  void _showEditSupplierDialog(
    BuildContext context,
    SuppliersController controller,
    Supplier supplier,
  ) {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone);
    final addressController = TextEditingController(text: supplier.address);
    final emailController = TextEditingController(text: supplier.email);
    final descriptionController = TextEditingController(text: supplier.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل المورد', style: GoogleFonts.cairo()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                hintText: 'اسم المورد *',
                prefixIconData: Icons.person_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: phoneController,
                hintText: 'رقم الهاتف',
                prefixIconData: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: addressController,
                hintText: 'العنوان',
                prefixIconData: Icons.location_on_rounded,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: emailController,
                hintText: 'البريد الإلكتروني',
                prefixIconData: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: descriptionController,
                hintText: 'ملاحظات',
                prefixIconData: Icons.description_rounded,
                maxLines: 2,
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
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'خطأ',
                  'يرجى إدخال اسم المورد',
                  backgroundColor: AppPalette.expenseContainer,
                  colorText: AppPalette.expense,
                );
                return;
              }
              
              final updatedSupplier = supplier.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                address: addressController.text,
                email: emailController.text,
                description: descriptionController.text,
              );
              
              final result = await controller.updateSupplier(updatedSupplier);
              Navigator.pop(context);
              
              if (result.isSuccess) {
                Get.snackbar(
                  'تم',
                  'تم تحديث المورد بنجاح',
                  backgroundColor: AppPalette.incomeContainer,
                  colorText: AppPalette.income,
                );
              } else {
                Get.snackbar(
                  'خطأ',
                  result.errorMessage ?? 'فشل في تحديث المورد',
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
    SuppliersController controller,
    Supplier supplier,
  ) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('سداد للمورد', style: GoogleFonts.cairo()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الرصيد الحالي: ${supplier.formattedBalance}',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppPalette.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            AppCurrencyField(
              controller: amountController,
              hintText: 'مبلغ السداد',
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: descriptionController,
              hintText: 'ملاحظات',
              prefixIconData: Icons.description_rounded,
            ),
          ],
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
              
              final transaction = SupplierTransaction(
                supplierId: supplier.id!,
                type: 'payment',
                amount: amount,
                description: descriptionController.text,
              );
              
              final result = await controller.addTransaction(transaction);
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
    );
  }
}
