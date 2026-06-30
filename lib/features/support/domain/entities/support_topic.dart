/// Destek talebi konusu – domain enum (framework bağımsız).
enum SupportTopic {
  general,
  bug,
  feature,
  account,
  wallet,
}

extension SupportTopicApi on SupportTopic {
  String get apiValue {
    switch (this) {
      case SupportTopic.general:
        return 'general';
      case SupportTopic.bug:
        return 'bug';
      case SupportTopic.feature:
        return 'feature';
      case SupportTopic.account:
        return 'account';
      case SupportTopic.wallet:
        return 'wallet';
    }
  }
}
