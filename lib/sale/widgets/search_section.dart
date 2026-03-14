import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/dialogs/sale_material_dialog.dart';
import 'package:moamri_accounting/theme/custom_widgets_theme.dart';

import '../controllers/sale_controller.dart';
import '../../controllers/main_controller.dart';

/// Search Section Widget
///
/// Handles material search with autocomplete functionality
class SearchSection extends StatelessWidget {
  final MainController mainController;
  final SaleController controller;
  final bool isSmallScreen;

  const SearchSection({
    super.key,
    required this.mainController,
    required this.controller,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: isSmallScreen ? 56 : 60,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
        child: Row(
          children: [
            Expanded(
              child: _buildSearchField(colorScheme),
            ),
            _buildRefreshButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 10),
      child: TypeAheadField<MyMaterial>(
        controller: controller.searchController,
        emptyBuilder: (context) => _buildEmptyResult(colorScheme),
        onSelected: (value) => _handleSelection(value),
        suggestionsCallback: (pattern) async {
          return await MyMaterialsDatabase.getMaterialsSuggestions(pattern, null);
        },
        itemBuilder: (context, suggestion) => _buildSuggestionItem(suggestion),
        builder: (context, textController, focusNode) => _buildTextField(focusNode),
      ),
    );
  }

  Widget _buildEmptyResult(ColorScheme colorScheme) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Text(
          "لم يتم إيجاد المادة",
          style: TextStyle(
            fontFamily: 'ReadexPro',
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(MyMaterial suggestion) {
    return ListTile(
      title: Text(
        '${suggestion.barcode}, ${suggestion.name}',
        style: const TextStyle(fontFamily: 'ReadexPro'),
      ),
    );
  }

  Widget _buildTextField(FocusNode focusNode) {
    return TextField(
      controller: controller.searchController,
      focusNode: focusNode,
      decoration: CustomWidgetsTheme.searchInputDecoration(
        hintText: 'بحث عن المواد...',
      ),
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildRefreshButton(ColorScheme colorScheme) {
    return IconButton(
      onPressed: () => controller.getCategories(),
      tooltip: "تحديث",
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(Icons.sync_rounded, color: colorScheme.primary),
    );
  }

  Future<void> _handleSelection(MyMaterial value) async {
    var index = controller.dataSource.value.getMaterialIndex(value);
    if (index == -1) {
      if (value.quantity < 1) {
        showErrorDialog("لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
        return;
      }
      controller.dataSource.value.addDataGridRow(value, controller);
      await AudioPlayer().play(AssetSource('sounds/scanner-beep.mp3'));
      controller.dataSource.refresh();
    } else {
      showSaleMaterialDialog(mainController, controller, index);
    }
  }
}
