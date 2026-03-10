import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DebtsDataSource extends DataGridSource {
  final MainController mainController;
  List<Map<String, dynamic>> debts;
  List<DataGridRow> _debts = [];

  DebtsDataSource({
    required this.mainController,
    required this.debts,
  }) {
    _buildRows();
  }

  void _buildRows() {
    _debts = debts.map<DataGridRow>((debt) {
      double remainingAmount = (debt['remaining_amount'] ?? debt['amount']) as double;
      double totalAmount = debt['amount'] as double;
      bool isPaid = remainingAmount <= 0;

      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'ID', value: debt['id'] as int),
        DataGridCell<String>(
            columnName: 'Customer', value: debt['customer_name'] ?? 'غير محدد'),
        DataGridCell<String>(columnName: 'Phone', value: debt['customer_phone'] ?? ''),
        DataGridCell<String>(columnName: 'Date', value: GlobalUtils.getDate(debt['date'] as int)),
        DataGridCell<double>(columnName: 'TotalAmount', value: totalAmount),
        DataGridCell<double>(columnName: 'RemainingAmount', value: remainingAmount),
        DataGridCell<String>(columnName: 'Status', value: isPaid ? 'مسدد' : 'غير مسدد'),
        DataGridCell<String>(columnName: 'Note', value: debt['note'] ?? ''),
      ]);
    }).toList();
  }

  void updateDebts(List<Map<String, dynamic>> newDebts) {
    debts = newDebts;
    _buildRows();
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _debts;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    bool isPaid = row.getCells()[6].value.toString() == 'مسدد';
    double remainingAmount = row.getCells()[5].value as double;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: dataGridCell.columnName == 'Status'
            ? (isPaid ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))
            : null,
        child: Text(
          _formatCellValue(dataGridCell),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dataGridCell.columnName == 'RemainingAmount' && remainingAmount > 0
                ? Colors.red
                : null,
            fontWeight: dataGridCell.columnName == 'RemainingAmount' && remainingAmount > 0
                ? FontWeight.bold
                : null,
          ),
        ),
      );
    }).toList());
  }

  String _formatCellValue(DataGridCell cell) {
    if (cell.value == null) return '';

    switch (cell.columnName) {
      case 'TotalAmount':
      case 'RemainingAmount':
        return GlobalUtils.getMoney(cell.value as double);
      default:
        return cell.value.toString();
    }
  }
}
