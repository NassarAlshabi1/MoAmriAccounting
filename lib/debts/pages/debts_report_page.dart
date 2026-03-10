import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/utils/global_utils.dart';

class DebtsReportPage extends StatelessWidget {
  DebtsReportPage({super.key});

  final MainController mainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "تقرير الديون",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Summary Cards
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DebtsDatabase.getDebtsSummaryByCustomer(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Map<String, dynamic>> summary = snapshot.data ?? [];
                  double totalDebts = 0;
                  double totalRemaining = 0;
                  int customersWithDebt = 0;

                  for (var item in summary) {
                    totalDebts += (item['total_debt'] ?? 0) as double;
                    totalRemaining += (item['remaining_amount'] ?? 0) as double;
                    if ((item['remaining_amount'] ?? 0) > 0) {
                      customersWithDebt++;
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              "إجمالي الديون",
                              GlobalUtils.getMoney(totalDebts),
                              mainController.storeData.value?.currency ?? '',
                              Colors.blue,
                              Icons.account_balance_wallet,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              "إجمالي المتبقي",
                              GlobalUtils.getMoney(totalRemaining),
                              mainController.storeData.value?.currency ?? '',
                              Colors.red,
                              Icons.warning,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              "عملاء مديونين",
                              customersWithDebt.toString(),
                              'عميل',
                              Colors.orange,
                              Icons.people,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Customer Details Table
                      const Text(
                        "تفاصيل ديون العملاء",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.grey[200]),
                          columns: const [
                            DataColumn(label: Text('العميل')),
                            DataColumn(label: Text('الجوال')),
                            DataColumn(label: Text('عدد الديون')),
                            DataColumn(label: Text('إجمالي الديون')),
                            DataColumn(label: Text('المتبقي')),
                          ],
                          rows: summary.map((item) {
                            double remaining =
                                (item['remaining_amount'] ?? 0) as double;
                            return DataRow(
                              cells: [
                                DataCell(Text(item['name'] ?? '')),
                                DataCell(Text(item['phone'] ?? '')),
                                DataCell(
                                    Text('${item['debts_count'] ?? 0}')),
                                DataCell(Text(
                                    '${GlobalUtils.getMoney((item['total_debt'] ?? 0) as double)} ${mainController.storeData.value?.currency ?? ''}')),
                                DataCell(
                                  Text(
                                    '${GlobalUtils.getMoney(remaining)} ${mainController.storeData.value?.currency ?? ''}',
                                    style: TextStyle(
                                      color:
                                          remaining > 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String unit, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "$value $unit",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
