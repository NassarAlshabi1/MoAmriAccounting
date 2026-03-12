import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/invoices_database.dart';
import '../../dialogs/alerts_dialogs.dart';
import '../controllers/return_controller.dart';
import '../dialogs/return_dialog.dart';
import '../dialogs/return_material_dialog.dart';

class ReturnPage extends StatelessWidget {
  ReturnPage({super.key});
  final MainController mainController = Get.find();
  final ReturnController controller = Get.put(ReturnController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب الأبعاد بناءً على حجم الشاشة
        final double searchBarHeight = isSmallScreen ? 48 : 56;
        final double dividerHeight = isSmallScreen ? 28 : 32;
        final double actionButtonsHeight = isSmallScreen ? 56 : 60;

        return Column(
          children: [
            // Search Section
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
                          controller: controller.billIDController,
                          emptyBuilder: (context) {
                            if (controller.billIDController.text.isEmpty) {
                              return const SizedBox(height: 0);
                            }
                            return SizedBox(
                              height: 60,
                              child: Center(
                                child: Text(
                                  "لم يتم إيجاد الفاتورة",
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (value) async {
                            controller.invoiceItem.value = value;
                            await AudioPlayer().play(AssetSource('sounds/scanner-beep.mp3'));
                            controller.setBillDataSource();
                            controller.billIDController.clear();
                          },
                          suggestionsCallback: (String pattern) async {
                            return await InvoicesDatabase.getInvoicesSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(
                                'رقم الفاتورة: ${suggestion.invoice.id!}: التأريخ:${GlobalUtils.dateFormat.format(DateTime.fromMillisecondsSinceEpoch(suggestion.invoice.date))} ${(suggestion.customer == null) ? '' : ',العميل ${suggestion.customer!.name}'}',
                                style: const TextStyle(fontFamily: 'ReadexPro', fontSize: 12),
                              ),
                            );
                          },
                          builder: (context, controller2, focusNode) {
                            return TextField(
                              controller: controller.billIDController,
                              focusNode: focusNode,
                              decoration: CustomWidgetsTheme.searchInputDecoration(
                                hintText: 'أدخل رقم الفاتورة',
                              ),
                              keyboardType: TextInputType.text,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),

            // Bill Items Section Header
            _buildSectionDivider('عناصر الفاتورة', colorScheme, dividerHeight),

            // Bill Items DataGrid - يأخذ نصف المساحة المتبقية
            Expanded(
              child: Obx(
                () => SfDataGridTheme(
                  data: isDark
                      ? CustomWidgetsTheme.darkDataGridTheme
                      : CustomWidgetsTheme.lightDataGridTheme,
                  child: Container(
                    color: colorScheme.surfaceContainerLowest,
                    child: SfDataGrid(
                      controller: controller.billDataGridController,
                      gridLinesVisibility: GridLinesVisibility.both,
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResizeEnd,
                      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                        controller.columnWidths.value[details.column.columnName] = details.width;
                        controller.columnWidths.refresh();
                        return true;
                      },
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      source: controller.billDataSource.value,
                      isScrollbarAlwaysShown: true,
                      onCellTap: (details) {
                        if (details.rowColumnIndex.rowIndex < 1) return;
                        if ((details.rowColumnIndex.rowIndex - 1) != controller.billDataGridController.selectedIndex) {
                          return;
                        }
                        showReturnMaterialDialog(
                          mainController,
                          controller,
                          details.rowColumnIndex.rowIndex - 1,
                          controller.billDataSource.value.salesData[details.rowColumnIndex.rowIndex - 1]['Material'],
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
                          columnName: 'Unit',
                          width: controller.columnWidths.value['Unit']!,
                          minimumWidth: 60,
                          label: _buildHeaderCell('الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Unit Price',
                          width: controller.columnWidths.value['Unit Price']!,
                          minimumWidth: 90,
                          label: _buildHeaderCell('سعر الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Quantity',
                          width: controller.columnWidths.value['Quantity']!,
                          minimumWidth: 70,
                          label: _buildHeaderCell('الكمية', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Total',
                          width: controller.columnWidths.value['Total']!,
                          minimumWidth: 90,
                          label: _buildHeaderCell('الإجمالي', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Note',
                          columnWidthMode: ColumnWidthMode.lastColumnFill,
                          minimumWidth: 80,
                          label: _buildHeaderCell('ملاحظة', colorScheme, isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Returned Items Section Header
            _buildSectionDivider('العناصر المرتجعة', colorScheme, dividerHeight),

            // Returned Items DataGrid - يأخذ النصف الآخر
            Expanded(
              child: Obx(
                () => SfDataGridTheme(
                  data: isDark
                      ? CustomWidgetsTheme.darkDataGridTheme
                      : CustomWidgetsTheme.lightDataGridTheme,
                  child: Container(
                    color: colorScheme.surfaceContainerLowest,
                    child: SfDataGrid(
                      controller: controller.returnedDataGridController,
                      gridLinesVisibility: GridLinesVisibility.both,
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResizeEnd,
                      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                        controller.columnWidths.value[details.column.columnName] = details.width;
                        controller.columnWidths.refresh();
                        return true;
                      },
                      headerGridLinesVisibility: GridLinesVisibility.both,
                      source: controller.returnedDataSource.value,
                      isScrollbarAlwaysShown: true,
                      onCellTap: (details) {
                        if (details.rowColumnIndex.rowIndex < 1) return;
                        if ((details.rowColumnIndex.rowIndex - 1) != controller.returnedDataGridController.selectedIndex) {
                          return;
                        }
                        showReturnMaterialDialog(
                          mainController,
                          controller,
                          details.rowColumnIndex.rowIndex - 1,
                          controller.returnedDataSource.value.returnsData[details.rowColumnIndex.rowIndex - 1]['Material'],
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
                          columnName: 'Unit',
                          width: controller.columnWidths.value['Unit']!,
                          minimumWidth: 60,
                          label: _buildHeaderCell('الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Unit Price',
                          width: controller.columnWidths.value['Unit Price']!,
                          minimumWidth: 90,
                          label: _buildHeaderCell('سعر الوحدة', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Quantity',
                          width: controller.columnWidths.value['Quantity']!,
                          minimumWidth: 70,
                          label: _buildHeaderCell('الكمية', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Total',
                          width: controller.columnWidths.value['Total']!,
                          minimumWidth: 90,
                          label: _buildHeaderCell('الإجمالي', colorScheme, isSmallScreen),
                        ),
                        GridColumn(
                          columnName: 'Note',
                          columnWidthMode: ColumnWidthMode.lastColumnFill,
                          minimumWidth: 80,
                          label: _buildHeaderCell('ملاحظة', colorScheme, isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Action Buttons
            SizedBox(
              height: actionButtonsHeight,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.returnedDataGridController.selectedIndex >= 0) {
                            controller.returnedDataSource.value.removeDataGridRow(
                              controller.returnedDataGridController.selectedIndex,
                              controller,
                            );
                            controller.returnedDataSource.refresh();
                          } else {
                            showErrorDialog("يرجى إختيار المادة المراد إزالتها");
                          }
                        },
                        style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                        icon: Icon(Icons.clear_rounded, size: isSmallScreen ? 16 : 20),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'إزالة المادة',
                            style: TextStyle(fontFamily: 'ReadexPro', fontSize: isSmallScreen ? 11 : 13),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (!(await showConfirmationDialog("هل أنت متأكد من أنك تريد تفريغ العناصر؟!") ?? false)) {
                            return;
                          }
                          controller.billDataSource.value.clearDataGridRows(controller);
                          controller.billDataSource.refresh();
                          controller.returnedDataSource.value.clearDataGridRows(controller);
                          controller.returnedDataSource.refresh();
                          controller.invoiceItem.value = null;
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.clear_all_rounded, size: isSmallScreen ? 16 : 20),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'تفريغ العناصر',
                            style: TextStyle(fontFamily: 'ReadexPro', fontSize: isSmallScreen ? 11 : 13),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          if (controller.invoiceItem.value == null) {
                            showErrorDialog('يرجى أختيار فاتورة');
                            return;
                          }
                          if (controller.returnedDataSource.value.returnsData.isEmpty) {
                            showErrorDialog('يرجى أختيار الأشياء المراد إرجاعها');
                            return;
                          }
                          showReturnDialog(mainController, controller);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.keyboard_return_rounded, size: isSmallScreen ? 16 : 20),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'إرجاع',
                            style: TextStyle(fontFamily: 'ReadexPro', fontSize: isSmallScreen ? 11 : 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionDivider(String text, ColorScheme colorScheme, double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: colorScheme.outlineVariant)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Divider(height: 1, color: colorScheme.outlineVariant)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, ColorScheme colorScheme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: 4),
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
