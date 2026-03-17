import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/debts_database.dart';
import 'package:moamri_accounting/debts/controllers/debts_controller.dart';
import 'package:moamri_accounting/debts/dialogs/debt_details_dialog.dart';
import 'package:moamri_accounting/debts/dialogs/pay_debt_dialog.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:moamri_accounting/utils/responsive_helper.dart';
import 'package:moamri_accounting/theme/app_colors.dart';
import 'package:moamri_accounting/theme/app_theme.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = ThemeController.to.isDarkMode;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() => Column(
            children: [
              SizedBox(height: isSmallScreen ? 6 : 10),

              // Summary Cards - استخدام Wrap للتجاوب
              FutureBuilder<double>(
                future: DebtsDatabase.getTotalDebtsAmount(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 10),
                    child: Card(
                      color: isDark 
                          ? colorScheme.errorContainer.withOpacity(0.3)
                          : Colors.red[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        child: Wrap(
                          alignment: WrapAlignment.spaceAround,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildSummaryItem(
                              icon: Icons.warning_rounded,
                              iconColor: colorScheme.error,
                              label: "إجمالي الديون المتبقية",
                              value: "${GlobalUtils.getMoney(snapshot.data ?? 0)} ${mainController.storeData.value?.currency ?? ''}",
                              valueColor: colorScheme.error,
                              isSmallScreen: isSmallScreen,
                              colorScheme: colorScheme,
                            ),
                            _buildSummaryItem(
                              icon: Icons.people_rounded,
                              iconColor: colorScheme.primary,
                              label: "عدد الديون النشطة",
                              value: "${controller.debtsCount.value}",
                              valueColor: colorScheme.primary,
                              isSmallScreen: isSmallScreen,
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: isSmallScreen ? 6 : 10),

              // Filter and Sort Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              avatar: Icon(
                                controller.showOnlyActive.value 
                                    ? Icons.filter_list_rounded 
                                    : Icons.list_rounded,
                                size: isSmallScreen ? 16 : 18,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  controller.showOnlyActive.value
                                      ? "الديون النشطة فقط"
                                      : "جميع الديون",
                                  style: TextStyle(
                                    fontFamily: 'ReadexPro',
                                    fontSize: isSmallScreen ? 11 : 13,
                                  ),
                                ),
                              ),
                              selected: controller.showOnlyActive.value,
                              onSelected: (value) {
                                controller.toggleActiveFilter();
                              },
                              selectedColor: AppColors.success.withOpacity(0.3),
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
                    IconButton(
                      onPressed: () => controller.refreshDebts(),
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
              SizedBox(height: isSmallScreen ? 6 : 10),

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
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            source: controller.dataSource.value!,
                            selectionMode: SelectionMode.single,
                            allowColumnsResizing: true,
                            columnResizeMode: ColumnResizeMode.onResizeEnd,
                            columns: [
                              GridColumn(
                                columnName: 'ID',
                                width: 70,
                                minimumWidth: 60,
                                label: _buildHeaderCell('رقم', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Customer',
                                width: 130,
                                minimumWidth: 100,
                                label: _buildHeaderCell('العميل', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Phone',
                                width: 100,
                                minimumWidth: 80,
                                label: _buildHeaderCell('الجوال', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Date',
                                width: 100,
                                minimumWidth: 80,
                                label: _buildHeaderCell('التاريخ', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'TotalAmount',
                                width: 110,
                                minimumWidth: 90,
                                label: _buildHeaderCell('المبلغ الأصلي', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'RemainingAmount',
                                width: 110,
                                minimumWidth: 90,
                                label: _buildHeaderCell('المبلغ المتبقي', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Status',
                                width: 80,
                                minimumWidth: 70,
                                label: _buildHeaderCell('الحالة', colorScheme, isSmallScreen),
                              ),
                              GridColumn(
                                columnName: 'Note',
                                columnWidthMode: ColumnWidthMode.lastColumnFill,
                                minimumWidth: 100,
                                label: _buildHeaderCell('ملاحظة', colorScheme, isSmallScreen),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const Divider(height: 1),

              // Action Buttons
              SizedBox(
                height: isSmallScreen ? 56 : 60,
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.visibility_rounded,
                          label: 'تفاصيل',
                          style: CustomWidgetsTheme.primaryOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
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
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.payment_rounded,
                          label: 'سداد',
                          style: CustomWidgetsTheme.primaryOutlinedButtonStyle(
                            foregroundColor: AppColors.success,
                          ),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
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
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          label: 'حذف',
                          style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
                          isSmallScreen: isSmallScreen,
                          colorScheme: colorScheme,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    required bool isSmallScreen,
    required ColorScheme colorScheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: isSmallScreen ? 20 : 24),
        SizedBox(height: isSmallScreen ? 2 : 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 10 : 12,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 18,
              fontFamily: 'ReadexPro',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, ColorScheme colorScheme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8, vertical: 6),
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
