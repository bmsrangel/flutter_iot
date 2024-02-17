#include <ArduinoJson.h>
#include <PubSubClient.h>
#include <wifi_config.h>

JsonDocument doc;
String serializedDoc;

WiFiClient espClient;
PubSubClient client(espClient);

void setupMQTT();
String buildMessage(byte* payload, unsigned int length);
void callback(char* topic, byte* payload, unsigned int length);
void reconnect();
void handleTopic(char* topic, byte* message);
void sendMessage(const char* topic, float value);

void setupMQTT() {
    client.setServer(mqtt_server, 1883);
    client.setCallback(callback);
    client.setKeepAlive(30);
}

String buildMessage(byte* payload, unsigned int length) {
    String message;
    for (uint i = 0; i < length; i++) {
        char c = (char)payload[i];
        message += c;
    }

    return message;
}

void callback(char* topic, byte* payload, unsigned int length) {
    Serial.print("Message arrived [");
    Serial.print(topic);
    Serial.print("] ");
    for (uint i = 0; i < length; i++) {
        Serial.print((char)payload[i]);
    }
    Serial.println();
    handleTopic(topic, payload);
}

void reconnect() {
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection... ");
        String clientId = "ESP8266Client-";
        clientId += String(random(0xffff), HEX);
        if (client.connect(clientId.c_str())) { // anonymous. For auth, use client.connect(clientId.c_str(), <username>, <password>)
            Serial.println("connected");
            client.subscribe(LED_RED_CM_TOPIC);
        }
        else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void handleTopic(char* topic, byte* message) {
    JsonDocument receivedDoc;

    DeserializationError err = deserializeJson(receivedDoc, message);

    if (err) {
        Serial.print(F("deserializeJson() failed with code "));
        Serial.println(err.c_str());
        return;
    }

    if (strcmp(topic, LED_RED_CM_TOPIC) == 0) {
        if (receivedDoc["value"] == 1) {
            digitalWrite(pinLedRed, HIGH);
            sendMessage(LED_RED_FB_TOPIC, 1);
        }
        if (receivedDoc["value"] == 0) {
            digitalWrite(pinLedRed, LOW);
            sendMessage(LED_RED_FB_TOPIC, 0);
        }
    }
}

void sendMessage(const char* topic, float value) {
    doc.clear();
    doc["value"] = value;
    serializeJson(doc, serializedDoc);
    client.publish(topic, serializedDoc.c_str(), true);
}
