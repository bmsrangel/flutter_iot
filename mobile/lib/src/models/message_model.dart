import 'dart:convert';

import 'package:mobile/src/models/payload_model.dart';

class MessageModel {
  final String topic;
  final PayloadModel payload;
  MessageModel({
    required this.topic,
    required this.payload,
  });

  MessageModel copyWith({
    String? topic,
    PayloadModel? payload,
  }) {
    return MessageModel(
      topic: topic ?? this.topic,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'payload': payload.toMap(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      topic: map['topic'] ?? '',
      payload: PayloadModel.fromMap(map['payload']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));

  @override
  String toString() => 'MessageModel(topic: $topic, payload: $payload)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageModel &&
        other.topic == topic &&
        other.payload == payload;
  }

  @override
  int get hashCode => topic.hashCode ^ payload.hashCode;
}
