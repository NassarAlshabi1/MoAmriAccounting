import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/dialogs/sale_dialog.dart';
import 'package:moamri_accounting/theme/app_colors.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';

import '../controllers/sale_controller.dart';
import '../../controllers/main_controller.dart';
import 'total_card.dart';

/// Bottom Actions Section Widget
///
/// Contains the total display and action buttons
class BottomActionsSection extends StatelessWidget {
  final MainController mainController;
  final SaleController controller;
  final bool isSmallScreen;

  const BottomActionsSection({
    super.key,
    required this.mainController,
    required this.controller,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomAreaHeight = isSmallScreen ? 140.0 : 160.0;

    return SizedBox(
      height: bottomAreaHeight,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
        child: isSmallScreen
            ? _buildSmallScreenLayout(context, colorScheme)
            : _buildNormalLayout(colorScheme),
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TotalCard(controller: controller, isSmallScreen: isSmallScreen),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _buildSmallScreenButtons(colorScheme),
        ),
      ],
    );
  }

  Widget _buildSmallScreenButtons(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRemoveButton(colorScheme, isCompact: true),
          const SizedBox(width: 6),
          _buildClearButton(colorScheme, isCompact: true),
          const SizedBox(width: 6),
          _buildSaleButton(isCompact: true),
        ],
      ),
    );
  }

  Widget _buildNormalLayout(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TotalCard(controller: controller, isSmallScreen: isSmallScreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _buildNormalButtons(colorScheme),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildNormalButtons(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Expanded(child: _buildRemoveButton(colorScheme)),
            const SizedBox(width: 8),
            Expanded(child: _buildClearButton(colorScheme)),
          ],
        ),
        _buildSaleButton(),
      ],
    );
  }

  Widget _buildRemoveButton(ColorScheme colorScheme, {bool isCompact = false}) {
    return isCompact
        ? _buildCompactButton(
            icon: Icons.remove_shopping_cart_rounded,
            label: 'إزالة',
            style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
            onPressed: () => _handleRemove(),
          )
        : OutlinedButton.icon(
            onPressed: () => _handleRemove(),
            style: CustomWidgetsTheme.dangerOutlinedButtonStyle(),
            icon: const Icon(Icons.remove_shopping_cart_rounded, size: 18),
            label: const FittedBox(
              child: Text('إزالة المادة', style: TextStyle(fontFamily: 'ReadexPro')),
            ),
          );
  }

  Widget _buildClearButton(ColorScheme colorScheme, {bool isCompact = false}) {
    final style = FilledButton.styleFrom(
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return isCompact
        ? _buildCompactButton(
            icon: Icons.clear_all_rounded,
            label: 'تفريغ',
            style: style,
            onPressed: () => _handleClear(),
          )
        : FilledButton.icon(
            onPressed: () => _handleClear(),
            style: style,
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const FittedBox(
              child: Text('تفريغ القائمة', style: TextStyle(fontFamily: 'ReadexPro')),
            ),
          );
  }

  Widget _buildSaleButton({bool isCompact = false}) {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.onSuccess,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      minimumSize: isCompact ? null : const Size(double.infinity, 40),
    );

    return isCompact
        ? _buildCompactButton(
            icon: Icons.shopping_bag_rounded,
            label: 'بيع',
            style: style,
            onPressed: () => showSaleDialog(mainController, controller),
          )
        : FilledButton.icon(
            onPressed: () => showSaleDialog(mainController, controller),
            style: style,
            icon: const Icon(Icons.shopping_bag_rounded, size: 20),
            label: const FittedBox(
              child: Text(
                'بيع',
                style: TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.bold),
              ),
            ),
          );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required ButtonStyle style,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontFamily: 'ReadexPro', fontSize: 12)),
    );
  }

  void _handleRemove() {
    if (controller.dataGridController.selectedIndex >= 0) {
      controller.dataSource.value.removeDataGridRow(
        controller.dataGridController.selectedIndex,
        controller,
      );
      controller.dataSource.refresh();
    } else {
      showErrorDialog("يرجى إختيار المادة المراد إزالتها");
    }
  }

  Future<void> _handleClear() async {
    final confirmed = await showConfirmationDialog(
      "هل أنت متأكد من أنك تريد تفريغ قائمة البيع؟!",
    );
    if (confirmed ?? false) {
      controller.dataSource.value.clearDataGridRows(controller);
      controller.dataSource.refresh();
    }
  }
}
