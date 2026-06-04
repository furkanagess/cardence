import 'dart:convert';

import '../../domain/entities/event_group.dart';

class EventGroupModel {
  EventGroupModel({required this.id, required this.name});

  final String id;
  final String name;

  factory EventGroupModel.fromEntity(EventGroup entity) {
    return EventGroupModel(id: entity.id, name: entity.name);
  }

  EventGroup toEntity() => EventGroup(id: id, name: name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory EventGroupModel.fromJson(Map<String, dynamic> json) {
    return EventGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
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
