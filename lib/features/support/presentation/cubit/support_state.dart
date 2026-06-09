import 'package:equatable/equatable.dart';

import '../../domain/entities/support_topic.dart';

enum SupportStatus { idle, submitting, success, failure }

class SupportState extends Equatable {
  const SupportState({
    this.email = '',
    this.topic = SupportTopic.general,
    this.message = '',
    this.status = SupportStatus.idle,
    this.errorMessage,
  });

  final String email;
  final SupportTopic topic;
  final String message;
  final SupportStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == SupportStatus.submitting;

  bool get canSubmit =>
      !isSubmitting &&
      email.trim().isNotEmpty &&
      message.trim().length >= 10;

  SupportState copyWith({
    String? email,
    SupportTopic? topic,
    String? message,
    SupportStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportState(
      email: email ?? this.email,
      topic: topic ?? this.topic,
      message: message ?? this.message,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, topic, message, status, errorMessage];
}
