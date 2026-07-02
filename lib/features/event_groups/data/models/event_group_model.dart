import 'dart:convert';

import '../../domain/entities/event_group.dart';

class EventGroupModel {
  EventGroupModel({
    required this.id,
    required this.name,
    this.location,
    this.description,
    required this.startAt,
    this.endAt,
    this.status = EventGroupStatus.upcoming,
    this.eventDate,
    this.photoUrl,
    this.invalidCardIds = const [],
  });

  final String id;
  final String name;
  final String? location;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final EventGroupStatus status;
  final DateTime? eventDate;
  final String? photoUrl;
  final List<String> invalidCardIds;

  factory EventGroupModel.fromEntity(EventGroup entity) {
    return EventGroupModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      description: entity.description,
      startAt: entity.startAt,
      endAt: entity.endAt,
      status: entity.status,
      eventDate: entity.eventDate,
      photoUrl: entity.photoUrl,
      invalidCardIds: entity.invalidCardIds,
    );
  }

  EventGroup toEntity() => EventGroup(
        id: id,
        name: name,
        location: location,
        description: description,
        startAt: startAt,
        endAt: endAt,
        status: status,
        photoUrl: photoUrl,
        invalidCardIds: invalidCardIds,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
        'startAt': startAt.toUtc().toIso8601String(),
        if (endAt != null) 'endAt': endAt!.toUtc().toIso8601String(),
        'status': status.name,
        if (eventDate != null)
          'eventDate': eventDate!.toUtc().toIso8601String(),
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (invalidCardIds.isNotEmpty) 'invalidCardIds': invalidCardIds,
      };

  factory EventGroupModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['Id'];
    final name = json['name'] ?? json['Name'];
    final location = json['location'] ?? json['Location'];
    final description = json['description'] ?? json['Description'];
    final photoUrl = json['photoUrl'] ?? json['PhotoUrl'];
    final rawStartAt = json['startAt'] ?? json['StartAt'];
    final rawEndAt = json['endAt'] ?? json['EndAt'];
    final rawStatus = json['status'] ?? json['Status'];
    final rawInvalidCardIds = json['invalidCardIds'] ?? json['InvalidCardIds'];
    final rawDate = json['eventDate'] ?? json['EventDate'];

    DateTime? eventDate;
    if (rawDate != null && rawDate.toString().isNotEmpty) {
      eventDate = DateTime.tryParse(rawDate.toString());
    }
    final startAt = rawStartAt != null && rawStartAt.toString().isNotEmpty
        ? DateTime.tryParse(rawStartAt.toString())
        : eventDate;
    DateTime? endAt;
    if (rawEndAt != null && rawEndAt.toString().isNotEmpty) {
      endAt = DateTime.tryParse(rawEndAt.toString());
    }

    return EventGroupModel(
      id: id?.toString() ?? '',
      name: name?.toString() ?? '',
      location: location?.toString(),
      description: description?.toString(),
      startAt: startAt ?? DateTime.now(),
      endAt: endAt,
      status: _parseStatus(rawStatus?.toString()),
      eventDate: eventDate,
      photoUrl: photoUrl?.toString(),
      invalidCardIds: _parseStringList(rawInvalidCardIds),
    );
  }

  static EventGroupStatus _parseStatus(String? value) {
    return EventGroupStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EventGroupStatus.upcoming,
    );
  }

  static List<String> _parseStringList(Object? value) {
    if (value is! List) return [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String toJsonString() => jsonEncode(toJson());

  static List<EventGroupModel> listFromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => EventGroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJsonString(List<EventGroupModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }
}
