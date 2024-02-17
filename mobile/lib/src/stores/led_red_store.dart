import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/src/models/message_model.dart';
import 'package:mobile/src/models/payload_model.dart';
import 'package:mobile/src/services/mqtt_service.dart';

class LedRedStore extends ChangeNotifier {
  LedRedStore(this._mqttService);

  final MQTTService _mqttService;

  bool isLoading = false;
  bool isConnected = false;
  StreamSubscription<MessageModel>? _messagesSubscription;

  bool isLedOn = false;
  bool ledCommand = false;
  String error = '';

  final ledCommandTopic = '/led/red/cm';
  final ledFeedbackTopic = '/led/red/fb';

  Future<void> connect() async {
    try {
      error = '';
      isLoading = true;
      notifyListeners();
      isConnected = await _mqttService.connect(topics: [
        ledFeedbackTopic,
      ]);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void getMessages() {
    _messagesSubscription = _mqttService
        .getMessages()
        ?.where((message) => message.topic == ledFeedbackTopic)
        .listen((event) {
      isLedOn = event.payload.value == 1;
      notifyListeners();
    });
  }

  void toggleLed() {
    ledCommand = !ledCommand;
    notifyListeners();
    final message = MessageModel(
      topic: ledCommandTopic,
      payload: PayloadModel(
        topic: ledCommandTopic,
        value: ledCommand ? 1 : 0,
      ),
    );
    _mqttService.publishMessage(message);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
