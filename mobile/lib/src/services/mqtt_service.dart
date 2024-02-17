import 'dart:convert';

import 'package:mobile/src/models/message_model.dart';
import 'package:mobile/src/models/payload_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  MQTTService({
    required this.brokerUrl,
    this.port = 1883,
    this.keepAlivePeriod = 30,
    this.connectTimeoutPeriod = 2000,
    this.username,
    this.password,
  }) {
    _client = MqttServerClient(
      brokerUrl,
      'app',
    );
    _client.port = port;
    _client.keepAlivePeriod = keepAlivePeriod;
    _client.connectTimeoutPeriod = connectTimeoutPeriod;
    _client.autoReconnect = true;
  }

  final String brokerUrl;
  final int port;
  final int keepAlivePeriod;
  final int connectTimeoutPeriod;
  final String? username;
  final String? password;

  late final MqttClient _client;

  Future<bool> connect({required List<String> topics}) async {
    try {
      await _client.connect(username, password);
      for (final topic in topics) {
        _client.subscribe(topic, MqttQos.atLeastOnce);
      }
      return true;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  void publishMessage(MessageModel message) {
    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      final String topic = message.topic;
      final PayloadModel payload = message.payload;
      final Map<String, dynamic> payloadData = payload.toMap();
      final payloadString = jsonEncode(payloadData);
      final builder = MqttClientPayloadBuilder();
      builder.addString(payloadString);
      _client.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );
    }
  }

  Stream<MessageModel>? getMessages() {
    return _client.updates?.map(
      (event) {
        final receivedMessage = event.first;
        final topic = receivedMessage.topic;
        final payload = receivedMessage.payload as MqttPublishMessage;
        final payloadString = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );
        final Map<String, dynamic> payloadData = jsonDecode(payloadString);
        final MessageModel message = MessageModel(
          topic: topic,
          payload: PayloadModel.fromMap(payloadData),
        );
        return message;
      },
    );
  }
}
