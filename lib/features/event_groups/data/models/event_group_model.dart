import 'dart:convert';

import '../../domain/entities/event_group.dart';

class EventGroupModel {
  EventGroupModel({
    required this.id,
    required this.name,
    this.location,
    this.eventDate,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String? location;
  final DateTime? eventDate;
  final String? photoUrl;

  factory EventGroupModel.fromEntity(EventGroup entity) {
    return EventGroupModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      eventDate: entity.eventDate,
      photoUrl: entity.photoUrl,
    );
  }

  EventGroup toEntity() => EventGroup(
        id: id,
        name: name,
        location: location,
        eventDate: eventDate,
        photoUrl: photoUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (location != null) 'location': location,
        if (eventDate != null)
          'eventDate': eventDate!.toUtc().toIso8601String(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

  factory EventGroupModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['Id'];
    final name = json['name'] ?? json['Name'];
    final location = json['location'] ?? json['Location'];
    final photoUrl = json['photoUrl'] ?? json['PhotoUrl'];
    final rawDate = json['eventDate'] ?? json['EventDate'];

    DateTime? eventDate;
    if (rawDate != null && rawDate.toString().isNotEmpty) {
      eventDate = DateTime.tryParse(rawDate.toString());
    }

    return EventGroupModel(
      id: id?.toString() ?? '',
      name: name?.toString() ?? '',
      location: location?.toString(),
      eventDate: eventDate,
      photoUrl: photoUrl?.toString(),
    );
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
