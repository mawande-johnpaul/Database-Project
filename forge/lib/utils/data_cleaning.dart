class DataCleaning {
  static List<String> cleanList(List<String?> rawList) {
    return rawList
        .where((item) => item != null && item.trim().isNotEmpty)
        .map((item) => item!.trim())
        .toSet()
        .toList();
  }

  static String normalizeText(String input) {
    return input.trim().toLowerCase();
  }

  static String removeSpecialChars(String input) {
    final regex = RegExp(r'[^\w\s]');
    return input.replaceAll(regex, '');
  }

  static String fillMissing(String? input, {String defaultValue = "N/A"}) {
    return (input == null || input.trim().isEmpty) ? defaultValue : input.trim();
  }
}
