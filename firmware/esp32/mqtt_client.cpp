#include "mqtt_client.h"
#include <Arduino.h>
static MqttClientWrapper* activeInstance = nullptr;
MqttClientWrapper mqttClient; 
MqttClientWrapper::MqttClientWrapper()
  : client(secureClient), messageHandler(nullptr), lastReconnectAttempt(0)
{
  activeInstance = this;
}
void MqttClientWrapper::begin()
{
  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(MqttClientWrapper::staticCallback);
  secureClient.setInsecure();
}
Serial.print("MQTT: connecting to broker...");
  if (client.connect(MQTT_CLIENT_ID, MQTT_USERNAME, MQTT_PASSWORD))
  {
    Serial.println("connected.");
    client.subscribe(TOPIC_ROBOT_COMMAND);
    client.publish(TOPIC_ROBOT_STATUS, "online");
  }
  else
  {
    Serial.print("failed, rc=");
    Serial.print(client.state());
    Serial.println(" - will retry.");
  }
}
void MqttClientWrapper::update() 
{
  if (!client.connected())
  {
    reconnect();
  } 
  else 
  {
    client.loop(); 
  }
}
bool MqttClientWrapper::isConnected()
{
  return client.connected();
}
void MqttClientWrapper::publish(const char* topic, const char* payload) 
{
  if (client.connected())
  {
    client.publish(topic, payload);
  }
}
void MqttClientWrapper::subscribe(const char* topic)
{
  if (client.connected()) 
  {
    client.subscribe(topic);
  }
}
bool MqttClientWrapper::isConnected()
{
  return client.connected();
}
void MqttClientWrapper::publish(const char* topic, const char* payload) 
{
  if (client.connected()) 
  {
    client.publish(topic, payload);
  }
}
void MqttClientWrapper::subscribe(const char* topic) 
{
  if (client.connected())
  {
    client.subscribe(topic);
  }
}
void MqttClientWrapper::setMessageHandler(MqttMessageHandler handler)
{
  messageHandler = handler;
}
void MqttClientWrapper::staticCallback(char* topic, byte* payload, unsigned int length)
{
  char message[128];
  unsigned int len = (length < sizeof(message) - 1) ? length : sizeof(message) - 1;
  memcpy(message, payload, len);
  message[len] = '\0';
if (activeInstance != nullptr && activeInstance->messageHandler != nullptr)
{
    activeInstance->messageHandler(topic, message);
  }
}
