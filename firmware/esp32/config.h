#ifndef CONFIG_H
#define CONFIG_H
#define OLED_SDA_PIN   8      // ESP32-S3 default I2C SDA (change if wired differently)
#define OLED_SCL_PIN   9      // ESP32-S3 default I2C SCL (change if wired differently)
#define OLED_WIDTH     128
#define OLED_HEIGHT    64
#define OLED_I2C_ADDR  0x3C   // Most SH1106 1.3" boards use 0x3C (some use 0x3D) 
#define BUZZER_PIN     4
#define MEDICINE_BUTTON_PIN 5
#define WIFI_SSID      "YOUR_WIFI_SSID"
#define WIFI_PASSWORD  "YOUR_WIFI_PASSWORD"
#define MQTT_BROKER    "your-broker-url.hivemq.cloud"
#define MQTT_PORT      8883
#define MQTT_USERNAME  "your_mqtt_username"
#define MQTT_PASSWORD  "your_mqtt_password"
#define MQTT_CLIENT_ID "vitalcode_robot_01"
#define TOPIC_ROBOT_STATUS      "robot/status"
#define TOPIC_ROBOT_EMOTION     "robot/emotion"
#define TOPIC_MEDICINE_REMINDER "robot/medicine/reminder"
#define TOPIC_MEDICINE_TAKEN    "robot/medicine/taken"
#define TOPIC_MEDICINE_MISSED   "robot/medicine/missed"
#define TOPIC_ROBOT_COMMAND     "robot/command"
// -------------- TIMING --------------
#define BLINK_INTERVAL_MS        4000   // how often the robot blinks when idle
#define ANIMATION_FRAME_MS       40     // base frame speed for animations (lower = faster)
#define MEDICINE_REMINDER_REPEAT_MS 60000UL // repeat reminder if not confirmed (1 min, adjust later)
#define MEDICINE_ANGRY_AFTER_MS  180000UL   // escalate SAD -> ANGRY after this long unconfirmed (3 min, adjust)
#define EXPRESSION_HOLD_MS       2500   // how long a reaction (e.g. LOVE) shows before returning to idle
struct ReminderTime
{
  int hour;
  int minute;
};
static const ReminderTime MEDICINE_SCHEDULE[] =
{
  {8, 0},
  {14, 0},
  {20, 0}
};
#define MEDICINE_SCHEDULE_COUNT (sizeof(MEDICINE_SCHEDULE) / sizeof(ReminderTime))
#define NTP_SERVER      "pool.ntp.org"
#define GMT_OFFSET_SEC  19800      
#define DAYLIGHT_OFFSET_SEC 0
#endif 
