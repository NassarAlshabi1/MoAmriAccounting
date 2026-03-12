import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/dialogs/sale_material_dialog.dart';
import 'package:moamri_accounting/theme/app_colors.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/sale_controller.dart';
import '../dialogs/sale_dialog.dart';

class SalePage extends StatelessWidget {
  SalePage({super.key});
  final MainController mainController = Get.find();
  final SaleController controller = Get.put(SaleController());
  final categoriesScrollController = ScrollController();
  final materialsScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;
    final screenType = ResponsiveHelper.getScreenType(context);
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب الأبعاد بناءً على حجم الشاشة المتاح
        final double searchBarHeight = isSmallScreen ? 56 : 60;
        final double categoriesHeight = isSmallScreen ? 70 : 80;
        final double bottomAreaHeight = isSmallScreen ? 140 : 160;

        return Column(
          children: [
            // Search Section - ارتفاع مرن
            SizedBox(
              height: searchBarHeight,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 10),
                        child: TypeAheadField(
                          controller: controller.searchController,
                          emptyBuilder: (context) {
                            return SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  "لم يتم إيجاد المادة",
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (value) async {
                            var index = controller.dataSource.value.getMaterialIndex(value);
                            if (index == -1) {
                              if (value.quantity < 1) {
                                showErrorDialog("لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                                return;
                              }
                              controller.dataSource.value.addDataGridRow(value, controller);
                              await AudioPlayer().play(AssetSource('sounds/scanner-beep.mp3'));
                              controller.dataSource.refresh();
                            } else {
                              showSaleMaterialDialog(mainController, controller, index);
                            }
                          },
                          suggestionsCallback: (String pattern) async {
                            return await MyMaterialsDatabase.getMaterialsSuggestions(pattern, null);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(
                                '${suggestion.barcode}, ${suggestion.name}',
                                style: const TextStyle(fontFamily: 'ReadexPro'),
                              ),
                            );
                          },
                          builder: (context, controller2, focusNode) {
                            return TextField(
                              controller: controller.searchController,
                              focusNode: focusNode,
                              decoration: CustomWidgetsTheme.searchInputDecoration(
                                hintText: 'بحث عن المواد...',
                              ),
                              keyboardType: TextInputType.text,
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        controller.getCategories();
                      },
                      tooltip: "تحديث",
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.sync_rounded, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),

            // Barcode listener - ارتفاع ضئيل
            VisibilityDetector(
              onVisibilityChanged: (VisibilityInfo info) {
                controller.visible.value = info.visibleFraction > 0;
              },
              key: const Key('visible-detector-key'),
              child: BarcodeKeyboardListener(
                bufferDuration: const Duration(milliseconds: 200),
                onBarcodeScanned: (barcode) async {
                  if (!(controller.visible.value ?? false)) return;
                  MyMaterial? selectedMaterial = await MyMaterialsDatabase.getMaterialByBarcode(barcode);
                  if (selectedMaterial == null) {
                    showErrorDialog("لا يوجد مادة بهذا الباركود");
                    return;
                  }
                  if (selectedMaterial.quantity < 1) {
                    showErrorDialog("لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                    return;
                  }

                  var index = controller.dataSource.value.getMaterialIndex(selectedMaterial);
                  if (index == -1) {
                    controller.dataSource.value.addDataGridRow(selectedMaterial, controller);
                    controller.dataSource.refresh();
                  } else {
                    showSaleMaterialDialog(mainController, controller, index);
                  }
                },
                child: const SizedBox.shrink(),
              ),
            ),

            // Categories and Materials Selection - ارتفاع محسوب
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 18, vertical: 6),
              child: SizedBox(
                height: categoriesHeight,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: CustomWidgetsTheme.primaryCardDecoration(
                          borderColor: colorScheme.primary.withOpacity(0.3),
                        ),
                        child: Obx(
                          () => (controller.loadingCategories.value)
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Scrollbar(
                                  controller: categoriesScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: ListView.builder(
                                    controller: categoriesScrollController,
                                    itemBuilder: (context, index) {
                                      final isSelected = controller.selectedCategory.value == index;
                                      return GestureDetector(
                                        onTap: () {
                                          controller.selectedCategory.value = index;
                                          controller.getCategoryMaterials();
                                          controller.categories.refresh();
                                        },
                                        child: Container(
                                          color: isSelected
                                              ? colorScheme.primaryContainer
                                              : Colors.transparent,
                                          child: ListTile(
                                            dense: true,
                                            visualDensity: const VisualDensity(vertical: -3),
                                            title: Text(
                                              controller.categories.value[index],
                                              style: TextStyle(
                                                fontFamily: 'ReadexPro',
                                                fontSize: isSmallScreen ? 11 : 13,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: controller.categories.value.length,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: CustomWidgetsTheme.primaryCardDecoration(
                          borderColor: colorScheme.primary.withOpacity(0.3),
                        ),
                        child: Obx(
                          () => (controller.loadingMaterials.value)
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Scrollbar(
                                  controller: materialsScrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: ListView.builder(
                                    controller: materialsScrollController,
                                    itemBuilder: (context, index) {
                                      final isSelected = controller.selectedMaterial.value == index;
                                      return GestureDetector(
                                        onTap: () {
                                          controller.selectedMaterial.value = index;
                                          controller.materials.refresh();
                                        },
                                        onDoubleTap: () async {
                                          var index1 = controller.dataSource.value
                                              .getMaterialIndex(controller.materials.value[index]);
                                          if (index1 != -1) {
                                            showSaleMaterialDialog(mainController, controller, index1);
                                          } else {
                                            if (controller.materials.value[index].quantity < 1) {
                                              showErrorDialog("لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                                              return;
                                            }

                                            controller.selectedMaterial.value = index;
                                            controller.dataSource.value
                                                .addDataGridRow(controller.materials.value[index], controller);
                                            await AudioPlayer()
                                                .play(AssetSource('sounds/scanner-beep.mp3'));
                                            controller.materials.refresh();
                                            controller.dataSource.refresh();
                                          }
                                        },
                                        child: Container(
                                          color: isSelected
                                              ? colorScheme.primaryContainer
                                              : Colors.transparent,
                                          child: ListTile(
                                            dense: true,
                                            visualDensity: const VisualDensity(vertical: -3),
                                            title: Text(
                                              '${controller.materials.value[index].barcode} : ${controller.materials.value[index].unit} :: ${controller.materials.value[index].name}',
                                              style: TextStyle(
                                                fontFamily: 'ReadexPro',
                                                fontSize: isSmallScreen ? 10 : 12,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: controller.materials.value.length,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Data Grid - يأخذ المساحة المتبقية
            Expanded(
              child: Obx(
                () => SfDataGridTheme(
                  data: isDark
                      ? CustomWidgetsTheme.darkDataGridTheme
                      : CustomWidgetsTheme.lightDataGridTheme,
                  child: Container(
                    color: colorScheme.surfaceContainerLowest,
                    child: SfDataGrid(
                      controller: controller.dataGridController,
                      gridLinesVisibility: GridLinesVisibility.both,
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResizeEnd,
                      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                        controller.columnWidths.value[details.column.columnName] = details.width;
                        controller.columnWidths.refresh();
                        return true;
                      },
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      source: controller.dataSource.value,
                      isScrollbarAlwaysShown: true,
                      onCellTap: (details) {
                        if (details.rowColumnIndex.rowIndex < 1) return;
                        if ((details.rowColumnIndex.rowIndex - 1) != controller.dataGridController.selectedIndex) {
                          return;
                        }
                        showSaleMaterialDialog(mainController, controller, details.rowColumnIndex.rowIndex - 1);
                      },
                      selectionMode: SelectionMode.single,
                      frozenColumnsCount: 2,
                      columns: [
                        GridColumn(
                          columnName: 'Barcode',
                          width: controller.columnWidths.value['Barcode']!,
                          minimumWidth: 100,
                          label: _buildHeaderCell('الباركود', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Name',
                          width: controller.columnWidths.value['Name']!,
                          minimumWidth: 100,
                          label: _buildHeaderCell('الاسم', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Unit',
                          width: controller.columnWidths.value['Unit']!,
                          minimumWidth: 80,
                          label: _buildHeaderCell('الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Unit Price',
                          width: controller.columnWidths.value['Unit Price']!,
                          minimumWidth: 100,
                          label: _buildHeaderCell('سعر الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Quantity',
                          width: controller.columnWidths.value['Quantity']!,
                          minimumWidth: 80,
                          label: _buildHeaderCell('الكمية', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Total',
                          width: controller.columnWidths.value['Total']!,
                          minimumWidth: 100,
                          label: _buildHeaderCell('الإجمالي', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Note',
                          columnWidthMode: ColumnWidthMode.lastColumnFill,
                          minimumWidth: 100,
                          label: _buildHeaderCell('ملاحظة', colorScheme, isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // Bottom Actions - ارتفاع محسوب
            SizedBox(
              height: bottomAreaHeight,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                child: isSmallScreen
                    ? _buildSmallScreenBottomActions(
                        context, colorScheme, controller, mainController, isSmallScreen)
                    : _buildNormalBottomActions(
                        context, colorScheme, controller, mainController, isSmallScreen),
              ),
            ),
          ],
        );
      },
    );
  }

  /// بناء الإجراءات السفلية للشاشات الصغيرة
  Widget _buildSmallScreenBottomActions(
    BuildContext context,
    ColorScheme colorScheme,
    SaleController controller,
    MainController mainController,
    bool isSmallScreen,
  ) {
    return Column(
      children: [
        // صف الإجمالي
        SizedBox(
          height: 50,
          child: _buildTotalCard(colorScheme, controller, isSmallScreen),
        ),
        const SizedBox(height: 6),
        // صف الأزرار
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCompactButton(
                  icon: Icons.remove_shopping_cart_rounded,
                  label: 'إزالة',
                  style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                  onPressed: () async {
                    if (controller.dataGridController.selectedIndex >= 0) {
                      controller.dataSource.value.removeDataGridRow(
                          controller.dataGridController.selectedIndex, controller);
                      controller.dataSource.refresh();
                    } else {
                      showErrorDialog("يرجى إختيار المادة المراد إزالتها");
                    }
                  },
                ),
                const SizedBox(width: 6),
                _buildCompactButton(
                  icon: Icons.clear_all_rounded,
                  label: 'تفريغ',
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (!(await showConfirmationDialog("هل أنت متأكد من أنك تريد تفريغ قائمة البيع؟!") ?? false)) {
                      return;
                    }
                    controller.dataSource.value.clearDataGridRows(controller);
                    controller.dataSource.refresh();
                  },
                ),
                const SizedBox(width: 6),
                _buildCompactButton(
                  icon: Icons.shopping_bag_rounded,
                  label: 'بيع',
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.onSuccess,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    showSaleDialog(mainController, controller);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// بناء الإجراءات السفلية للشاشات العادية
  Widget _buildNormalBottomActions(
    BuildContext context,
    ColorScheme colorScheme,
    SaleController controller,
    MainController mainController,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        // بطاقة الإجمالي
        Expanded(
          flex: 2,
          child: _buildTotalCard(colorScheme, controller, isSmallScreen),
        ),
        const SizedBox(width: 10),
        // الأزرار
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (controller.dataGridController.selectedIndex >= 0) {
                          controller.dataSource.value.removeDataGridRow(
                              controller.dataGridController.selectedIndex, controller);
                          controller.dataSource.refresh();
                        } else {
                          showErrorDialog("يرجى إختيار المادة المراد إزالتها");
                        }
                      },
                      style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                      icon: const Icon(Icons.remove_shopping_cart_rounded, size: 18),
                      label: const FittedBox(
                        child: Text('إزالة المادة', style: TextStyle(fontFamily: 'ReadexPro')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!(await showConfirmationDialog("هل أنت متأكد من أنك تريد تفريغ قائمة البيع؟!") ?? false)) {
                          return;
                        }
                        controller.dataSource.value.clearDataGridRows(controller);
                        controller.dataSource.refresh();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.clear_all_rounded, size: 18),
                      label: const FittedBox(
                        child: Text('تفريغ القائمة', style: TextStyle(fontFamily: 'ReadexPro')),
                      ),
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () async {
                  showSaleDialog(mainController, controller);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onSuccess,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_rounded, size: 20),
                label: const FittedBox(
                  child: Text(
                    'بيع',
                    style: TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  /// بناء بطاقة الإجمالي
  Widget _buildTotalCard(ColorScheme colorScheme, SaleController controller, bool isSmallScreen) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.only(bottom: 8),
          decoration: CustomWidgetsTheme.primaryCardDecoration(
            borderColor: colorScheme.primary.withOpacity(0.5),
          ),
          child: Obx(() => Padding(
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
            child: SingleChildScrollView(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.totalString.value,
                    style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: isSmallScreen ? 12 : 14,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          )),
        ),
        Positioned(
          right: 16,
          top: 0,
          child: Container(
            padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
            color: colorScheme.surface,
            child: Text(
              'الإجمالي',
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء زر مضغوط
  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required ButtonStyle style,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontFamily: 'ReadexPro', fontSize: 12)),
    );
  }

  Widget _buildHeaderCell(String text, ColorScheme colorScheme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: 6),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: isSmallScreen ? 11 : 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
