#ifndef MEDICINE_VERIFICATION_H
#define MEDICINE_VERIFICATION_H
#include "face.h"
enum VerificationStatus
{
  VERIFY_NONE,        
  VERIFY_PENDING,
  VERIFY_CONFIRMED,   
  VERIFY_TIMED_OUT    
};
void medicineVerificationBegin(Face* faceRef);
void medicineVerificationUpdate();
void medicineVerificationOnCommand(const char* payload);
VerificationStatus medicineVerificationGetStatus();
#endif 
