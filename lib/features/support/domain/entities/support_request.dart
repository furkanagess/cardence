import 'package:equatable/equatable.dart';

import 'support_topic.dart';

class SupportRequest extends Equatable {
  const SupportRequest({
    required this.email,
    required this.topic,
    required this.message,
  });

  final String email;
  final SupportTopic topic;
  final String message;

  bool get isValid =>
      _isValidEmail(email) &&
      message.trim().length >= 10 &&
      message.trim().length <= 2000;

  static bool _isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 320) return false;
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed);
  }

  @override
  List<Object?> get props => [email, topic, message];
}
