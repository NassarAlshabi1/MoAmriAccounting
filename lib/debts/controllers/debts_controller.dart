import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/debts/data_sources/debts_data_source.dart';

class DebtsController extends GetxController {
  final MainController mainController;
  final int? customerId;

  DebtsController({required this.mainController, this.customerId});

  var isFirstLoadRunning = true.obs;
  var debts = <Map<String, dynamic>>[].obs;
  var debtsCount = 0.obs;
  var dataSource = Rxn<DebtsDataSource>();
  var selectedOrderBy = 0.obs;
  var selectedOrderDir = 0.obs;
  var orderBy = ['التاريخ', 'المبلغ', 'المبلغ المتبقي', 'العميل'].obs;
  var showOnlyActive = true.obs;

  @override
  void onInit() {
    super.onInit();
    firstLoad();
  }

  Future<void> firstLoad() async {
    isFirstLoadRunning.value = true;
    debts.clear();

    String orderColumn = 'd.date';
    switch (selectedOrderBy.value) {
      case 1:
        orderColumn = 'd.amount';
        break;
      case 2:
        orderColumn = 'remaining_amount';
        break;
      case 3:
        orderColumn = 'c.name';
        break;
    }

    String dir = selectedOrderDir.value == 0 ? 'ASC' : 'DESC';

    List<Map<String, dynamic>> debtsList;
    if (showOnlyActive.value) {
      debtsList = await DebtsDatabase.getActiveDebts(
        orderBy: orderColumn,
        dir: dir,
      );
    } else {
      debtsList = await DebtsDatabase.getAllDebts(
        customerId: customerId,
        orderBy: orderColumn,
        dir: dir,
      );
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
