#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H
#include <WiFi.h>
#include "config.h"
typedef void (*WifiStatusHandler)(bool connected);
void wifiBegin();
void wifiUpdate();
bool wifiIsConnected();
String wifiGetLocalIP();
void wifiSetStatusHandler(WifiStatusHandler handler);
#endif 
