/// Utility for timezone-safe date parsing, formatting, and timeline grouping.
class DateParser {
  DateParser._();

  static const List<String> _months = [
    'january',
    'february',
    'march',
    'april',
    'may',
    'june',
    'july',
    'august',
    'september',
    'october',
    'november',
    'december',
  ];

  /// Parses a string or DateTime into a timezone-safe [DateTime].
  /// Supports:
  /// - ISO 8601 (e.g. "2024-02-29T10:00:00Z", "2024-02-29T10:00:00+05:30", "2024-02-29")
  /// - Month-name strings (e.g. "29 february 2024", "10 January 2026")
  /// - Slash-separated dates (e.g. "29/2/2024", "10/01/2026")
  static DateTime? parse(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;
    if (input is! String) return null;

    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // 1. Try standard ISO 8601
    final isoParsed = DateTime.tryParse(trimmed);
    if (isoParsed != null) return isoParsed;

    // 2. Try "DD Month YYYY" (e.g. "10 january 2026" or "29 Feb 2024")
    final monthRegex = RegExp(r'^(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})$');
    final monthMatch = monthRegex.firstMatch(trimmed);
    if (monthMatch != null) {
      final day = int.tryParse(monthMatch.group(1)!);
      final monthStr = monthMatch.group(2)!.toLowerCase();
      final year = int.tryParse(monthMatch.group(3)!);

      int monthIndex = -1;
      for (int i = 0; i < _months.length; i++) {
        if (_months[i].startsWith(monthStr) || _months[i] == monthStr) {
          monthIndex = i + 1;
          break;
        }
      }

      if (day != null && year != null && monthIndex != -1) {
        try {
          return DateTime(year, monthIndex, day);
        } catch (_) {}
      }
    }

    // 3. Try "D/M/YYYY" or "DD/MM/YYYY"
    final slashRegex = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$');
    final slashMatch = slashRegex.firstMatch(trimmed);
    if (slashMatch != null) {
      final day = int.tryParse(slashMatch.group(1)!);
      final month = int.tryParse(slashMatch.group(2)!);
      final year = int.tryParse(slashMatch.group(3)!);
      if (day != null && month != null && year != null) {
        try {
          return DateTime(year, month, day);
        } catch (_) {}
      }
    }

    return null;
  }

  /// Formats date for user-facing display (e.g. "10 January 2026").
  static String formatDisplay(DateTime? date) {
    if (date == null) return '';
    final monthName = _months[date.month - 1];
    final capitalized = monthName[0].toUpperCase() + monthName.substring(1);
    return '${date.day} $capitalized ${date.year}';
  }

  /// Formats month and year for grouping (e.g. "January 2026").
  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    final monthName = _months[date.month - 1];
    final capitalized = monthName[0].toUpperCase() + monthName.substring(1);
    return '$capitalized ${date.year}';
  }

  /// Compares two dates for same calendar day ignoring time.
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
