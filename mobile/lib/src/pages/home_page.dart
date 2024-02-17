import 'package:flutter/material.dart';
import 'package:mobile/src/services/mqtt_service.dart';
import 'package:mobile/src/stores/led_red_store.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LedRedStore _ledRedStore;
  late final MQTTService _mqttService;

  @override
  void initState() {
    super.initState();
    _mqttService = MQTTService(brokerUrl: 'broker.emqx.io');
    _ledRedStore = LedRedStore(_mqttService);
    _ledRedStore.addListener(getMessagesListener);
    _ledRedStore.connect();
  }

  @override
  void dispose() {
    _ledRedStore.removeListener(getMessagesListener);
    _ledRedStore.dispose();
    super.dispose();
  }

  void getMessagesListener() {
    if (_ledRedStore.isConnected) {
      _ledRedStore.getMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT App'),
      ),
      body: AnimatedBuilder(
        animation: _ledRedStore,
        builder: (_, __) {
          if (_ledRedStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (_ledRedStore.error.isNotEmpty) {
            return Center(
              child: Text(_ledRedStore.error),
            );
          } else {
            return SwitchListTile.adaptive(
              secondary: CircleAvatar(
                radius: 16.0,
                backgroundColor:
                    _ledRedStore.isLedOn ? Colors.red : Colors.grey,
              ),
              title: const Text('LED Red'),
              value: _ledRedStore.ledCommand,
              onChanged: (value) => _ledRedStore.toggleLed(),
            );
          }
        },
      ),
    );
  }
}
