import 'package:intl/intl.dart';

/// Doğum günü metnini saklama (`yyyy-MM-dd`) ve gösterim için yardımcılar.
class BirthdayFormat {
  BirthdayFormat._();

  static final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static DateTime? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final text = raw.trim();

    if (_isoDate.hasMatch(text)) {
      try {
        final parts = text.split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        return null;
      }
    }

    final dotted = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$');
    final dottedMatch = dotted.firstMatch(text);
    if (dottedMatch != null) {
      try {
        return DateTime(
          int.parse(dottedMatch.group(3)!),
          int.parse(dottedMatch.group(2)!),
          int.parse(dottedMatch.group(1)!),
        );
      } catch (_) {
        return null;
      }
    }

    try {
      return DateFormat.yMMMMd('tr').parseLoose(text);
    } catch (_) {
      return null;
    }
  }

  static String toStorage(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String display(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final parsed = tryParse(raw);
    if (parsed != null) {
      return DateFormat('d MMMM yyyy', 'tr').format(parsed);
    }
    return raw.trim();
  }
}
