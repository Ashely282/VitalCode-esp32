#ifndef MEDICINE_VERIFICATION_H
#define MEDICINE_VERIFICATION_H

#include "face.h"
enum VerificationStatus {
  VERIFY_NONE,        
  VERIFY_PENDING,
  VERIFY_CONFIRMED,   
  VERIFY_TIMED_OUT    
};
void medicineVerificationBegin(Face* faceRef);

// Call every loop(). Non-blocking. Polls remindersGetState() to notice
// new "taken" events and checks the verification timeout.
void medicineVerificationUpdate();

// Call from main.ino's onMqttMessage() whenever a message arrives on
// TOPIC_ROBOT_COMMAND (alongside the existing "remind" handling). Any
// payload other than "verify_taken" is ignored, so it's safe to call
// unconditionally for every command message.
void medicineVerificationOnCommand(const char* payload);

// Optional: current verification status, for future use elsewhere.
VerificationStatus medicineVerificationGetStatus();

#endif // MEDICINE_VERIFICATION_H
