import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/inventory/controllers/inventory_controller.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/inventory/dialogs/edit_material_dialog.dart';
import 'package:moamri_accounting/theme/app_colors.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/select_category_dialog.dart';
import '../../dialogs/sort_by_dialog.dart';
import '../dialogs/add_material_dialog.dart';
import '../../dialogs/print_dialogs.dart';
import '../dialogs/currencies_dialog.dart';
import '../print/print_materials.dart';

class InventoryPage extends StatelessWidget {
  InventoryPage({super.key});

  final MainController mainController = Get.find();
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // حساب الأبعاد بناءً على حجم الشاشة
          final double searchBarHeight = isSmallScreen ? 48 : 56;
          final double filterBarHeight = isSmallScreen ? 48 : 56;
          final double actionBarHeight = isSmallScreen ? 56 : 60;

          return Obx(() => Column(
            children: [
              SizedBox(height: isSmallScreen ? 6 : 10),

              // Search Row - ارتفاع محسوب
              SizedBox(
                height: searchBarHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: controller.searchController,
                          decoration: CustomWidgetsTheme.searchInputDecoration(
                            hintText: 'ابحث عن طريق اسم المادة أو الباركود',
                          ),
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              controller.firstLoad();
                            } else {
                              controller.search();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      // عدد المواد - استخدام Flexible لمنع overflow
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 100 : 140,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_rounded, size: isSmallScreen ? 16 : 18, color: colorScheme.primary),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'العدد: ${controller.materialsCount.value}',
                                    style: TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontSize: isSmallScreen ? 11 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      IconButton(
                        onPressed: () {
                          controller.firstLoad();
                        },
                        tooltip: "تحديث",
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.sync_rounded, color: colorScheme.primary, size: isSmallScreen ? 20 : 24),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 10),
              const Divider(height: 1),

              // Filter Buttons - ارتفاع محسوب
              SizedBox(
                height: filterBarHeight,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildFilterChip(
                                context: context,
                                icon: Icons.category_rounded,
                                label: 'الصنف: ${controller.categories.value[controller.selectedCategory.value]}',
                                colorScheme: colorScheme,
                                isSmallScreen: isSmallScreen,
                                onSelected: (bool selected) async {
                                  controller.selectedCategory.value =
                                      (await showCategoryDialog(
                                          controller.categories.value,
                                          controller.selectedCategory.value)) ??
                                          controller.selectedCategory.value;
                                  controller.firstLoad();
                                },
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 10),
                              _buildFilterChip(
                                context: context,
                                icon: Icons.sort_rounded,
                                label: 'ترتيب: ${controller.orderBy.value[controller.selectedOrderBy.value]} (${(controller.selectedOrderDir.value == 0) ? 'تصاعدياً' : 'تنازلياً'})',
                                colorScheme: colorScheme,
                                isSmallScreen: isSmallScreen,
                                onSelected: (bool selected) async {
                                  var result = await showSortByDialog(
                                      controller.orderBy.value,
                                      controller.selectedOrderBy.value,
                                      controller.selectedOrderDir.value);
                                  if (result == null) return;
                                  controller.selectedOrderBy.value = result[0];
                                  controller.selectedOrderDir.value = result[1];
                                  controller.firstLoad();
                                },
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 10),
                              _buildFilterChip(
                                context: context,
                                icon: Icons.money_rounded,
                                label: 'العملات',
                                colorScheme: colorScheme,
                                isSmallScreen: isSmallScreen,
                                onSelected: (bool selected) async {
                                  var refresh = await showCurrenciesDialog(mainController);
                                  if (refresh) {
                                    controller.firstLoad();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Data Grid - يأخذ المساحة المتبقية
              Expanded(
                child: controller.isFirstLoadRunning.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تحميل البيانات...',
                              style: TextStyle(
                                fontFamily: 'ReadexPro',
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SfDataGridTheme(
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
                            loadMoreViewBuilder: (BuildContext context, LoadMoreRows loadMoreRows) {
                              Future<String> loadRows() async {
                                await loadMoreRows();
                                return Future<String>.value('Completed');
                              }

                              return FutureBuilder<String>(
                                initialData: controller.hasNextPage.value ? 'Loading' : 'Completed',
                                future: loadRows(),
                                builder: (context, snapShot) {
                                  return snapShot.data == 'Loading'
                                      ? Container(
                                          height: 60.0,
                                          alignment: Alignment.center,
                                          width: double.infinity,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: colorScheme.primary,
                                              backgroundColor: colorScheme.surfaceContainerHighest,
                                            ),
                                          ))
                                      : SizedBox.fromSize(size: Size.zero);
                                },
                              );
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
                                columnName: 'Category',
                                width: controller.columnWidths.value['Category']!,
                                minimumWidth: 80,
                                label: _buildHeaderCell('الصنف', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Quantity',
                                width: controller.columnWidths.value['Quantity']!,
                                minimumWidth: 80,
                                label: _buildHeaderCell('الكمية', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Unit',
                                width: controller.columnWidths.value['Unit']!,
                                minimumWidth: 60,
                                label: _buildHeaderCell('الوحدة', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Cost Price',
                                width: controller.columnWidths.value['Cost Price']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('سعر الشراء', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Sale Price',
                                width: controller.columnWidths.value['Sale Price']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('سعر البيع', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Note',
                                width: controller.columnWidths.value['Note']!,
                                minimumWidth: 100,
                                columnWidthMode: ColumnWidthMode.lastColumnFill,
                                label: _buildHeaderCell('ملاحظات', colorScheme, isSmallScreen),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const Divider(height: 1),

              // Action Buttons - ارتفاع محسوب
              SizedBox(
                height: actionBarHeight,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.add_rounded,
                          label: 'إضافة',
                          style: CustomWidgetsTheme.primaryButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          onPressed: () async {
                            if ((await showAddMaterialDialog(mainController)) ?? false) {
                              controller.firstLoad();
                            }
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          label: 'تعديل',
                          style: CustomWidgetsTheme.primaryOutlinedButtonStyle(
                            foregroundColor: AppColors.success,
                          ),
                          isSmallScreen: isSmallScreen,
                          onPressed: () async {
                            if (controller.dataGridController.selectedIndex < 0) {
                              showErrorDialog("يجب عليك إختيار مادة");
                              return;
                            }
                            if ((await showEditMaterialDialog(
                                    mainController,
                                    controller.materials.value[controller.dataGridController.selectedIndex])) ??
                                false) {
                              controller.firstLoad();
                            }
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          label: 'حذف',
                          style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          onPressed: () async {
                            if (controller.dataGridController.selectedIndex < 0) {
                              showErrorDialog("يجب عليك إختيار مادة");
                              return;
                            }
                            var material = controller.materials.value[controller.dataGridController.selectedIndex];
                            if (!(await MyMaterialsDatabase.isMaterialDeletable(material.id!))) {
                              showErrorDialog("لا يمكن حذف المادة لأنها مستخدمة مع بعض البيانات الأخرى");
                              return;
                            }

                            if (!(await showConfirmationDialog("هل أنت متأكد من أنك تريد الحذف؟") ?? false)) {
                              return;
                            }
                            await MyMaterialsDatabase.deleteMaterial(material, mainController.currentUser.value!);
                            await showSuccessDialog("تم حذف المادة");
                            controller.firstLoad();
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.print_rounded,
                          label: 'طباعة',
                          style: CustomWidgetsTheme.neutralOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          onPressed: () async {
                            var printType = await showPrintDialog("المواد");
                            if (printType == null) return;
                            if (printType == "حراري") {
                              await printMaterialsRoll(mainController, controller);
                            } else {
                              await printMaterialsA4(mainController, controller);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
        },
      ),
    );
  }

  /// بناء FilterChip متجاوب
  Widget _buildFilterChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required bool isSmallScreen,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: isSmallScreen ? 16 : 18),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: isSmallScreen ? 11 : 13,
          ),
        ),
      ),
      selected: true,
      onSelected: onSelected,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      visualDensity: isSmallScreen ? VisualDensity.compact : null,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required ButtonStyle style,
    required bool isSmallScreen,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: isSmallScreen ? 18 : 20),
      label: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: isSmallScreen ? 11 : 13,
          ),
        ),
      ),
    );
  }
}
