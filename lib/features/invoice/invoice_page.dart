import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Invoice Page - Create New Invoice
///
/// Features:
/// - Clean, intuitive form layout
/// - Quick product search
/// - Real-time total calculation
/// - Multiple payment methods
/// - Responsive design
class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _customerSearchController = TextEditingController();
  final _productSearchController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isSearchingProduct = false;

  // Selected data
  String? _selectedCustomer;
  String _paymentMethod = 'cash';
  List<InvoiceLineItem> _items = [];

  // Currency selection
  String _selectedCurrency = 'ريال';
  final List<String> _currencies = ['ريال', 'دولار'];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: isSmallScreen
            ? _buildMobileLayout()
            : _buildDesktopLayout(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'فاتورة جديدة',
        style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton.icon(
          onPressed: _clearForm,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(
            'إعادة تعيين',
            style: GoogleFonts.cairo(),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerSection(),
          const SizedBox(height: 24),
          _buildProductSearch(),
          const SizedBox(height: 16),
          _buildItemsList(),
          const SizedBox(height: 24),
          _buildPaymentSection(),
          const SizedBox(height: 24),
          _buildNotesSection(),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Products and Items
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductSearch(),
                const SizedBox(height: 16),
                _buildItemsList(),
              ],
            ),
          ),
        ),

        // Divider
        Container(
          width: 1,
          color: AppPalette.outline,
          margin: const EdgeInsets.symmetric(vertical: 24),
        ),

        // Right side - Customer, Payment, Summary
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerSection(),
                const SizedBox(height: 24),
                _buildPaymentSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildSummaryCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العميل',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: _customerSearchController,
          hint: 'البحث عن عميل أو إضافة جديد...',
          prefixIcon: const Icon(Icons.person_outline_rounded),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddCustomerDialog(),
          ),
          onChanged: (value) => _searchCustomer(value),
        ),
        if (_selectedCustomer != null) ...[
          const SizedBox(height: 12),
          _buildSelectedCustomerCard(),
        ],
      ],
    );
  }

  Widget _buildSelectedCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppPalette.primary,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محمد أحمد',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'دين: 1,250 ر.س',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppPalette.warning,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => setState(() => _selectedCustomer = null),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إضافة منتجات',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _productSearchController,
                hint: 'البحث بالاسم أو الباركود...',
                prefixIcon: _isSearchingProduct
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  onPressed: () => _scanBarcode(),
                ),
                onChanged: (value) => _searchProduct(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickProducts(),
      ],
    );
  }

  Widget _buildQuickProducts() {
    // Sample quick products
    final products = ['منتج 1', 'منتج 2', 'منتج 3'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: products.map((product) {
        return ActionChip(
          label: Text(product, style: GoogleFonts.cairo(fontSize: 12)),
          onPressed: () => _addQuickProduct(product),
          side: BorderSide(color: AppPalette.outline),
          backgroundColor: AppPalette.surface,
        );
      }).toList(),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return _buildEmptyItemsState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surfaceVariant,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('المنتج')),
                const Expanded(flex: 2, child: Text('السعر')),
                const Expanded(flex: 2, child: Text('الكمية')),
                const Expanded(flex: 2, child: Text('الإجمالي')),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Items
          ..._items.asMap().entries.map((entry) => _buildItemRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildEmptyItemsState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppPalette.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات في الفاتورة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابحث عن منتج أو امسح الباركود للإضافة',
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, InvoiceLineItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppPalette.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Product name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.barcode,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppPalette.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Text(
              '${item.unitPrice.toStringAsFixed(2)} ر.س',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ),

          // Quantity
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 18),
                  onPressed: () => _updateQuantity(index, item.quantity - 1),
                  style: IconButton.styleFrom(
                    backgroundColor: AppPalette.surfaceVariant,
                    minimumSize: const Size(28, 28),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.quantity.toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  onPressed: () => _updateQuantity(index, item.quantity + 1),
                  style: IconButton.styleFrom(
                    backgroundColor: AppPalette.primaryContainer,
                    foregroundColor: AppPalette.primary,
                    minimumSize: const Size(28, 28),
                  ),
                ),
              ],
            ),
          ),

          // Total
          Expanded(
            flex: 2,
            child: Text(
              '${item.total.toStringAsFixed(2)} ر.س',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppPalette.primary,
              ),
            ),
          ),

          // Remove button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _removeItem(index),
            color: AppPalette.expense,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الدفع',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                value: 'cash',
                label: 'نقدي',
                icon: Icons.payments_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentOption(
                value: 'credit',
                label: 'آجل',
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentOption(
                value: 'card',
                label: 'بطاقة',
                icon: Icons.credit_card_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppDropdownField<String>(
          label: 'العملة',
          value: _selectedCurrency,
          items: _currencies
              .map((c) => DropdownItem(value: c, label: c))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCurrency = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppPalette.primaryContainer : AppPalette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPalette.primary : AppPalette.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return AppTextField(
      label: 'ملاحظات',
      controller: _notesController,
      hint: 'أضف ملاحظات للفاتورة (اختياري)',
      maxLines: 3,
    );
  }

  Widget _buildSummaryCard() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.total);
    const discount = 0.0;
    final total = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الفاتورة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('المجموع الفرعي', subtotal),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('الخصم', discount, isDiscount: true),
          ],
          const Divider(height: 24),
          _buildSummaryRow('الإجمالي', total, isTotal: true),
          const SizedBox(height: 8),
          Text(
            '${_items.length} منتج في الفاتورة',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppPalette.income : AppPalette.textPrimary,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ر.س',
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount
                ? AppPalette.income
                : isTotal
                    ? AppPalette.primary
                    : AppPalette.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final subtotal = _items.fold<double>(0, (sum, item) => sum + item.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                  Text(
                    '${subtotal.toStringAsFixed(2)} $_selectedCurrency',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            AppSecondaryButton(
              text: 'حفظ مسودة',
              onPressed: _items.isEmpty ? null : () => _saveDraft(),
            ),
            const SizedBox(width: 12),
            AppPrimaryButton(
              text: 'إتمام الفاتورة',
              icon: Icons.check_rounded,
              onPressed: _items.isEmpty ? null : () => _completeInvoice(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _searchCustomer(String value) {
    // Implement customer search
  }

  void _searchProduct(String value) {
    setState(() => _isSearchingProduct = true);
    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSearchingProduct = false);
      }
    });
  }

  void _scanBarcode() {
    // Implement barcode scanning
  }

  void _addQuickProduct(String product) {
    setState(() {
      _items.add(InvoiceLineItem(
        productName: product,
        barcode: '123456789',
        unitPrice: 100.0,
        quantity: 1,
      ));
    });
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }
    setState(() {
      _items[index].quantity = newQuantity;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showAddCustomerDialog() {
    // Show add customer dialog
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _customerSearchController.clear();
    _productSearchController.clear();
    _notesController.clear();
    setState(() {
      _items.clear();
      _selectedCustomer = null;
      _paymentMethod = 'cash';
    });
  }

  void _saveDraft() {
    // Implement save draft
  }

  void _completeInvoice() {
    if (_formKey.currentState!.validate()) {
      // Implement complete invoice
    }
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _productSearchController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

/// Invoice Line Item Model
class InvoiceLineItem {
  final String productName;
  final String barcode;
  final double unitPrice;
  int quantity;

  InvoiceLineItem({
    required this.productName,
    required this.barcode,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;
}
