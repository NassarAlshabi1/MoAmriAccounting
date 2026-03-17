import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/database/entities/debt_payment.dart';
import 'package:moamri_accounting/debts/dialogs/pay_debt_dialog.dart';
import 'package:moamri_accounting/utils/global_utils.dart';

Future<bool?> showDebtDetailsDialog(
  MainController mainController,
  Map<String, dynamic> debtData,
) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
              child: FutureBuilder<List<DebtPayment>>(
                future: DebtsDatabase.getDebtPayments(debtData['id'] as int),
                builder: (context, snapshot) {
                  List<DebtPayment> payments = snapshot.data ?? [];
                  double totalPaid = payments.fold(
                      0, (sum, p) => sum + (p.amount * p.exchangeRate));
                  double originalAmount = debtData['amount'] as double;
                  double remainingAmount =
                      (debtData['remaining_amount'] ?? originalAmount) as double;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "تفاصيل الدين",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ],
                        ),
                        const Divider(),
                        // Debt Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow("رقم الدين", "#${debtData['id']}"),
                              _buildInfoRow(
                                  "العميل", debtData['customer_name'] ?? 'غير محدد'),
                              _buildInfoRow(
                                  "التاريخ",
                                  GlobalUtils.getDate(debtData['date'] as int)),
                              _buildInfoRow(
                                  "المبلغ الأصلي",
                                  "${GlobalUtils.getMoney(originalAmount)} ${mainController.storeData.value?.currency ?? ''}"),
                              _buildInfoRow(
                                  "إجمالي المدفوع",
                                  "${GlobalUtils.getMoney(totalPaid)} ${mainController.storeData.value?.currency ?? ''}",
                                  valueColor: Colors.green),
                              _buildInfoRow(
                                  "المبلغ المتبقي",
                                  "${GlobalUtils.getMoney(remainingAmount)} ${mainController.storeData.value?.currency ?? ''}",
                                  valueColor: remainingAmount > 0
                                      ? Colors.red
                                      : Colors.green),
                              if (debtData['note'] != null &&
                                  debtData['note'].toString().isNotEmpty)
                                _buildInfoRow("ملاحظة", debtData['note']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Payments History
                        const Text(
                          "سجل السداد",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : payments.isEmpty
                                  ? const Center(
                                      child: Text("لا توجد عمليات سداد"))
                                  : ListView.builder(
                                      itemCount: payments.length,
                                      itemBuilder: (context, index) {
                                        final payment = payments[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: ListTile(
                                            leading: const Icon(Icons.payment,
                                                color: Colors.green),
                                            title: Text(
                                              "${GlobalUtils.getMoney(payment.amount)} ${payment.currency}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(
                                              GlobalUtils.getDate(payment.date),
                                            ),
                                            trailing: payment.note != null
                                                ? Tooltip(
                                                    message: payment.note!,
                                                    child: const Icon(Icons.note,
                                                        color: Colors.grey),
                                                  )
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (remainingAmount > 0)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  Get.back();
                                  await showPayDebtDialog(
                                      mainController, debtData);
                                },
                                icon: const Icon(Icons.payment),
                                label: const Text('سداد'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('إغلاق'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      });
}

Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
