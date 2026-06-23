import '../../../../core/utils/birthday_format.dart';
import '../../domain/entities/event_group.dart';

class EventGroupMetaFormatter {
  EventGroupMetaFormatter._();

  static String? formatDate(DateTime? date) {
    if (date == null) return null;
    return BirthdayFormat.display(BirthdayFormat.toStorage(date));
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

  static String? summaryFor(EventGroup group) =>
      summary(location: group.location, eventDate: group.eventDate);
}
