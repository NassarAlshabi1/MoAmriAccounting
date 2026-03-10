import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/debts/controllers/debts_controller.dart';
import 'package:moamri_accounting/debts/dialogs/debt_details_dialog.dart';
import 'package:moamri_accounting/debts/dialogs/pay_debt_dialog.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DebtsPage extends StatelessWidget {
  DebtsPage({super.key, this.customerId});

  final int? customerId;
  final MainController mainController = Get.find();

  @override
  Widget build(BuildContext context) {
    final DebtsController controller = Get.put(
      DebtsController(mainController: mainController, customerId: customerId),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 10),
              // Summary Cards
              FutureBuilder<double>(
                future: DebtsDatabase.getTotalDebtsAmount(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(height: 4),
                                const Text("إجمالي الديون المتبقية",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  "${GlobalUtils.getMoney(snapshot.data ?? 0)} ${mainController.storeData.value?.currency ?? ''}",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            const VerticalDivider(),
                            Column(
                              children: [
                                const Icon(Icons.people, color: Colors.blue),
                                const SizedBox(height: 4),
                                const Text("عدد الديون النشطة",
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  "${controller.debtsCount.value}",
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Filter and Sort Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text(controller.showOnlyActive.value
                                  ? "الديون النشطة فقط"
                                  : "جميع الديون"),
                              selected: controller.showOnlyActive.value,
                              onSelected: (value) {
                                controller.toggleActiveFilter();
                              },
                              selectedColor: Colors.green.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.refreshDebts(),
                      tooltip: "تحديث",
                      icon: const Icon(Icons.sync),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Data Grid
              Expanded(
                child: controller.isFirstLoadRunning.value
                    ? const Center(child: CircularProgressIndicator())
                    : SfDataGridTheme(
                        data: SfDataGridThemeData(headerColor: Colors.white),
                        child: Container(
                          color: Colors.black12,
                          child: SfDataGrid(
                            controller: controller.dataGridController,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            source: controller.dataSource.value!,
                            selectionMode: SelectionMode.single,
                            allowColumnsResizing: true,
                            columnResizeMode: ColumnResizeMode.onResizeEnd,
                            columns: [
                              GridColumn(
                                columnName: 'ID',
                                width: 80,
                                label: _buildHeaderCell('رقم'),
                              ),
                              GridColumn(
                                columnName: 'Customer',
                                width: 150,
                                label: _buildHeaderCell('العميل'),
                              ),
                              GridColumn(
                                columnName: 'Phone',
                                width: 120,
                                label: _buildHeaderCell('الجوال'),
                              ),
                              GridColumn(
                                columnName: 'Date',
                                width: 120,
                                label: _buildHeaderCell('التاريخ'),
                              ),
                              GridColumn(
                                columnName: 'TotalAmount',
                                width: 120,
                                label: _buildHeaderCell('المبلغ الأصلي'),
                              ),
                              GridColumn(
                                columnName: 'RemainingAmount',
                                width: 120,
                                label: _buildHeaderCell('المبلغ المتبقي'),
                              ),
                              GridColumn(
                                columnName: 'Status',
                                width: 100,
                                label: _buildHeaderCell('الحالة'),
                              ),
                              GridColumn(
                                columnName: 'Note',
                                width: 150,
                                label: _buildHeaderCell('ملاحظة'),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const Divider(),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedRow == null) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          int selectedIndex = controller.dataGridController.selectedIndex;
                          if (selectedIndex < 0 || selectedIndex >= controller.debts.length) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          var debtData = controller.debts[selectedIndex];
                          await showDebtDetailsDialog(mainController, debtData);
                          controller.refreshDebts();
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        icon: const Icon(Icons.visibility),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('تفاصيل'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedRow == null) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          int selectedIndex = controller.dataGridController.selectedIndex;
                          if (selectedIndex < 0 || selectedIndex >= controller.debts.length) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          var debtData = controller.debts[selectedIndex];
                          double remaining =
                              (debtData['remaining_amount'] ?? debtData['amount']) as double;
                          if (remaining <= 0) {
                            showErrorDialog("هذا الدين مسدد بالكامل");
                            return;
                          }
                          await showPayDebtDialog(mainController, debtData);
                          controller.refreshDebts();
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        icon: const Icon(Icons.payment),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('سداد'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedRow == null) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          int selectedIndex = controller.dataGridController.selectedIndex;
                          if (selectedIndex < 0 || selectedIndex >= controller.debts.length) {
                            showErrorDialog("يجب عليك اختيار دين");
                            return;
                          }
                          var debtData = controller.debts[selectedIndex];
                          double remaining =
                              (debtData['remaining_amount'] ?? debtData['amount']) as double;
                          if (remaining > 0) {
                            showErrorDialog("لا يمكن حذف دين غير مسدد بالكامل");
                            return;
                          }
                          if (!(await showConfirmationDialog(
                                  "هل أنت متأكد من حذف هذا الدين؟") ??
                              false)) {
                            return;
                          }
                          bool deleted = await DebtsDatabase.deleteDebt(
                              debtData['id'] as int,
                              mainController.currentUser.value!);
                          if (deleted) {
                            await showSuccessDialog("تم حذف الدين");
                            controller.refreshDebts();
                          } else {
                            showErrorDialog("فشل حذف الدين");
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        icon: const Icon(Icons.delete),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('حذف'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.center,
      child: Text(text, overflow: TextOverflow.ellipsis),
    );
  }
}
