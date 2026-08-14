#ifndef MQTT_CLIENT_H
#define MQTT_CLIENT_H
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include "config.h"
typedef void (MqttMessageHandler)(const char* topic, const char* payload);
class MqttClientWrapper
{
  public:
    MqttClientWrapper();
    void begin();                
    void update();                
    bool isConnected();
    void publish(const char* topic, const char* payload);
    void subscribe(const char* topic);
    void setMessageHandler(MqttMessageHandler handler);
private:
    WiFiClientSecure secureClient; 
    PubSubClient client;
    MqttMessageHandler messageHandler;
    unsigned long lastReconnectAttempt;
    static const unsigned long RECONNECT_INTERVAL_MS = 5000;
    void reconnect(); 
    static void staticCallback(char* topic, byte* payload, unsigned int length);
};
extern MqttClientWrapper mqttClient; 
#endif 

