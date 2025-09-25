class Validators {
  /// Validate Email
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Validate Phone Number (digits only, 10–15 length)
  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), ''); // keep only digits
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  /// Validate Username (alphanumeric, 3–16 chars)
  static bool isValidUsername(String username) {
    final regex = RegExp(r'^[a-zA-Z0-9_]{3,16}$');
    return regex.hasMatch(username);
  }

  /// Validate Password (at least 8 chars, 1 uppercase, 1 number, 1 special char)
  static bool isValidPassword(String password) {
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  /// Validate Numeric Value (integer or decimal)
  static bool isNumeric(String input) {
    final regex = RegExp(r'^-?\d+(\.\d+)?$');
    return regex.hasMatch(input);
  }

  /// Validate Non-Empty String
  static bool isNotEmpty(String? input) {
    return input != null && input.trim().isNotEmpty;
  }
}
