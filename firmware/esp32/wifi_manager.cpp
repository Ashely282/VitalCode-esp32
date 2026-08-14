#include "wifi_manager.h"
#include <Arduino.h>
static const unsigned long WIFI_RECONNECT_INTERVAL_MS = 10000UL;
static const unsigned long WIFI_CONNECT_LOG_INTERVAL_MS = 500UL; 
static unsigned long lastReconnectAttempt = 0;
static unsigned long lastConnectLogTime = 0;
static bool wasConnected = false;
static WifiStatusHandler statusHandler = nullptr;
static void notifyStatus(bool connected)
{
  if (statusHandler != nullptr) 
  {
    statusHandler(connected);
 }
}
void wifiBegin()
{
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(false);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi: connecting to ");
  Serial.println(WIFI_SSID);
  unsigned long now = millis();
  lastReconnectAttempt = now;
  lastConnectLogTime = now;
  wasConnected = false;
}
void wifiUpdate()
{
  unsigned long now = millis();
  bool isConnected = (WiFi.status() == WL_CONNECTED);
  if (isConnected && !wasConnected) 
  {
    wasConnected = true;
    Serial.print("WiFi connected. IP: ");
    Serial.println(WiFi.localIP());
    notifyStatus(true);
  }
  else if (!isConnected && wasConnected) 
  {
    wasConnected = false;
    Serial.println("WiFi: connection lost - will retry.");
    notifyStatus(false);
  }
if (!isConnected)
{
 if (now - lastReconnectAttempt >= WIFI_RECONNECT_INTERVAL_MS)
   {
      lastReconnectAttempt = now;
      Serial.println("WiFi: retrying connection...");
      WiFi.disconnect();
      WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
 } 
 else if (now - lastConnectLogTime >= WIFI_CONNECT_LOG_INTERVAL_MS) 
 {
  lastConnectLogTime = now;
 Serial.print(".");
 }
}
}
bool wifiIsConnected() 
{
 return WiFi.status() == WL_CONNECTED;
}
String wifiGetLocalIP() 
{
 if (wifiIsConnected()) 
{
return WiFi.localIP().toString();
 }
return String("0.0.0.0");
}
void wifiSetStatusHandler(WifiStatusHandler handler)
{
  statusHandler = handler;
}
