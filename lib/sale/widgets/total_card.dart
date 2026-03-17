import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';

import '../controllers/sale_controller.dart';

/// Total Card Widget
///
/// Displays the total amount of the sale
class TotalCard extends StatelessWidget {
  final SaleController controller;
  final bool isSmallScreen;

  const TotalCard({
    super.key,
    required this.controller,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        _buildCardContainer(colorScheme),
        _buildTitleLabel(colorScheme),
      ],
    );
  }

  Widget _buildCardContainer(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: CustomWidgetsTheme.primaryCardDecoration(
        borderColor: colorScheme.primary.withOpacity(0.5),
      ),
      child: Obx(() => _buildTotalContent(colorScheme)),
    );
  }

  Widget _buildTotalContent(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
      child: SingleChildScrollView(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              controller.totalString.value,
              style: TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: isSmallScreen ? 12 : 14,
                color: colorScheme.onSurface,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleLabel(ColorScheme colorScheme) {
    return Positioned(
      right: 16,
      top: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
        color: colorScheme.surface,
        child: Text(
          'الإجمالي',
          style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: isSmallScreen ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
