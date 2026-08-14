#include "medicine_verification.h"
#include "config.h"
#include "reminders.h"
#include "mqtt_client.h"
#include <Arduino.h>
static const unsigned long VERIFICATION_TIMEOUT_MS = 300000UL;
static Face* face = nullptr;
static VerificationStatus status = VERIFY_NONE;
static MedicineState lastReminderState = MED_IDLE;
static unsigned long pendingSince = 0;
void medicineVerificationBegin(Face* faceRef)
{
 face = faceRef;
 status = VERIFY_NONE;
 lastReminderState = remindersGetState();
pendingSince = 0;
}
void medicineVerificationUpdate() 
{
 MedicineState current = remindersGetState();
 if (current == MED_TAKEN && lastReminderState != MED_TAKEN)
{
    status = VERIFY_PENDING;
    pendingSince = millis();
    mqttClient.publish(TOPIC_ROBOT_STATUS, "awaiting_verification");
  }
lastReminderState = current;
if (status == VERIFY_PENDING)
{
 if (millis() - pendingSince >= VERIFICATION_TIMEOUT_MS) 
  {
   status = VERIFY_TIMED_OUT;
   mqttClient.publish(TOPIC_MEDICINE_TAKEN, "unverified");
    }
  }
}
void medicineVerificationOnCommand(const char* payload)
{
 if (status != VERIFY_PENDING) return;
 if (strcmp(payload, "verify_taken") == 0) 
{
status = VERIFY_CONFIRMED;
mqttClient.publish(TOPIC_MEDICINE_TAKEN, "verified");
 if (face != nullptr)
 {
 face->setExpressionTimed(EXPR_LOVE, EXPRESSION_HOLD_MS);
  }
 }
}

VerificationStatus medicineVerificationGetStatus() {
  return status;
}

