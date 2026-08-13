#ifndef FALL_DETECTION_H
#define FALL_DETECTION_H

#include "face.h"
enum EmergencyType {
  EMERGENCY_FALL,
  EMERGENCY_KEYWORD_HELP,
  EMERGENCY_KEYWORD_OUCH,
  EMERGENCY_KEYWORD_THUD
};

// Call once in setup(), after the Face object exists.
void fallDetectionBegin(Face* faceRef);

// Call every loop(). Non-blocking. Drives the emergency alarm buzzer
// pattern and manages the timeout for emergency state.
void fallDetectionUpdate();
void fallDetectionOnEvent(EmergencyType type);

// Optional: check if currently in emergency state (for other modules
// that might want to know).
bool fallDetectionIsActive();

#endif // FALL_DETECTION_H
