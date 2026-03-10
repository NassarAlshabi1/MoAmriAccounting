import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/debts/data_sources/debts_data_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DebtsController extends GetxController {
  final MainController mainController;
  final int? customerId;

  DebtsController({required this.mainController, this.customerId});

  var isFirstLoadRunning = true.obs;
  var debts = <Map<String, dynamic>>[].obs;
  var debtsCount = 0.obs;
  var dataSource = Rxn<DebtsDataSource>();
  var showOnlyActive = true.obs;
  
  final dataGridController = DataGridController();
  var columnWidths = <String, double>{
    'ID': 80,
    'Customer': 150,
    'Phone': 120,
    'Date': 120,
    'TotalAmount': 120,
    'RemainingAmount': 120,
    'Status': 100,
    'Note': 150,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    firstLoad();
  }

  Future<void> firstLoad() async {
    isFirstLoadRunning.value = true;
    debts.clear();

    List<Map<String, dynamic>> debtsList;
    if (showOnlyActive.value) {
      debtsList = await DebtsDatabase.getActiveDebts();
    } else {
      debtsList = await DebtsDatabase.getAllDebts(customerId: customerId);
    }

    debts.addAll(debtsList);
    debtsCount.value = debts.length;

    dataSource.value = DebtsDataSource(
      mainController: mainController,
      debts: debts,
    );

    isFirstLoadRunning.value = false;
  }

  Future<void> refreshDebts() async {
    await firstLoad();
  }

  void toggleActiveFilter() {
    showOnlyActive.value = !showOnlyActive.value;
    firstLoad();
  }
}
