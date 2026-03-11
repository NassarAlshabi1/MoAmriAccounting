import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/inventory/controllers/inventory_controller.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/inventory/dialogs/edit_material_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/select_category_dialog.dart';
import '../../dialogs/sort_by_dialog.dart';
import '../dialogs/add_material_dialog.dart';
import '../../dialogs/print_dialogs.dart';
import '../dialogs/currencies_dialog.dart';
import '../print/print_materials.dart';
import '../theme/app_colors.dart';
import '../theme/custom_widgets_theme.dart';
import '../theme/app_theme.dart';

class InventoryPage extends StatelessWidget {
  InventoryPage({super.key});

  final MainController mainController = Get.find();
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 10),
              // Search Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_rounded, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'العدد: ${controller.materialsCount.value}',
                            style: TextStyle(
                              fontFamily: 'ReadexPro',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      icon: Icon(Icons.sync_rounded, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              // Filter Buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FilterChip(
                              avatar: const Icon(Icons.category_rounded, size: 18),
                              label: Text(
                                'الصنف: ${controller.categories.value[controller.selectedCategory.value]}',
                                style: const TextStyle(
                                  fontFamily: 'ReadexPro',
                                  fontSize: 13,
                                ),
                              ),
                              selected: true,
                              onSelected: (bool selected) async {
                                controller.selectedCategory.value =
                                    (await showCategoryDialog(
                                        controller.categories.value,
                                        controller.selectedCategory.value)) ??
                                    controller.selectedCategory.value;
                                controller.firstLoad();
                              },
                              selectedColor: colorScheme.primaryContainer,
                              checkmarkColor: colorScheme.primary,
                              backgroundColor: colorScheme.surface,
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilterChip(
                              avatar: const Icon(Icons.sort_rounded, size: 18),
                              label: Text(
                                'ترتيب: ${controller.orderBy.value[controller.selectedOrderBy.value]} (${(controller.selectedOrderDir.value == 0) ? 'تصاعدياً' : 'تنازلياً'})',
                                style: const TextStyle(
                                  fontFamily: 'ReadexPro',
                                  fontSize: 13,
                                ),
                              ),
                              selected: true,
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
                              selectedColor: colorScheme.primaryContainer,
                              checkmarkColor: colorScheme.primary,
                              backgroundColor: colorScheme.surface,
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FilterChip(
                              avatar: const Icon(Icons.money_rounded, size: 18),
                              label: const Text(
                                'العملات',
                                style: TextStyle(
                                  fontFamily: 'ReadexPro',
                                  fontSize: 13,
                                ),
                              ),
                              selected: false,
                              onSelected: (bool selected) async {
                                var refresh = await showCurrenciesDialog(mainController);
                                if (refresh) {
                                  controller.firstLoad();
                                }
                              },
                              selectedColor: colorScheme.primaryContainer,
                              checkmarkColor: colorScheme.primary,
                              backgroundColor: colorScheme.surface,
                              side: BorderSide(color: colorScheme.outline),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Data Grid
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
                                              backgroundColor: colorScheme.surfaceVariant,
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
                                minimumWidth: 120,
                                label: _buildHeaderCell('الباركود', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Name',
                                width: controller.columnWidths.value['Name']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('الاسم', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Category',
                                width: controller.columnWidths.value['Category']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('الصنف', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Quantity',
                                width: controller.columnWidths.value['Quantity']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('الكمية', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Unit',
                                width: controller.columnWidths.value['Unit']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('الوحدة', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Cost Price',
                                width: controller.columnWidths.value['Cost Price']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('سعر الشراء', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Sale Price',
                                width: controller.columnWidths.value['Sale Price']!,
                                minimumWidth: 120,
                                label: _buildHeaderCell('سعر البيع', colorScheme),
                              ),
                              GridColumn(
                                columnName: 'Note',
                                width: controller.columnWidths.value['Note']!,
                                minimumWidth: 120,
                                columnWidthMode: ColumnWidthMode.lastColumnFill,
                                label: _buildHeaderCell('ملاحظات', colorScheme),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const Divider(height: 1),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.add_rounded,
                        label: 'إضافة',
                        style: CustomWidgetsTheme.primaryButtonStyle(),
                        onPressed: () async {
                          if ((await showAddMaterialDialog(mainController)) ?? false) {
                            controller.firstLoad();
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        label: 'تعديل',
                        style: CustomWidgetsTheme.primaryOutlinedButtonStyle(
                          foregroundColor: AppColors.success,
                        ),
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
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.delete_rounded,
                        label: 'حذف',
                        style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
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
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.print_rounded,
                        label: 'طباعة',
                        style: CustomWidgetsTheme.neutralOutlinedButtonStyle(),
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
            ],
          )),
    );
  }

  Widget _buildHeaderCell(String text, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'ReadexPro',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required ButtonStyle style,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 20),
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
