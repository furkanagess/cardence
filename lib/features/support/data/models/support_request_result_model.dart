import '../../domain/entities/support_request_result.dart';

class SupportRequestResultModel {
  const SupportRequestResultModel({
    required this.requestId,
    required this.email,
    required this.topic,
    required this.createdAt,
  });

  final String requestId;
  final String email;
  final String topic;
  final DateTime createdAt;

  factory SupportRequestResultModel.fromJson(Map<String, dynamic> json) {
    final requestId = json['requestId']?.toString() ?? '';
    final createdAtRaw = json['createdAt']?.toString();
    return SupportRequestResultModel(
      requestId: requestId,
      email: json['email']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now().toUtc()
          : DateTime.now().toUtc(),
    );
  }

  SupportRequestResult toEntity() => SupportRequestResult(
        requestId: requestId,
        email: email,
        topic: topic,
        createdAt: createdAt,
      );
}
