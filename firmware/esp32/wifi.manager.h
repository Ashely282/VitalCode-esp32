#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H
#include <WiFi.h>
#include "config.h"

// WIFI MODULE
// Manages the ESP32's WiFi station connection using the credentials
// already defined in config.h (WIFI_SSID / WIFI_PASSWORD). Nothing
// is hard-coded here - same convention as mqtt_client.h.
// NON-BLOCKING: wifiBegin() kicks off the connection attempt and
// returns immediately (no while-loop, no delay() waiting for
// WL_CONNECTED). wifiUpdate() is called every loop() and:
//   - notices when the link comes up or drops
//   - retries at most once every WIFI_RECONNECT_INTERVAL_MS while
//     disconnected (same "one attempt per interval, never block"
//     pattern MqttClientWrapper::reconnect() uses in mqtt_client.cpp)
// COMPATIBLE WITH MQTT: mqttClient.update() already tolerates WiFi
// being down - PubSubClient's connect() simply fails over TCP and
// MqttClientWrapper::reconnect() retries later on its own timer, so
// there's no hard dependency between the two modules. wifiUpdate()
// just needs to be called every loop() (alongside mqttClient.update())
// so the underlying link is kept alive / retried for MQTT to use.
// NOTE ON THE FILENAME: this is intentionally wifi_manager.h/.cpp,
// NOT wifi.h/wifi.cpp. On case-insensitive filesystems (Windows,
// default macOS) a sketch file literally named wifi.h can collide
// with the ESP32 core's own <WiFi.h> header (which main.ino already
// includes), causing confusing "redefinition" / missing-declaration
// compile errors. wifi_manager.h avoids that clash entirely.
// ============================================================
// Optional: get notified whenever the connection state changes, e.g.
// to publish robot/status over MQTT or drive a face expression.
// Safe to leave unset (nullptr) if you don't need it.
typedef void (*WifiStatusHandler)(bool connected);
// Call once in setup() - replaces a manual WiFi.begin()/while() block.
// Returns immediately; does not block waiting for a connection.
void wifiBegin();
// Call every loop(). Non-blocking: only touches the radio at most
// once every WIFI_RECONNECT_INTERVAL_MS while disconnected.
void wifiUpdate();
// True if currently associated to the AP (WiFi.status() == WL_CONNECTED).
bool wifiIsConnected();
// Current local IP as a string, or "0.0.0.0" if not connected yet.
String wifiGetLocalIP();
// Register a callback for connect/disconnect transitions (optional).
void wifiSetStatusHandler(WifiStatusHandler handler);
#endif 
