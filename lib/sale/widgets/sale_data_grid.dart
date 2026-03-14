import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/sale/dialogs/sale_material_dialog.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../controllers/sale_controller.dart';
import '../../controllers/main_controller.dart';

/// Sale Data Grid Widget
///
/// Displays the list of materials in the current sale
class SaleDataGrid extends StatelessWidget {
  final MainController mainController;
  final SaleController controller;

  const SaleDataGrid({
    super.key,
    required this.mainController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = ThemeController.to.isDarkMode;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Obx(
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
            onColumnResizeUpdate: _handleColumnResize,
            headerGridLinesVisibility: GridLinesVisibility.both,
            source: controller.dataSource.value,
            isScrollbarAlwaysShown: true,
            onCellTap: (details) => _handleCellTap(details),
            selectionMode: SelectionMode.single,
            frozenColumnsCount: 2,
            columns: _buildColumns(colorScheme, isSmallScreen),
          ),
        ),
      ),
    );
  }

  bool _handleColumnResize(ColumnResizeUpdateDetails details) {
    controller.columnWidths.value[details.column.columnName] = details.width;
    controller.columnWidths.refresh();
    return true;
  }

  void _handleCellTap(DataGridCellTapDetails details) {
    if (details.rowColumnIndex.rowIndex < 1) return;
    if ((details.rowColumnIndex.rowIndex - 1) != controller.dataGridController.selectedIndex) {
      return;
    }
    showSaleMaterialDialog(mainController, controller, details.rowColumnIndex.rowIndex - 1);
  }

  List<GridColumn> _buildColumns(ColorScheme colorScheme, bool isSmallScreen) {
    return [
      _buildColumn('Barcode', 'الباركود', colorScheme, isSmallScreen, 100),
      _buildColumn('Name', 'الاسم', colorScheme, isSmallScreen, 100),
      _buildColumn('Unit', 'الوحدة', colorScheme, isSmallScreen, 80),
      _buildColumn('Unit Price', 'سعر الوحدة', colorScheme, isSmallScreen, 100),
      _buildColumn('Quantity', 'الكمية', colorScheme, isSmallScreen, 80),
      _buildColumn('Total', 'الإجمالي', colorScheme, isSmallScreen, 100),
      _buildNoteColumn(colorScheme, isSmallScreen),
    ];
  }

  GridColumn _buildColumn(
    String columnName,
    String label,
    ColorScheme colorScheme,
    bool isSmallScreen,
    double minWidth,
  ) {
    return GridColumn(
      columnName: columnName,
      width: controller.columnWidths.value[columnName]!,
      minimumWidth: minWidth,
      label: _buildHeaderCell(label, colorScheme, isSmallScreen),
    );
  }

  GridColumn _buildNoteColumn(ColorScheme colorScheme, bool isSmallScreen) {
    return GridColumn(
      columnName: 'Note',
      columnWidthMode: ColumnWidthMode.lastColumnFill,
      minimumWidth: 100,
      label: _buildHeaderCell('ملاحظة', colorScheme, isSmallScreen),
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
