import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_palette.dart';

/// App Text Field - A reusable text input widget
///
/// Features:
/// - Consistent styling across the app
/// - Built-in validation support
/// - Optional prefix/suffix icons
/// - Loading state support
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? AppPalette.textPrimary : AppPalette.textDisabled,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: enabled ? AppPalette.textPrimary : AppPalette.textDisabled,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// App Currency Field - A specialized text field for currency input
///
/// Features:
/// - Automatic number formatting
/// - Currency symbol display
/// - RTL support for Arabic
class AppCurrencyField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String currencySymbol;
  final String currency;
  final bool enabled;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const AppCurrencyField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.currencySymbol = 'ر.س',
    this.currency = 'ريال',
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.focusNode,
  });

  Color get _currencyColor {
    switch (currency.toLowerCase()) {
      case 'ريال':
      case 'sar':
      case 'riyal':
        return AppPalette.riyal;
      case 'دولار':
      case 'usd':
      case 'dollar':
        return AppPalette.dollar;
      default:
        return AppPalette.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      validator: validator,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      prefixIcon: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _currencyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currencySymbol,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _currencyColor,
          ),
        ),
      ),
      hint: '0.00',
    );
  }
}

/// App Quantity Field - A specialized field for quantity input
///
/// Features:
/// - Stepper buttons for increment/decrement
/// - Min/max validation
class AppQuantityField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double minValue;
  final double maxValue;
  final double step;
  final bool enabled;
  final void Function(String)? onChanged;

  const AppQuantityField({
    super.key,
    this.label,
    this.controller,
    this.validator,
    this.minValue = 0,
    this.maxValue = double.infinity,
    this.step = 1,
    this.enabled = true,
    this.onChanged,
  });

  void _increment() {
    final current = double.tryParse(controller?.text ?? '0') ?? 0;
    final newValue = (current + step).clamp(minValue, maxValue);
    controller?.text = _formatValue(newValue);
    onChanged?.call(controller!.text);
  }

  void _decrement() {
    final current = double.tryParse(controller?.text ?? '0') ?? 0;
    final newValue = (current - step).clamp(minValue, maxValue);
    controller?.text = _formatValue(newValue);
    onChanged?.call(controller!.text);
  }

  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: enabled ? _decrement : null,
            icon: const Icon(Icons.remove_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppPalette.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          IconButton(
            onPressed: enabled ? _increment : null,
            icon: const Icon(Icons.add_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppPalette.primaryContainer,
              foregroundColor: AppPalette.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// App Dropdown Field - A reusable dropdown widget
class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownItem<T>> items;
  final String? hint;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final bool enabled;
  final Widget? prefixIcon;

  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    this.hint,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: enabled ? AppPalette.textPrimary : AppPalette.textDisabled,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(
                      item.label,
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          hint: hint != null
              ? Text(hint!, style: GoogleFonts.cairo(color: AppPalette.textHint))
              : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

/// Dropdown Item model
class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({
    required this.value,
    required this.label,
  });
}
