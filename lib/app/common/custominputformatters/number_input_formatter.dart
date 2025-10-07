// lib/common/custominputformatters/number_input_formatter.dart
import 'package:flutter/services.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty input
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Regular expression to allow digits and one optional period
    final regExp = RegExp(r'^[0-9]+(\.[0-9]*)?$');

    // Check if the input matches the pattern
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue; // Revert to old value if invalid
    }

    // Additional validation for only one period
    if (newValue.text.split('.').length > 2) {
      return oldValue; // Revert if multiple periods are found
    }

    return newValue;
  }
}
