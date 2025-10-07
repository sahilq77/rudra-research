import 'package:flutter/services.dart';

class SecureTextInputFormatter extends TextInputFormatter {
  // Regular expression to match dangerous patterns or leading whitespace
  static final RegExp _deniedPattern = RegExp(
    r'(<script|on\w+=|javascript:|^[\s]+)',
    caseSensitive: false,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new input contains any denied pattern or leading whitespace, reject it
    if (_deniedPattern.hasMatch(newValue.text)) {
      return oldValue; // Return old value to prevent update
    }
    return newValue; // Allow the input if it passes the check
  }

  // Static method for easy usage like FilteringTextInputFormatter.deny
  static TextInputFormatter deny() {
    return SecureTextInputFormatter();
  }
}
