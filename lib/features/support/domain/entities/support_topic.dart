/// Destek talebi konusu – domain enum (framework bağımsız).
enum SupportTopic {
  general,
  bug,
  feature,
  account,
  wallet,
}

extension SupportTopicLabels on SupportTopic {
  String get label {
    switch (this) {
      case SupportTopic.general:
        return 'Genel soru';
      case SupportTopic.bug:
        return 'Hata bildirimi';
      case SupportTopic.feature:
        return 'Özellik önerisi';
      case SupportTopic.account:
        return 'Hesap ve giriş';
      case SupportTopic.wallet:
        return 'Cüzdan ve abonelik';
    }
  }

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
