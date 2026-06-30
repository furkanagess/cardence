import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/support_topic.dart';

String supportTopicLabel(AppLocalizations l10n, SupportTopic topic) {
  switch (topic) {
    case SupportTopic.general:
      return l10n.genelSoru;
    case SupportTopic.bug:
      return l10n.hataBildirimi;
    case SupportTopic.feature:
      return l10n.zelliknerisi;
    case SupportTopic.account:
      return l10n.hesapVeGiri;
    case SupportTopic.wallet:
      return l10n.czdanVeAbonelik;
  }
}
