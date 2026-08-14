#ifndef FALL_DETECTION_H
#define FALL_DETECTION_H
#include "face.h"
enum EmergencyType
{
  EMERGENCY_FALL,
  EMERGENCY_KEYWORD_HELP,
  EMERGENCY_KEYWORD_OUCH,
  EMERGENCY_KEYWORD_THUD
};
void fallDetectionBegin(Face* faceRef);
void fallDetectionUpdate();
void fallDetectionOnEvent(EmergencyType type);
bool fallDetectionIsActive();
#endif
