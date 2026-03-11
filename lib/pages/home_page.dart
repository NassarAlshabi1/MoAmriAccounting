import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/debts/pages/debts_page.dart';
import 'package:moamri_accounting/return/pages/return_page.dart';
import 'package:moamri_accounting/sale/pages/sale_page.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/main_controller.dart';
import '../customers/pages/customers_page.dart';
import '../inventory/pages/inventory_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/custom_widgets_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int selectedPage = 0;

  bool get _isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      _initWindow();
    }
  }

  void _initWindow() {
    const WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
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
        appBar: _isDesktop ? _buildDesktopAppBar(mainController, theme) : _buildMobileAppBar(mainController, theme),
        body: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  _buildSideMenu(mainController, theme, isDark),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      pageSnapping: false,
                      controller: pageController,
                      children: [
                        InventoryPage(),
                        CustomersPage(),
                        SalePage(),
                        ReturnPage(),
                        DebtsPage(),
                        _buildPlaceholderPage('الموردين', theme),
                        _buildPlaceholderPage('فواتير المبيعات/المرتجع', theme),
                        _buildPlaceholderPage('فواتير المشتريات/المرتجع', theme),
                        _buildPlaceholderPage('النفقات', theme),
                        _buildPlaceholderPage('التقارير', theme),
                        _buildPlaceholderPage('الملاحظات و التنبيهات', theme),
                        _buildPlaceholderPage('المستخدمين', theme),
                        _buildSettingsPage(mainController, theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(MainController mainController, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
        child: Row(
          children: [
            Icon(Icons.store_rounded, color: colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              mainController.storeData.value?.name ?? "",
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      actions: [
        // Theme toggle button
        Obx(() => IconButton(
          onPressed: () {
            ThemeController.to.toggleTheme();
          },
          tooltip: ThemeController.to.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          icon: Icon(
            ThemeController.to.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colorScheme.primary,
          ),
        )),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () async {
            await windowManager.setMinimumSize(Size.zero);
            await windowManager.minimize();
          },
          icon: Icon(Icons.minimize_rounded, color: colorScheme.onSurfaceVariant),
          tooltip: 'تصغير',
        ),
        IconButton(
          onPressed: () async {
            if (await windowManager.isMaximized()) {
              await windowManager.unmaximize();
            } else {
              await windowManager.setMaximumSize(Size.infinite);
              windowManager.maximize();
            }
          },
          icon: Icon(Icons.crop_square_rounded, color: AppColors.success),
          tooltip: 'تكبير',
        ),
        IconButton(
          onPressed: () => exit(0),
          icon: Icon(Icons.close_rounded, color: colorScheme.error),
          tooltip: 'إغلاق',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PreferredSizeWidget _buildMobileAppBar(MainController mainController, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.store_rounded, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            mainController.storeData.value?.name ?? "",
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      actions: [
        Obx(() => IconButton(
          onPressed: () {
            ThemeController.to.toggleTheme();
          },
          tooltip: ThemeController.to.isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن',
          icon: Icon(
            ThemeController.to.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: colorScheme.primary,
          ),
        )),
      ],
    );
  }

  Widget _buildSideMenu(MainController mainController, ThemeData theme, bool isDark) {
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: 220,
      color: isDark ? AppColors.sidebarBackgroundDark : AppColors.sidebarBackground,
      child: SideMenu(
        mode: SideMenuMode.open,
        hasResizerToggle: false,
        hasResizer: false,
        builder: (data) => SideMenuData(
          header: Column(
            children: [
              if (mainController.storeData.value != null) ...[
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.storefront_rounded, color: colorScheme.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        mainController.storeData.value!.branch,
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mainController.storeData.value!.phone,
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mainController.storeData.value!.address,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'ReadexPro',
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 1),
              const SizedBox(height: 8),
            ],
          ),
          items: [
            _buildMenuItem(0, 'المستودع', 'assets/images/inventory.png', colorScheme),
            _buildMenuItem(1, 'العملاء', 'assets/images/customers.png', colorScheme),
            _buildMenuItem(2, 'البيع', 'assets/images/cart.png', colorScheme),
            _buildMenuItemWithIcon(3, 'المرتجع', Icons.keyboard_return_rounded, AppColors.warning, colorScheme),
            _buildMenuItemWithIcon(4, 'الديون', Icons.warning_amber_rounded, AppColors.error, colorScheme),
            _buildMenuItem(5, 'الموردين', 'assets/images/supplier.png', colorScheme),
            _buildMenuItem(6, 'فواتير المبيعات/المرتجع', 'assets/images/sales.png', colorScheme),
            _buildMenuItem(7, 'فواتير المشتريات/المرتجع', 'assets/images/purchases.png', colorScheme),
            _buildMenuItem(8, 'النفقات', 'assets/images/expenses.png', colorScheme),
            _buildMenuItem(9, 'التقارير', 'assets/images/reports.png', colorScheme),
            _buildMenuItem(10, 'الملاحظات و التنبيهات', 'assets/images/alarm.png', colorScheme),
            _buildMenuItem(11, 'المستخدمين', 'assets/images/users.png', colorScheme),
            _buildMenuItemWithIcon(12, 'الإعدادات', Icons.settings_rounded, colorScheme.onSurfaceVariant, colorScheme),
          ],
        ),
      ),
    );
  }

  SideMenuItemDataTile _buildMenuItem(int index, String title, String iconPath, ColorScheme colorScheme) {
    final isSelected = selectedPage == index;
    
    return SideMenuItemDataTile(
      isSelected: isSelected,
      title: title,
      onTap: () {
        pageController.jumpToPage(index);
        setState(() => selectedPage = index);
      },
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            iconPath,
            width: 22,
            height: 22,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      titleStyle: TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      selectedTitleStyle: TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      selectedDecoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  SideMenuItemDataTile _buildMenuItemWithIcon(int index, String title, IconData icon, Color iconColor, ColorScheme colorScheme) {
    final isSelected = selectedPage == index;
    
    return SideMenuItemDataTile(
      isSelected: isSelected,
      title: title,
      onTap: () {
        pageController.jumpToPage(index);
        setState(() => selectedPage = index);
      },
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? colorScheme.primary : iconColor,
          ),
        ),
      ),
      titleStyle: TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      selectedTitleStyle: TextStyle(
        fontFamily: 'ReadexPro',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      selectedDecoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.construction_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قيد التطوير...',
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(MainController mainController, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.settings_rounded, color: colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Theme Settings Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: CustomWidgetsTheme.primaryCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعدادات المظهر',
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
                        onChanged: (value) {
                          ThemeController.to.toggleTheme();
                        },
                      ),
                    ],
                  )),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Store Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: CustomWidgetsTheme.primaryCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات المتجر',
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (mainController.storeData.value != null) ...[
                    _buildInfoRow('الاسم', mainController.storeData.value!.name, colorScheme),
                    _buildInfoRow('الفرع', mainController.storeData.value!.branch, colorScheme),
                    _buildInfoRow('الهاتف', mainController.storeData.value!.phone, colorScheme),
                    _buildInfoRow('العنوان', mainController.storeData.value!.address, colorScheme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
