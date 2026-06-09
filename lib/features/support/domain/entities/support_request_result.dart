import 'package:equatable/equatable.dart';

class SupportRequestResult extends Equatable {
  const SupportRequestResult({
    required this.requestId,
    required this.email,
    required this.topic,
    required this.createdAt,
  });

  final String requestId;
  final String email;
  final String topic;
  final DateTime createdAt;

  @override
  List<Object?> get props => [requestId, email, topic, createdAt];
}
