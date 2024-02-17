#include <Arduino.h>
#include <mqtt_service.h>

void setup() {
  Serial.begin(115200);
  // configurar os pinos
  pinMode(pinLedRed, OUTPUT);
  // teste do LED
  digitalWrite(pinLedRed, HIGH);
  delay(1000);
  digitalWrite(pinLedRed, LOW);

  // configurar WIFI
  setupWifi();
  // configurar MQTT
  setupMQTT();
}

void loop() {
  // conexão com o broker
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  // atuar no LED -> handleTopic()
  delay(500);
}
