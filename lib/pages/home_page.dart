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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _isDesktop ? _buildDesktopAppBar(mainController) : _buildMobileAppBar(mainController),
        body: Column(
          children: [
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  _buildSideMenu(mainController),
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
                        _buildPlaceholderPage('الموردين'),
                        _buildPlaceholderPage('فواتير المبيعات/المرتجع'),
                        _buildPlaceholderPage('فواتير المشتريات/المرتجع'),
                        _buildPlaceholderPage('النفقات'),
                        _buildPlaceholderPage('التقارير'),
                        _buildPlaceholderPage('الملاحظات و التنبيهات'),
                        _buildPlaceholderPage('المستخدمين'),
                        _buildPlaceholderPage('الإعدادات'),
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

  PreferredSizeWidget _buildDesktopAppBar(MainController mainController) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
        child: Row(
          children: [
            Text(mainController.storeData.value?.name ?? ""),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: [
        IconButton(
          onPressed: () async {
            await windowManager.setMinimumSize(Size.zero);
            await windowManager.minimize();
          },
          icon: const Icon(Icons.minimize),
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
          icon: const Icon(Icons.crop_square, color: Colors.green),
        ),
        IconButton(
          onPressed: () => exit(0),
          icon: const Icon(Icons.close, color: Colors.red),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildMobileAppBar(MainController mainController) {
    return AppBar(
      centerTitle: true,
      title: Text(mainController.storeData.value?.name ?? ""),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  Widget _buildSideMenu(MainController mainController) {
    return SideMenu(
      mode: SideMenuMode.open,
      hasResizerToggle: false,
      hasResizer: false,
      builder: (data) => SideMenuData(
        header: Column(
          children: [
            if (mainController.storeData.value != null) ...[
              Center(child: Text(mainController.storeData.value!.branch)),
              const SizedBox(height: 10),
              Center(child: Text(mainController.storeData.value!.phone)),
              const SizedBox(height: 5),
              Center(child: Text(mainController.storeData.value!.address)),
              const SizedBox(height: 10),
            ],
            const Divider(height: 1),
            const SizedBox(height: 10),
          ],
        ),
        items: [
          _buildMenuItem(0, 'المستودع', 'assets/images/inventory.png'),
          _buildMenuItem(1, 'العملاء', 'assets/images/customers.png'),
          _buildMenuItem(2, 'البيع', 'assets/images/cart.png'),
          _buildMenuItemWithIcon(3, 'المرتجع', Icons.keyboard_return, Colors.orange),
          _buildMenuItemWithIcon(4, 'الديون', Icons.warning_amber_rounded, Colors.red),
          _buildMenuItem(5, 'الموردين', 'assets/images/supplier.png'),
          _buildMenuItem(6, 'فواتير المبيعات/المرتجع', 'assets/images/sales.png'),
          _buildMenuItem(7, 'فواتير المشتريات/المرتجع', 'assets/images/purchases.png'),
          _buildMenuItem(8, 'النفقات', 'assets/images/expenses.png'),
          _buildMenuItem(9, 'التقارير', 'assets/images/reports.png'),
          _buildMenuItem(10, 'الملاحظات و التنبيهات', 'assets/images/alarm.png'),
          _buildMenuItem(11, 'المستخدمين', 'assets/images/users.png'),
          _buildMenuItem(12, 'الإعدادات', 'assets/images/settings.png'),
        ],
      ),
    );
  }

  SideMenuItemDataTile _buildMenuItem(int index, String title, String iconPath) {
    return SideMenuItemDataTile(
      isSelected: selectedPage == index,
      title: title,
      onTap: () {
        pageController.jumpToPage(index);
        setState(() => selectedPage = index);
      },
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Image.asset(iconPath, width: 28, height: 28),
      ),
    );
  }

  SideMenuItemDataTile _buildMenuItemWithIcon(int index, String title, IconData icon, Color color) {
    return SideMenuItemDataTile(
      isSelected: selectedPage == index,
      title: title,
      onTap: () {
        pageController.jumpToPage(index);
        setState(() => selectedPage = index);
      },
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(title, style: const TextStyle(fontSize: 24)),
    );
  }
}
