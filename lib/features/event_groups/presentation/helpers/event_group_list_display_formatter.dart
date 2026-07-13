import '../../../../l10n/app_localizations.dart';

/// Etkinlik grubu liste kartları için kısa tarih ve durum metinleri.
class EventGroupListDisplayFormatter {
  EventGroupListDisplayFormatter._();

  static bool _isTurkish(AppLocalizations l10n) =>
      l10n.localeName.startsWith('tr');

  static String _monthAbbrev(AppLocalizations l10n, int month) {
    if (_isTurkish(l10n)) {
      const months = [
        'Oca',
        'Şub',
        'Mar',
        'Nis',
        'May',
        'Haz',
        'Tem',
        'Ağu',
        'Eyl',
        'Eki',
        'Kas',
        'Ara',
      ];
      return months[month - 1];
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String formatUpcomingDateRange(
    AppLocalizations l10n,
    DateTime startAt,
    DateTime? endAt,
  ) {
    final start = startAt.toLocal();
    final end = endAt?.toLocal();
    final startMonth = _monthAbbrev(l10n, start.month);

    if (end == null ||
        start.year == end.year &&
            start.month == end.month &&
            start.day == end.day) {
      return '${start.day} $startMonth ${start.year}';
    }

    final endMonth = _monthAbbrev(l10n, end.month);
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}-${end.day} $startMonth ${start.year}';
    }
    if (start.year == end.year) {
      return '${start.day} $startMonth - ${end.day} $endMonth ${start.year}';
    }
    return '${start.day} $startMonth ${start.year} - '
        '${end.day} $endMonth ${end.year}';
  }

  static String ongoingTimingLabel(AppLocalizations l10n) => l10n.eventGroupToday;

  static String endedSummaryLabel(
    AppLocalizations l10n,
    DateTime? endAt, {
    DateTime? reference,
  }) {
    final end = (endAt ?? reference ?? DateTime.now()).toLocal();
    final now = (reference ?? DateTime.now()).toLocal();
    final endMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);
    final eventEndMonth = DateTime(end.year, end.month);

    if (eventEndMonth == endMonth) {
      return l10n.eventGroupEndedThisMonth;
    }
    if (eventEndMonth == previousMonth) {
      return l10n.eventGroupEndedLastMonth;
    }

    final month = _monthAbbrev(l10n, end.month);
    return '${end.day} $month ${end.year}';
  }

  static String? primaryCityFromLocation(String? location) {
    final trimmed = location?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    const displaySeparator = ' - ';
    if (trimmed.contains(displaySeparator)) {
      final parts = trimmed
          .split(displaySeparator)
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length >= 2) return parts[1];
      return parts.first;
    }

    final parts = trimmed.split(RegExp(r'[,·|]'));
    if (parts.length >= 3) {
      return parts[parts.length - 2].trim();
    }
    if (parts.length == 2) {
      return parts.first.trim();
    }
    return parts.first.trim();
  }

  static String linkedCardCountLabel(AppLocalizations l10n, int count) =>
      l10n.eventGroupLinkedCardCount(count);
}
