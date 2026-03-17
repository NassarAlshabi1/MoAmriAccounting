import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/shared/widgets/form_fields.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Inventory Page - Modern Inventory Management
///
/// Features:
/// - Summary cards for inventory stats
/// - Product search with filters
/// - Category tabs
/// - Product grid/list view
/// - Low stock alerts
/// - Add/Edit product dialogs
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isGridView = true;
  bool _isLoading = false;

  // Selected category
  int _selectedCategoryIndex = 0;

  // Sample data
  final List<String> _categories = [
    'الكل',
    'أجهزة كهربائية',
    'ملابس',
    'مواد غذائية',
    'أدوات مكتبية',
  ];

  final List<InventoryItem> _products = [
    InventoryItem(
      id: 1,
      name: 'لابتوب HP ProBook',
      barcode: '123456789',
      category: 'أجهزة كهربائية',
      quantity: 25,
      unit: 'قطعة',
      costPrice: 2500.00,
      salePrice: 3200.00,
      currency: 'ريال',
      minStock: 5,
    ),
    InventoryItem(
      id: 2,
      name: 'طابعة Canon LBP',
      barcode: '123456790',
      category: 'أجهزة كهربائية',
      quantity: 3,
      unit: 'قطعة',
      costPrice: 850.00,
      salePrice: 1100.00,
      currency: 'ريال',
      minStock: 10,
    ),
    InventoryItem(
      id: 3,
      name: 'ورق A4 (500 ورقة)',
      barcode: '123456791',
      category: 'أدوات مكتبية',
      quantity: 150,
      unit: 'رزمة',
      costPrice: 15.00,
      salePrice: 22.00,
      currency: 'ريال',
      minStock: 50,
    ),
    InventoryItem(
      id: 4,
      name: 'قميص قطني',
      barcode: '123456792',
      category: 'ملابس',
      quantity: 0,
      unit: 'قطعة',
      costPrice: 45.00,
      salePrice: 75.00,
      currency: 'ريال',
      minStock: 20,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
          _buildFilterBar(context, isSmallScreen),
        ],
        body: _buildBody(context, isSmallScreen),
      ),
      floatingActionButton: AppFAB(
        label: 'إضافة منتج',
        icon: Icons.add_rounded,
        onPressed: () => _showAddProductDialog(),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
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
                    'إدارة المخزون',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  // Stats summary
                  _buildQuickStats(),
                ],
              ),
              const SizedBox(height: 16),
              // Summary cards
              Row(
                children: [
                  Expanded(child: _buildSummaryCard(
                    'إجمالي المنتجات',
                    '${_products.length}',
                    AppPalette.primary,
                    Icons.inventory_2_rounded,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard(
                    'نفذ من المخزون',
                    '${_products.where((p) => p.quantity == 0).length}',
                    AppPalette.expense,
                    Icons.warning_rounded,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSummaryCard(
                    'مخزون منخفض',
                    '${_products.where((p) => p.quantity > 0 && p.quantity <= p.minStock).length}',
                    AppPalette.warning,
                    Icons.trending_down_rounded,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_money_rounded, color: AppPalette.primary, size: 20),
          const SizedBox(width: 4),
          Text(
            'قيمة المخزون: ${_calculateTotalValue().toStringAsFixed(0)} ر.س',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalValue() {
    return _products.fold<double>(0, (sum, item) => sum + (item.costPrice * item.quantity));
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppPalette.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, bool isSmallScreen) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterBarDelegate(
        searchController: _searchController,
        onSearchChanged: _onSearchChanged,
        isGridView: _isGridView,
        onViewChanged: (isGrid) => setState(() => _isGridView = isGrid),
        categories: _categories,
        selectedIndex: _selectedCategoryIndex,
        onCategoryChanged: (index) => setState(() => _selectedCategoryIndex = index),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isSmallScreen) {
    final filteredProducts = _getFilteredProducts();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView
        ? _buildGridView(filteredProducts, isSmallScreen)
        : _buildListView(filteredProducts);
  }

  List<InventoryItem> _getFilteredProducts() {
    var products = _products;
    final search = _searchController.text.toLowerCase();

    if (search.isNotEmpty) {
      products = products.where((p) =>
          p.name.toLowerCase().contains(search) ||
          p.barcode.contains(search)).toList();
    }

    if (_selectedCategoryIndex > 0) {
      products = products.where((p) =>
          p.category == _categories[_selectedCategoryIndex]).toList();
    }

    return products;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: AppPalette.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على + لإضافة منتج جديد',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<InventoryItem> products, bool isSmallScreen) {
    final crossAxisCount = isSmallScreen ? 2 : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(InventoryItem product) {
    final isLowStock = product.quantity > 0 && product.quantity <= product.minStock;
    final isOutOfStock = product.quantity == 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOutOfStock
                  ? AppPalette.expense.withOpacity(0.5)
                  : isLowStock
                      ? AppPalette.warning.withOpacity(0.5)
                      : AppPalette.outline.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with stock status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOutOfStock
                      ? AppPalette.expenseContainer
                      : isLowStock
                          ? AppPalette.warningContainer
                          : AppPalette.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOutOfStock)
                      Icon(Icons.error_rounded, color: AppPalette.expense, size: 18)
                    else if (isLowStock)
                      Icon(Icons.warning_rounded, color: AppPalette.warning, size: 18),
                  ],
                ),
              ),

              // Product details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.barcode,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: AppPalette.textHint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الكمية:',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppPalette.expenseContainer
                                : AppPalette.incomeContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${product.quantity} ${product.unit}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock ? AppPalette.expense : AppPalette.income,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'سعر الشراء:',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        Text(
                          '${product.costPrice.toStringAsFixed(0)} ر.س',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'سعر البيع:',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        Text(
                          '${product.salePrice.toStringAsFixed(0)} ر.س',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Actions
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppIconButton(
                      icon: Icons.edit_rounded,
                      size: 32,
                      onPressed: () => _showEditProductDialog(product),
                    ),
                    const SizedBox(width: 4),
                    AppIconButton(
                      icon: Icons.delete_rounded,
                      size: 32,
                      backgroundColor: AppPalette.expenseContainer,
                      foregroundColor: AppPalette.expense,
                      onPressed: () => _confirmDelete(product),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<InventoryItem> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductListTile(products[index]),
    );
  }

  Widget _buildProductListTile(InventoryItem product) {
    final isLowStock = product.quantity > 0 && product.quantity <= product.minStock;
    final isOutOfStock = product.quantity == 0;

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
            color: isOutOfStock
                ? AppPalette.expenseContainer
                : isLowStock
                    ? AppPalette.warningContainer
                    : AppPalette.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isOutOfStock
                ? Icons.error_rounded
                : isLowStock
                    ? Icons.warning_rounded
                    : Icons.inventory_2_rounded,
            color: isOutOfStock
                ? AppPalette.expense
                : isLowStock
                    ? AppPalette.warning
                    : AppPalette.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? AppPalette.expenseContainer
                    : AppPalette.incomeContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${product.quantity} ${product.unit}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOutOfStock ? AppPalette.expense : AppPalette.income,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              product.barcode,
              style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textHint),
            ),
            const SizedBox(width: 16),
            Text(
              'شراء: ${product.costPrice.toStringAsFixed(0)} | بيع: ${product.salePrice.toStringAsFixed(0)}',
              style: GoogleFonts.cairo(fontSize: 12, color: AppPalette.textSecondary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: Icons.edit_rounded,
              size: 36,
              onPressed: () => _showEditProductDialog(product),
            ),
            AppIconButton(
              icon: Icons.delete_rounded,
              size: 36,
              backgroundColor: AppPalette.expenseContainer,
              foregroundColor: AppPalette.expense,
              onPressed: () => _confirmDelete(product),
            ),
          ],
        ),
        onTap: () => _showProductDetails(product),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() {});
  }

  void _showAddProductDialog() {
    // Show add product dialog
  }

  void _showEditProductDialog(InventoryItem product) {
    // Show edit product dialog
  }

  void _showProductDetails(InventoryItem product) {
    // Show product details
  }

  void _confirmDelete(InventoryItem product) {
    // Show confirmation dialog
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

/// Filter Bar Delegate
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final bool isGridView;
  final Function(bool) onViewChanged;
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategoryChanged;

  _FilterBarDelegate({
    required this.searchController,
    required this.onSearchChanged,
    required this.isGridView,
    required this.onViewChanged,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPalette.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search and view toggle
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: searchController,
                  hint: 'البحث بالاسم أو الباركود...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppPalette.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.grid_view_rounded,
                          color: isGridView ? AppPalette.primary : AppPalette.textSecondary),
                      onPressed: () => onViewChanged(true),
                    ),
                    IconButton(
                      icon: Icon(Icons.view_list_rounded,
                          color: !isGridView ? AppPalette.primary : AppPalette.textSecondary),
                      onPressed: () => onViewChanged(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Category chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return FilterChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (_) => onCategoryChanged(index),
                  selectedColor: AppPalette.primaryContainer,
                  checkmarkColor: AppPalette.primary,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: isSelected ? AppPalette.primary : AppPalette.textSecondary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) {
    return isGridView != oldDelegate.isGridView || selectedIndex != oldDelegate.selectedIndex;
  }
}

/// Inventory Item Model
class InventoryItem {
  final int id;
  final String name;
  final String barcode;
  final String category;
  final int quantity;
  final String unit;
  final double costPrice;
  final double salePrice;
  final String currency;
  final int minStock;

  InventoryItem({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.currency,
    required this.minStock,
  });
}
