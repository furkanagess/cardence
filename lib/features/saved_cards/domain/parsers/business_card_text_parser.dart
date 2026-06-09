import '../entities/manual_saved_card_draft.dart';

/// OCR metninden kartvizit alanlarını çıkarır (heuristic).
class BusinessCardTextParser {
  BusinessCardTextParser._();

  static final RegExp _emailPattern = RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );
  static final RegExp _phonePattern = RegExp(
    r'(\+?\d[\d\s().-]{7,}\d)',
  );
  static final RegExp _urlPattern = RegExp(
    r'(https?://[^\s]+|www\.[^\s]+|linkedin\.com/[^\s]+)',
    caseSensitive: false,
  );

  static ManualSavedCardDraft parse({
    required String frontText,
    String backText = '',
  }) {
    final combined = '$frontText\n$backText';
    final lines = combined
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final email = _firstMatch(_emailPattern, combined);
    final phone = _normalizePhone(_firstMatch(_phonePattern, combined));
    final website = _normalizeWebsite(
      _firstUrl(combined, excludeLinkedIn: true),
    );
    final linkedin = _normalizeWebsite(_firstLinkedIn(combined));

    final usedLines = <String>{};
    if (email != null) usedLines.addAll(_linesContaining(lines, email));
    if (phone != null) usedLines.addAll(_linesContaining(lines, phone));
    if (website != null) usedLines.addAll(_linesContaining(lines, website));
    if (linkedin != null) usedLines.addAll(_linesContaining(lines, linkedin));

    final contentLines =
        lines.where((line) => !usedLines.contains(line)).toList();

    String? displayName;
    String? company;
    String? title;

    if (contentLines.isNotEmpty) {
      displayName = contentLines.first;
    }
    if (contentLines.length > 1) {
      title = contentLines[1];
    }
    if (contentLines.length > 2) {
      company = contentLines[2];
    }

    final about = backText.trim().isEmpty ? null : backText.trim();

    return ManualSavedCardDraft(
      displayName: displayName,
      email: email,
      phone: phone,
      company: company,
      title: title,
      website: website,
      linkedin: linkedin,
      about: about,
    );
  }

  static String? _firstMatch(RegExp pattern, String text) {
    final match = pattern.firstMatch(text);
    return match?.group(0)?.trim();
  }

  static Iterable<String> _linesContaining(List<String> lines, String value) {
    final needle = value.toLowerCase();
    return lines.where((line) => line.toLowerCase().contains(needle));
  }

  static String? _normalizePhone(String? raw) {
    if (raw == null) return null;
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    return digits.isEmpty ? null : raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String? _firstUrl(String text, {required bool excludeLinkedIn}) {
    for (final match in _urlPattern.allMatches(text)) {
      final value = match.group(0)?.trim();
      if (value == null) continue;
      if (excludeLinkedIn && value.toLowerCase().contains('linkedin')) {
        continue;
      }
      return value;
    }
    return null;
  }

  static String? _firstLinkedIn(String text) {
    for (final match in _urlPattern.allMatches(text)) {
      final value = match.group(0)?.trim();
      if (value != null && value.toLowerCase().contains('linkedin')) {
        return value;
      }
    }
    return null;
  }

  static String? _normalizeWebsite(String? raw) {
    if (raw == null) return null;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('www.')) return 'https://$raw';
    return raw;
  }
}
