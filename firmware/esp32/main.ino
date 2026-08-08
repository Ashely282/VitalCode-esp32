#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <WiFi.h>
#include "config.h"
#include "face.h"
#include "mqtt_client.h"
#include "reminders.h"

// ============================================================
// VITALCODE ROBOT - Main Sketch
// Ties together: OLED face, expressions/animations, medicine
// reminder logic (reminders.cpp), buzzer feedback, and MQTT.
// Everything in loop() is non-blocking (millis()-based).
// ============================================================
Adafruit_SH1106G display(OLED_WIDTH, OLED_HEIGHT, &Wire, -1);
Face face(&display);

bool lastButtonState = HIGH; // pull-up: HIGH = not pressed

// ---------------- MQTT message handling ----------------
void onMqttMessage(const char* topic, const char* payload) {
  Serial.print("MQTT message on ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(payload);

  if (strcmp(topic, TOPIC_ROBOT_COMMAND) == 0) {
    // App can publish "remind" to robot/command to trigger a reminder manually,
    // useful for testing without waiting for the schedule.
    if (strcmp(payload, "remind") == 0) {
      remindersForceTrigger();
    }
  }
}
void checkMedicineButton() {
  bool buttonState = digitalRead(MEDICINE_BUTTON_PIN);
  if (lastButtonState == HIGH && buttonState == LOW) { // pressed (active-low w/ pull-up)
    remindersOnButtonPressed();
  }
  lastButtonState = buttonState;
}

// ---------------- Setup / Loop ----------------

void setup() {
  Serial.begin(115200);

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  pinMode(MEDICINE_BUTTON_PIN, INPUT_PULLUP);

  Wire.begin(OLED_SDA_PIN, OLED_SCL_PIN);

  if (!display.begin(OLED_I2C_ADDR, true)) {
Serial.println("OLED not found! Check wiring/address in config.h");
    while (true) delay(1000);
  }
  display.clearDisplay();
  display.display();

  face.begin();
  face.setExpression(EXPR_NEUTRAL);

  // ---- WiFi ----
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  unsigned long wifiStart = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - wifiStart < 15000) {
    Serial.print(".");
    delay(250); // acceptable here: only during setup(), not in loop()
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("WiFi connected. IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("WiFi not connected - will keep retrying via MQTT reconnect logic.");
  }
// ---- MQTT ----
  mqttClient.begin();
  mqttClient.setMessageHandler(onMqttMessage);

  // ---- Medicine reminders (schedule lives in config.h) ----
  remindersBegin(&face);

  Serial.println("VITALCODE robot online.");
}

void loop() {
  mqttClient.update();       // non-blocking MQTT connect/loop
  checkMedicineButton();
  remindersUpdate();         // non-blocking schedule + state machine
  face.update();             // non-blocking animation/expression rendering
}
