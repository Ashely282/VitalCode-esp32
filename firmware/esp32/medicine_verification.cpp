#include "config.h"
#include "reminders.h"
#include "mqtt_client.h"
#include <Arduino.h>
Medicine verification functions
static const unsigned long VERIFICATION_TIMEOUT_MS = 300000UL;
static Face* face = nullptr;
static VerificationStatus status = VERIFY_NONE;
static MedicineState lastReminderState = MED_IDLE;
static unsigned long pendingSince = 0;

void medicineVerificationBegin(Face* faceRef) {
  face = faceRef;
  status = VERIFY_NONE;
  lastReminderState = remindersGetState();
  pendingSince = 0;
}
void medicineVerificationUpdate() {
  MedicineState current = remindersGetState();

  // Edge-detect the moment reminders.cpp reports a dose taken (i.e. it
  // just transitioned INTO MED_TAKEN). This starts a fresh verification
  // window regardless of any previous status, since this is a new dose.
  if (current == MED_TAKEN && lastReminderState != MED_TAKEN) {
    status = VERIFY_PENDING;
    pendingSince = millis();
    mqttClient.publish(TOPIC_ROBOT_STATUS, "awaiting_verification");
  }
  lastReminderState = current;
if (status == VERIFY_PENDING) {
    if (millis() - pendingSince >= VERIFICATION_TIMEOUT_MS) {
      status = VERIFY_TIMED_OUT;
      mqttClient.publish(TOPIC_MEDICINE_TAKEN, "unverified");
    }
  }
}

void medicineVerificationOnCommand(const char* payload) {
  if (status != VERIFY_PENDING) return;

  if (strcmp(payload, "verify_taken") == 0) {
    status = VERIFY_CONFIRMED;
    mqttClient.publish(TOPIC_MEDICINE_TAKEN, "verified");

    if (face != nullptr) {
      // Reuse the existing "positive confirmation" expression and hold
      // time - no new expression or timing constant is introduced.
      face->setExpressionTimed(EXPR_LOVE, EXPRESSION_HOLD_MS);
    }
  }
}

VerificationStatus medicineVerificationGetStatus() {
  return status;
}

