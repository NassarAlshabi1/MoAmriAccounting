import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/database/entities/debt_payment.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/utils/global_utils.dart';

Future<bool?> showPayDebtDialog(
  MainController mainController,
  Map<String, dynamic> debtData,
) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final amountController = TextEditingController();
        final noteController = TextEditingController();
        var selectedCurrency = mainController.currencies.isNotEmpty
            ? mainController.currencies.first
            : null;

        double remainingAmount =
            (debtData['remaining_amount'] ?? debtData['amount']) as double;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: StatefulBuilder(builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "سداد دين",
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
                        // Debt Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow("العميل", debtData['customer_name'] ?? 'غير محدد'),
                              _buildInfoRow(
                                  "المبلغ الأصلي",
                                  "${GlobalUtils.getMoney(debtData['amount'] as double)} ${mainController.storeData.value?.currency ?? ''}"),
                              _buildInfoRow(
                                "المبلغ المتبقي",
                                "${GlobalUtils.getMoney(remainingAmount)} ${mainController.storeData.value?.currency ?? ''}",
                                valueColor: Colors.red,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Amount Field
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'مبلغ السداد',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال المبلغ';
                            }
                            double? amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'يرجى إدخال مبلغ صحيح';
                            }
                            if (selectedCurrency != null &&
                                amount * selectedCurrency.exchangeRate >
                                    remainingAmount) {
                              return 'المبلغ أكبر من الدين المتبقي';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 12),
                        // Currency Dropdown
                        Obx(() => DropdownButtonFormField<dynamic>(
                              value: selectedCurrency,
                              decoration: InputDecoration(
                                labelText: 'العملة',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: mainController.currencies.map((currency) {
                                return DropdownMenuItem(
                                  value: currency,
                                  child: Text(
                                      '${currency.name} (${currency.exchangeRate})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCurrency = value;
                                });
                              },
                            )),
                        const SizedBox(height: 12),
                        // Note Field
                        TextFormField(
                          controller: noteController,
                          decoration: InputDecoration(
                            labelText: 'ملاحظة (اختياري)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        // Summary
                        if (amountController.text.isNotEmpty &&
                            selectedCurrency != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("سيتبقى: "),
                                Text(
                                  "${GlobalUtils.getMoney(remainingAmount - (double.tryParse(amountController.text) ?? 0) * selectedCurrency!.exchangeRate)} ${mainController.storeData.value?.currency ?? ''}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('إلغاء'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                double amount =
                                    double.parse(amountController.text);
                                if (selectedCurrency == null) {
                                  showErrorDialog('يرجى اختيار العملة');
                                  return;
                                }

                                DebtPayment payment = DebtPayment(
                                  debtId: debtData['id'] as int,
                                  customerId: debtData['customer_id'] as int,
                                  date: DateTime.now().millisecondsSinceEpoch,
                                  amount: amount,
                                  exchangeRate: selectedCurrency.exchangeRate,
                                  currency: selectedCurrency.name,
                                  note: noteController.text.isEmpty
                                      ? null
                                      : noteController.text,
                                );

                                try {
                                  await DebtsDatabase.addDebtPayment(
                                    payment,
                                    mainController.currentUser.value!,
                                  );
                                  Get.back(result: true);
                                  await showSuccessDialog("تم تسجيل السداد بنجاح");
                                } catch (e) {
                                  showErrorDialog('حدث خطأ: $e');
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('تأكيد السداد'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
