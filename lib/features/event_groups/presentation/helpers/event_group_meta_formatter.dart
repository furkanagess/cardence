import '../../domain/entities/event_group.dart';

class EventGroupMetaFormatter {
  EventGroupMetaFormatter._();

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    final local = date.toLocal();
    return '${_twoDigits(local.day)}.${_twoDigits(local.month)}.${local.year} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String formatRange(DateTime startAt, DateTime? endAt) {
    final start = formatDate(startAt) ?? '';
    final end = formatDate(endAt);
    if (end == null || end.isEmpty) return start;
    return '$start - $end';
  }

  static String? summary({String? location, DateTime? eventDate}) {
    final parts = <String>[];
    final formattedDate = formatDate(eventDate);
    if (formattedDate != null && formattedDate.isNotEmpty) {
      parts.add(formattedDate);
    }
    final trimmedLocation = location?.trim();
    if (trimmedLocation != null && trimmedLocation.isNotEmpty) {
      parts.add(trimmedLocation);
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static String? summaryFor(EventGroup group) {
    final parts = <String>[
      formatRange(group.startAt, group.endAt),
    ];
    final trimmedLocation = group.location?.trim();
    if (trimmedLocation != null && trimmedLocation.isNotEmpty) {
      parts.add(trimmedLocation);
    }
    return parts.join(' · ');
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
