class TextValidator {
  // Validates if the input is empty or contains only whitespace
  static String? isEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }

  // Validates email format using a regex pattern
  static String? isEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    final RegExp emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validates mobile number (basic international format, e.g., +1234567890 or 1234567890)

  static String? isMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    // Must be exactly 10 digits
    if (digitsOnly.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }

    // Must start with 6, 7, 8, or 9 (valid Indian mobile)
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly)) {
      return 'Please enter a valid Indian mobile number';
    }

    return null;
  }

  // static String? isMobileNumber(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return 'Please enter a mobile number';
  //   }
  //   final RegExp mobilePattern = RegExp(
  //     r'^\+?[1-9]\d{7,14}$',
  //     caseSensitive: false,
  //   );
  //   if (!mobilePattern.hasMatch(value.trim())) {
  //     return 'Please enter a valid mobile number';
  //   }
  //   return null;
  // }

  // Validates if the input contains only alphabetic characters
  static String? isAlphabetic(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    final RegExp alphabeticPattern = RegExp(
      r'^[a-zA-Z\s]+$',
      caseSensitive: false,
    );
    if (!alphabeticPattern.hasMatch(value.trim())) {
      return 'Only alphabetic characters are allowed';
    }
    return null;
  }

  // Validates if the input contains only alphanumeric characters
  static String? isAlphanumeric(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    final RegExp alphanumericPattern = RegExp(
      r'^[a-zA-Z0-9\s]+$',
      caseSensitive: false,
    );
    if (!alphanumericPattern.hasMatch(value.trim())) {
      return 'Only alphanumeric characters are allowed';
    }
    return null;
  }

  static String? isValidAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter address';
    }

    final trimmed = value.trim();

    // Minimum 5 characters (very lenient – allows "Shop 12", "Room 5", "H.No 45")
    if (trimmed.length < 5) {
      return 'Address must be at least 5 characters';
    }

    // Must contain at least ONE letter (a-z or A-Z)
    // This blocks pure numbers like "123456", "999999", or symbols only
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return 'Address must contain at least one letter';
    }

    // Optional: Block obvious garbage (all same symbols repeated)
    if (RegExp(r'^[0-9\s\-.,/\\#&()]+$').hasMatch(trimmed)) {
      return 'Please enter a proper address with street/building name';
    }

    return null;
  }

// Reusable combined validator (recommended)
  static String? validateAddress(String? value) {
    return combineValidators(value, [
      isEmpty,
      isValidAddress,
    ]);
  }

  // Validates if the input meets a minimum length requirement
  static String? hasMinimumLength(String? value, int minLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    if (value.trim().length < minLength) {
      return 'Must be at least $minLength characters long';
    }
    return null;
  }

  // Validates if the input meets a maximum length requirement
  static String? hasMaximumLength(String? value, int maxLength) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    if (value.trim().length > maxLength) {
      return 'Must not exceed $maxLength characters';
    }
    return null;
  }

  // Validates if the input matches a custom regex pattern
  static String? matchesPattern(
      String? value, RegExp pattern, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    if (!pattern.hasMatch(value.trim())) {
      return errorMessage;
    }
    return null;
  }

  // Validates password (e.g., at least 8 characters, with uppercase, lowercase, number, and special character)
  static String? isStrongPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a password';
    }
    final RegExp passwordPattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      caseSensitive: true,
    );
    if (!passwordPattern.hasMatch(value.trim())) {
      return 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character';
    }
    return null;
  }

  // Combines multiple validators and returns the first error message or null if all pass
  static String? combineValidators(
      String? value, List<String? Function(String?)> validators) {
    for (var validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result; // Return the first error message
      }
    }
    return null; // All validators passed
  }
}
