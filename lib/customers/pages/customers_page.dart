import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/customers/controllers/customers_controller.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/theme/app_colors.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/sort_by_dialog.dart';
import '../dialogs/add_customer_dialog.dart';
import '../dialogs/edit_customer_dialog.dart';

class CustomersPage extends StatelessWidget {
  CustomersPage({super.key});

  final MainController mainController = Get.find();
  final CustomersController controller = Get.put(CustomersController());

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
                            hintText: 'بحث بالاسم',
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
                      // عدد العملاء - استخدام Flexible لمنع overflow
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 90 : 120,
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
                              Icon(Icons.people_rounded, size: isSmallScreen ? 16 : 18, color: colorScheme.primary),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'العدد: ${controller.customersCount.value}',
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
                              FilterChip(
                                avatar: Icon(Icons.sort_rounded, size: isSmallScreen ? 16 : 18),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'ترتيب: ${controller.orderBy.value[controller.selectedOrderBy.value]} (${(controller.selectedOrderDir.value == 0) ? 'تصاعدياً' : 'تنازلياً'})',
                                    style: TextStyle(
                                      fontFamily: 'ReadexPro',
                                      fontSize: isSmallScreen ? 11 : 13,
                                    ),
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
                                visualDensity: isSmallScreen ? VisualDensity.compact : null,
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
                                columnName: 'ID',
                                width: controller.columnWidths.value['ID']!,
                                minimumWidth: 80,
                                label: _buildHeaderCell('المعرف', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Name',
                                width: controller.columnWidths.value['Name']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('الاسم', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Debt',
                                width: controller.columnWidths.value['Debt']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('إجمالي الدين', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Phone',
                                width: controller.columnWidths.value['Phone']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('الجوال', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Address',
                                width: controller.columnWidths.value['Address']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('العنوان', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Description',
                                columnWidthMode: ColumnWidthMode.lastColumnFill,
                                width: controller.columnWidths.value['Description']!,
                                minimumWidth: 100,
                                label: _buildHeaderCell('الوصف', colorScheme, isSmallScreen),
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
                          icon: Icons.add,
                          label: 'إضافة',
                          style: CustomWidgetsTheme.primaryButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
                          onPressed: () async {
                            if ((await showAddCustomerDialog(mainController) != null)) {
                              controller.firstLoad();
                            }
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.edit,
                          label: 'تعديل',
                          style: CustomWidgetsTheme.primaryOutlinedButtonStyle(
                            foregroundColor: AppColors.success,
                          ),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
                          onPressed: () async {
                            if (controller.dataGridController.selectedIndex < 0) {
                              showErrorDialog("يجب عليك إختيار عميل");
                              return;
                            }
                            if ((await showEditCustomerDialog(
                                    mainController,
                                    controller
                                        .customersWithDebts
                                        .value[controller.dataGridController.selectedIndex]
                                        .customer)) ??
                                false) {
                              controller.firstLoad();
                            }
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.delete,
                          label: 'حذف',
                          style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
                          onPressed: () async {
                            if (controller.dataGridController.selectedIndex < 0) {
                              showErrorDialog("يجب عليك إختيار عميل");
                              return;
                            }
                            var customer = controller.customersWithDebts.value[
                                controller.dataGridController.selectedIndex];
                            if (!(await CustomersDatabase.isCustomerDeletable(
                                customer.customer.id!))) {
                              showErrorDialog(
                                  "لا يمكن حذف هذا العميل لأنه لايزال لديه بعض الديون");
                              return;
                            }

                            if (!(await showConfirmationDialog("هل أنت متأكد من الحذف؟!") ??
                                false)) {
                              return;
                            }
                            await CustomersDatabase.deleteCustomer(
                                customer.customer,
                                mainController.currentUser.value!);
                            await showSuccessDialog("تم حذف العميل");
                            controller.firstLoad();
                          },
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.print,
                          label: 'طباعة',
                          style: CustomWidgetsTheme.neutralOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
                          onPressed: () async {
                            // وظيفة الطباعة
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
    required ColorScheme colorScheme,
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
