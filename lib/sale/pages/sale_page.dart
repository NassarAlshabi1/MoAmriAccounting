import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';

import '../widgets/index.dart';

/// Sale Page
///
/// Main page for creating sales transactions.
/// This page has been refactored into smaller widgets for better
/// maintainability and readability.
///
/// Architecture:
/// - SearchSection: Handles material search
/// - CategoriesMaterialsSection: Shows categories and materials lists
/// - SaleDataGrid: Shows the sale items in a data grid
/// - BottomActionsSection: Contains total display and action buttons
class SalePage extends StatelessWidget {
  SalePage({super.key});

  final MainController mainController = Get.find();
  final SaleController controller = Get.put(SaleController());
  final categoriesScrollController = ScrollController();
  final materialsScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveHelper.getScreenType(context);
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Search Section
            SearchSection(
              mainController: mainController,
              controller: controller,
              isSmallScreen: isSmallScreen,
            ),

            // Categories and Materials Selection
            CategoriesMaterialsSection(
              mainController: mainController,
              controller: controller,
              isSmallScreen: isSmallScreen,
              categoriesScrollController: categoriesScrollController,
              materialsScrollController: materialsScrollController,
            ),

            // Data Grid
            Expanded(
              child: SaleDataGrid(
                mainController: mainController,
                controller: controller,
              ),
            ),
            const Divider(height: 1),

            // Bottom Actions
            BottomActionsSection(
              mainController: mainController,
              controller: controller,
              isSmallScreen: isSmallScreen,
            ),
          ],
        );
      },
    );
  }
}
