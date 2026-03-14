import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';

import '../controllers/sale_controller.dart';
import '../../controllers/main_controller.dart';

/// Categories and Materials Selection Widget
///
/// Displays categories list and materials list side by side
class CategoriesMaterialsSection extends StatelessWidget {
  final MainController mainController;
  final SaleController controller;
  final bool isSmallScreen;
  final ScrollController categoriesScrollController;
  final ScrollController materialsScrollController;

  const CategoriesMaterialsSection({
    super.key,
    required this.mainController,
    required this.controller,
    required this.isSmallScreen,
    required this.categoriesScrollController,
    required this.materialsScrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoriesHeight = isSmallScreen ? 70.0 : 80.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 18, vertical: 6),
      child: SizedBox(
        height: categoriesHeight,
        child: Row(
          children: [
            Expanded(
              child: _buildCategoriesList(colorScheme),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 2,
              child: _buildMaterialsList(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ColorScheme colorScheme) {
    return Container(
      decoration: CustomWidgetsTheme.primaryCardDecoration(
        borderColor: colorScheme.primary.withOpacity(0.3),
      ),
      child: Obx(
        () => controller.loadingCategories.value
            ? _buildLoadingIndicator(colorScheme)
            : _buildCategoriesListView(),
      ),
    );
  }

  Widget _buildMaterialsList(ColorScheme colorScheme) {
    return Container(
      decoration: CustomWidgetsTheme.primaryCardDecoration(
        borderColor: colorScheme.primary.withOpacity(0.3),
      ),
      child: Obx(
        () => controller.loadingMaterials.value
            ? _buildLoadingIndicator(colorScheme)
            : _buildMaterialsListView(colorScheme),
      ),
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return Center(
      child: CircularProgressIndicator(color: colorScheme.primary),
    );
  }

  Widget _buildCategoriesListView() {
    return Scrollbar(
      controller: categoriesScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: categoriesScrollController,
        itemCount: controller.categories.value.length,
        itemBuilder: (context, index) => _buildCategoryItem(index),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final colorScheme = Get.theme.colorScheme;
    final isSelected = controller.selectedCategory.value == index;

    return GestureDetector(
      onTap: () => _handleCategoryTap(index),
      child: Container(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text(
            controller.categories.value[index],
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _handleCategoryTap(int index) {
    controller.selectedCategory.value = index;
    controller.getCategoryMaterials();
    controller.categories.refresh();
  }

  Widget _buildMaterialsListView(ColorScheme colorScheme) {
    return Scrollbar(
      controller: materialsScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: ListView.builder(
        controller: materialsScrollController,
        itemCount: controller.materials.value.length,
        itemBuilder: (context, index) => _buildMaterialItem(index, colorScheme),
      ),
    );
  }

  Widget _buildMaterialItem(int index, ColorScheme colorScheme) {
    final isSelected = controller.selectedMaterial.value == index;
    final material = controller.materials.value[index];

    return GestureDetector(
      onTap: () => _handleMaterialTap(index),
      onDoubleTap: () => _handleMaterialDoubleTap(index),
      child: Container(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -3),
          title: Text(
            '${material.barcode} : ${material.unit} :: ${material.name}',
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: isSmallScreen ? 10 : 12,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _handleMaterialTap(int index) {
    controller.selectedMaterial.value = index;
    controller.materials.refresh();
  }

  Future<void> _handleMaterialDoubleTap(int index) async {
    final material = controller.materials.value[index];
    final existingIndex = controller.dataSource.value.getMaterialIndex(material);

    if (existingIndex != -1) {
      showSaleMaterialDialog(mainController, controller, existingIndex);
    } else {
      if (material.quantity < 1) {
        showErrorDialog("لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
        return;
      }

      controller.selectedMaterial.value = index;
      controller.dataSource.value.addDataGridRow(material, controller);
      await AudioPlayer().play(AssetSource('sounds/scanner-beep.mp3'));
      controller.materials.refresh();
      controller.dataSource.refresh();
    }
  }
}
