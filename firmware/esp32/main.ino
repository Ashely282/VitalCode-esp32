#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <WiFi.h>
#include "config.h"
#include "face.h"
#include "mqtt_client.h"
#include "reminders.h"
#include "medicine_verification.h"
Adafruit_SH1106G display(OLED_WIDTH, OLED_HEIGHT, &Wire, -1);
Face face(&display);
bool lastButtonState = HIGH;
void onMqttMessage(const char* topic, const char* payload)
{
  Serial.print("MQTT message on ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(payload);
  if (strcmp(topic, TOPIC_ROBOT_COMMAND) == 0)
  {
    if (strcmp(payload, "remind") == 0)
  {
    remindersForceTrigger();
    else if (strcmp(payload,"verify_taken")==0)
    {
      medicineVerificationOnCommand(payload);
  }
 }
}
void checkMedicineButton()
{
  bool buttonState = digitalRead(MEDICINE_BUTTON_PIN);
  if (lastButtonState == HIGH && buttonState == LOW)
  {
    remindersOnButtonPressed();
  }
  lastButtonState = buttonState;
}
void setup()
{
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  pinMode(MEDICINE_BUTTON_PIN, INPUT_PULLUP);
  Wire.begin(OLED_SDA_PIN, OLED_SCL_PIN);
  if (!display.begin(OLED_I2C_ADDR, true))
  {
Serial.println("OLED not found! Check wiring/address in config.h");
    while (true) delay(1000);
  }
  display.clearDisplay();
  display.display();
  face.begin();
  face.setExpression(EXPR_NEUTRAL);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  unsigned long wifiStart = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - wifiStart < 15000)
    {
    Serial.print(".");
    delay(250);
  }
  Serial.println();
  if (WiFi.status() == WL_CONNECTED)
  {
    Serial.print("WiFi connected. IP: ");
    Serial.println(WiFi.localIP());
  } else
  {
    Serial.println("WiFi not connected - will keep retrying via MQTT reconnect logic.");
  }
  mqttClient.begin();
  mqttClient.setMessageHandler(onMqttMessage);
  remindersBegin(&face);
  medicineVerificationBegin(&face);
  Serial.println("VITALCODE robot online.");
}
void loop()
{
  mqttClient.update();       
  checkMedicineButton();
  remindersUpdate();   
  medicineVerificationUpdate();
  face.update();             
}
