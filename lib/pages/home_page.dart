import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/return/pages/return_page.dart';
import 'package:moamri_accounting/sale/pages/sale_page.dart';

import '../controllers/main_controller.dart';
import '../customers/pages/customers_page.dart';
import '../inventory/pages/inventory_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/custom_widgets_theme.dart';
import '../features/suppliers/suppliers_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';
import '../features/debts/debts_page.dart';
import '../features/expenses/expenses_page.dart';
import '../features/notifications/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Main pages for bottom navigation
  final List<_NavItem> _mainNavItems = [
    _NavItem(icon: Icons.inventory_2_rounded, label: 'المستودع', index: 0),
    _NavItem(icon: Icons.people_rounded, label: 'العملاء', index: 1),
    _NavItem(icon: Icons.point_of_sale_rounded, label: 'البيع', index: 2),
    _NavItem(icon: Icons.keyboard_return_rounded, label: 'المرتجع', index: 3),
    _NavItem(icon: Icons.more_horiz_rounded, label: 'المزيد', index: 4),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(mainController, theme),
        drawer: _buildDrawer(mainController, theme, isDark),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: [
            InventoryPage(),
            CustomersPage(),
            SalePage(),
            ReturnPage(),
            _buildMorePage(mainController, theme),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(theme),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MainController mainController, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_rounded, color: colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              mainController.storeData.value?.name ?? "محاسبي",
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      actions: [
        Obx(() => IconButton(
          onPressed: () => ThemeController.to.toggleTheme(),
          tooltip: ThemeController.to.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          icon: Icon(
            ThemeController.to.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colorScheme.primary,
          ),
        )),
      ],
    );
  }

  Widget _buildDrawer(MainController mainController, ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Drawer(
      width: screenWidth * 0.75,
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    mainController.storeData.value?.name ?? 'محاسبي',
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  if (mainController.storeData.value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      mainController.storeData.value!.branch,
                      style: TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.inventory_2_rounded,
                    label: 'المستودع',
                    index: 0,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_rounded,
                    label: 'العملاء',
                    index: 1,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.point_of_sale_rounded,
                    label: 'البيع',
                    index: 2,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.keyboard_return_rounded,
                    label: 'المرتجع',
                    index: 3,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.warning_amber_rounded,
                    label: 'الديون',
                    index: 4,
                    colorScheme: colorScheme,
                    color: AppColors.error,
                  ),
                  const Divider(height: 24),
                  _buildDrawerItem(
                    icon: Icons.local_shipping_rounded,
                    label: 'الموردين',
                    index: 5,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'فواتير المبيعات',
                    index: 6,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'فواتير المشتريات',
                    index: 7,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'النفقات',
                    index: 8,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_rounded,
                    label: 'التقارير',
                    index: 9,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    label: 'التنبيهات',
                    index: 10,
                    colorScheme: colorScheme,
                  ),
                  _buildDrawerItem(
                    icon: Icons.manage_accounts_rounded,
                    label: 'المستخدمين',
                    index: 11,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            
            // Settings at bottom
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: Icon(Icons.settings_rounded, color: colorScheme.onSurfaceVariant),
                title: Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(12);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
    Color? color,
  }) {
    final isSelected = _selectedIndex == index;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : (color ?? colorScheme.onSurfaceVariant),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'ReadexPro',
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        Navigator.pop(context);
        _navigateToPage(index);
      },
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _mainNavItems.map((item) {
              final isSelected = _selectedIndex == item.index;
              return _buildNavItem(item, isSelected, colorScheme);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isSelected, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => _navigateToPage(item.index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorePage(MainController mainController, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Debts Card
          _buildMenuCard(
            icon: Icons.warning_amber_rounded,
            title: 'الديون',
            subtitle: 'إدارة ديون العملاء والموردين',
            color: AppColors.error,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(4),
          ),
          const SizedBox(height: 12),
          
          // Suppliers
          _buildMenuCard(
            icon: Icons.local_shipping_rounded,
            title: 'الموردين',
            subtitle: 'إدارة بيانات الموردين',
            color: colorScheme.secondary,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(5),
          ),
          const SizedBox(height: 12),
          
          // Invoices
          _buildMenuCard(
            icon: Icons.receipt_long_rounded,
            title: 'فواتير المبيعات/المرتجع',
            subtitle: 'عرض وإدارة الفواتير',
            color: colorScheme.tertiary,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(6),
          ),
          const SizedBox(height: 12),
          
          // Purchases
          _buildMenuCard(
            icon: Icons.shopping_bag_rounded,
            title: 'فواتير المشتريات/المرتجع',
            subtitle: 'إدارة فواتير المشتريات',
            color: colorScheme.primary,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(7),
          ),
          const SizedBox(height: 12),
          
          // Expenses
          _buildMenuCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'النفقات',
            subtitle: 'تسجيل ومتابعة النفقات',
            color: AppColors.warning,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(8),
          ),
          const SizedBox(height: 12),
          
          // Reports
          _buildMenuCard(
            icon: Icons.analytics_rounded,
            title: 'التقارير',
            subtitle: 'تقارير وإحصائيات',
            color: AppColors.success,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(9),
          ),
          const SizedBox(height: 12),
          
          // Alerts
          _buildMenuCard(
            icon: Icons.notifications_rounded,
            title: 'التنبيهات',
            subtitle: 'الملاحظات والتذكيرات',
            color: colorScheme.secondary,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(10),
          ),
          const SizedBox(height: 12),
          
          // Users
          _buildMenuCard(
            icon: Icons.manage_accounts_rounded,
            title: 'المستخدمين',
            subtitle: 'إدارة صلاحيات المستخدمين',
            color: colorScheme.onSurfaceVariant,
            colorScheme: colorScheme,
            onTap: () => _navigateToPage(11),
          ),
          const SizedBox(height: 24),
          
          // Settings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: CustomWidgetsTheme.primaryCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => Row(
                  children: [
                    Icon(
                      ThemeController.to.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ThemeController.to.isDarkMode ? 'الوضع الداكن' : 'الوضع الفاتح',
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Switch(
                      value: ThemeController.to.isDarkMode,
                      onChanged: (value) => ThemeController.to.toggleTheme(),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'ReadexPro',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    // Pages 0-4 are in PageView
    if (index <= 4) {
      setState(() => _selectedIndex = index);
      _pageController.jumpToPage(index);
      return;
    }
    
    // Other pages navigate to separate screens
    Widget? page;
    switch (index) {
      case 5:
        page = const SuppliersPage();
        break;
      case 6:
        // Sales invoices - navigate to existing page
        page = const SalePage();
        break;
      case 7:
        // Purchase invoices - placeholder
        page = _buildPlaceholderPage('فواتير المشتريات');
        break;
      case 8:
        page = const ExpensesPage();
        break;
      case 9:
        page = const ReportsPage();
        break;
      case 10:
        page = const NotificationsPage();
        break;
      case 11:
        page = _buildPlaceholderPage('المستخدمين');
        break;
      case 12:
        page = const SettingsPage();
        break;
      default:
        setState(() => _selectedIndex = 4);
        _pageController.jumpToPage(4);
        return;
    }
    
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );
    }
  }
  
  Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'هذه الميزة قيد التطوير',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
