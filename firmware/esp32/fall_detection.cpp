#include "fall_detection.h"
#include "config.h"
#include "mqtt_client.h"
#include <Arduino.h>
static const unsigned long BUZZER_ON_MS = 500UL;  
static const unsigned long BUZZER_OFF_MS = 300UL; 
static const unsigned long TOTAL_CYCLE_MS = BUZZER_ON_MS + BUZZER_OFF_MS;
static const unsigned long EMERGENCY_TIMEOUT_MS = 60000UL; 
static const unsigned long MQTT_ALERT_COOLDOWN_MS = 2000UL;
static Face* face = nullptr;
static bool emergencyActive = false;
static unsigned long emergencyStartedAt = 0;
static unsigned long lastMqttAlertTime = 0;
static EmergencyType lastEventType = EMERGENCY_FALL;
static const char* emergencyTypeToString(EmergencyType type)
{
  switch (type)
    {
    case EMERGENCY_FALL:
      return "fall_detected";
    case EMERGENCY_KEYWORD_HELP:
      return "keyword_help";
    case EMERGENCY_KEYWORD_OUCH:
      return "keyword_ouch";
    case EMERGENCY_KEYWORD_THUD:
      return "keyword_thud";
    default:
      return "unknown";
  }
}
void fallDetectionBegin(Face* faceRef)
{
  face = faceRef;
  emergencyActive = false;
  emergencyStartedAt = 0;
  lastMqttAlertTime = 0;
}
void fallDetectionUpdate()
{
  if (!emergencyActive) 
  {
    return;
  }
  unsigned long now = millis();
  if (now - emergencyStartedAt >= EMERGENCY_TIMEOUT_MS)
  {
    emergencyActive = false;
    digitalWrite(BUZZER_PIN, LOW); 
    return;
  }
unsigned long elapsedInCycle = (now - emergencyStartedAt) % TOTAL_CYCLE_MS;
  if (elapsedInCycle < BUZZER_ON_MS)
  {
    digitalWrite(BUZZER_PIN, HIGH); 
  }
  else 
  {
    digitalWrite(BUZZER_PIN, LOW);  
}
}
void fallDetectionOnEvent(EmergencyType type)
{
  unsigned long now = millis();
if (!emergencyActive) {
    emergencyActive = true;
    emergencyStartedAt = now;
    lastMqttAlertTime = 0; 
    lastEventType = type;
    if (face != nullptr) 
    {
      face->setExpression(EXPR_SHAKEN);
    }
  }
else
{ 
    lastEventType = type;
  }
if (now - lastMqttAlertTime >= MQTT_ALERT_COOLDOWN_MS)
{
    lastMqttAlertTime = now;
    mqttClient.publish(TOPIC_ROBOT_STATUS, "EMERGENCY");
    mqttClient.publish(TOPIC_ROBOT_EMOTION, emergencyTypeToString(type));
    Serial.print("FALL DETECTION: emergency alert - ");
    Serial.println(emergencyTypeToString(type));
  }
}
bool fallDetectionIsActive() 
{
  return emergencyActive;
}


