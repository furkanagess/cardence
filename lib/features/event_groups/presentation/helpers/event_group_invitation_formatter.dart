import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/event_group.dart';

class EventGroupInvitationFormatter {
  EventGroupInvitationFormatter._();

  static int daysUntilEventStart(DateTime startAt, {DateTime? reference}) {
    final now = (reference ?? DateTime.now()).toUtc();
    final start = startAt.toUtc();
    if (!start.isAfter(now)) return 0;

    final startDate = DateTime.utc(start.year, start.month, start.day);
    final nowDate = DateTime.utc(now.year, now.month, now.day);
    return startDate.difference(nowDate).inDays;
  }

  static EventGroupStatus eventStatus(
    DateTime startAt,
    DateTime? endAt, {
    DateTime? reference,
  }) {
    final now = (reference ?? DateTime.now()).toUtc();
    final start = startAt.toUtc();
    final end = endAt?.toUtc();

    if (end != null && !end.isAfter(now)) {
      return EventGroupStatus.ended;
    }
    if (start.isAfter(now)) {
      return EventGroupStatus.upcoming;
    }
    return EventGroupStatus.ongoing;
  }

  static String eventStartRemainingLabel(
    AppLocalizations l10n,
    DateTime startAt,
    DateTime? endAt, {
    DateTime? reference,
  }) {
    final status = eventStatus(startAt, endAt, reference: reference);
    return switch (status) {
      EventGroupStatus.ended => l10n.eventStatusEnded,
      EventGroupStatus.ongoing => l10n.eventStatusOngoing,
      EventGroupStatus.upcoming => l10n.eventInvitationDaysRemaining(
          daysUntilEventStart(startAt, reference: reference),
        ),
    };
  }
}
