#include "reminders.h"
#include "config.h"
#include <Arduino.h>
#include <time.h>
static Face* face = nullptr;
static MedicineState state = MED_IDLE;
static unsigned long stateStartTime = 0;
static unsigned long lastReminderBuzzTime = 0;
static bool firedToday[16]; 
static int lastCheckedDay = -1;
static void buzz(int durationMs)
{
  digitalWrite(BUZZER_PIN, HIGH);
  delay(durationMs);
  digitalWrite(BUZZER_PIN, LOW);
}
static void startReminder() 
{
  state = MED_REMINDING;
  stateStartTime = millis();
  lastReminderBuzzTime = millis();
  if (face != nullptr)
  {
    face->setExpression(EXPR_MEDICINE_REMINDER);
  }
  buzz(100);
  mqttClient.publish(TOPIC_MEDICINE_REMINDER, "reminder");
  mqttClient.publish(TOPIC_ROBOT_EMOTION, "excited");
  mqttClient.publish(TOPIC_ROBOT_STATUS, "reminding");
}
void remindersBegin(Face* faceRef) 
{
  face = faceRef;
  state = MED_IDLE;
  stateStartTime = millis();
  for (int i = 0; i < 16; i++) firedToday[i] = false;
  configTime(GMT_OFFSET_SEC, DAYLIGHT_OFFSET_SEC, NTP_SERVER);
}
void remindersOnButtonPressed()
{
  if (state == MED_REMINDING || state == MED_MISSED_SAD || state == MED_MISSED_ANGRY) {
    state = MED_TAKEN;
    stateStartTime = millis();

    if (face != nullptr) 
    {      
      face->setExpressionTimed(EXPR_LOVE, EXPRESSION_HOLD_MS);
    }
    mqttClient.publish(TOPIC_MEDICINE_TAKEN, "taken");
    mqttClient.publish(TOPIC_ROBOT_EMOTION, "love");
  }
}
void remindersForceTrigger()
{
  startReminder();
}
MedicineState remindersGetState()
{
  return state;
}
static void checkSchedule()
{
  struct tm timeInfo;
  if (!getLocalTime(&timeInfo, 5))
  {
    return; 
  }
  if (timeInfo.tm_yday != lastCheckedDay)
  {
    lastCheckedDay = timeInfo.tm_yday;
    for (int i = 0; i < 16; i++) firedToday[i] = false;
  }
 if (state != MED_IDLE) return; 

  for (unsigned int i = 0; i < MEDICINE_SCHEDULE_COUNT && i < 16; i++)
    {
    if (!firedToday[i] &&
        timeInfo.tm_hour == MEDICINE_SCHEDULE[i].hour &&
        timeInfo.tm_min == MEDICINE_SCHEDULE[i].minute)
    {
      firedToday[i] = true;
      startReminder();
      return; 
    }
  }
}
void remindersUpdate()
{
  unsigned long now = millis();
  checkSchedule();
  switch (state)
    {
    case MED_IDLE:
      break;
case MED_REMINDING:
      if (now - stateStartTime >= MEDICINE_REMINDER_REPEAT_MS)
      {
        state = MED_MISSED_SAD;
        stateStartTime = now;
        if (face != nullptr) face->setExpression(EXPR_SAD);
        mqttClient.publish(TOPIC_MEDICINE_MISSED, "missed");
        mqttClient.publish(TOPIC_ROBOT_EMOTION, "sad");
      }
      break;
    case MED_MISSED_SAD:
      if (now - lastReminderBuzzTime >= MEDICINE_REMINDER_REPEAT_MS) 
      {
        lastReminderBuzzTime = now;
        buzz(100);
      }
      if (now - stateStartTime >= MEDICINE_ANGRY_AFTER_MS) 
      {
        state = MED_MISSED_ANGRY;
        stateStartTime = now;
        if (face != nullptr) face->setExpression(EXPR_ANGRY);
mqttClient.publish(TOPIC_ROBOT_EMOTION, "angry");
      }
      break;
    case MED_MISSED_ANGRY:
      if (now - lastReminderBuzzTime >= MEDICINE_REMINDER_REPEAT_MS)
      {
        lastReminderBuzzTime = now;
        buzz(100);
      }
      break;
    case MED_TAKEN:
      if (now - stateStartTime >= EXPRESSION_HOLD_MS)
      {
        state = MED_IDLE;
        mqttClient.publish(TOPIC_ROBOT_STATUS, "idle");
      }
      break;
  }
}

