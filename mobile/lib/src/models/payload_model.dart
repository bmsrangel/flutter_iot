import 'dart:convert';

class PayloadModel {
  PayloadModel({
    required this.topic,
    required this.value,
  });

  final String topic;
  final num value;

  PayloadModel copyWith({
    String? topic,
    num? value,
  }) {
    return PayloadModel(
      topic: topic ?? this.topic,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'value': value,
    };
  }

  factory PayloadModel.fromMap(Map<String, dynamic> map) {
    return PayloadModel(
      topic: map['topic'] ?? '',
      value: map['value'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PayloadModel.fromJson(String source) =>
      PayloadModel.fromMap(json.decode(source));

  @override
  String toString() => 'Payload(topic: $topic, value: $value)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PayloadModel &&
        other.topic == topic &&
        other.value == value;
  }

  @override
  int get hashCode => topic.hashCode ^ value.hashCode;
}
