#ifndef REMINDERS_H
#define REMINDERS_H
#include "face.h"
#include "mqtt_client.h"
enum MedicineState 
{
  MED_IDLE,
  MED_REMINDING,     
  MED_MISSED_SAD,    
  MED_MISSED_ANGRY,   
  MED_TAKEN            
};
void remindersBegin(Face* faceRef);

void remindersUpdate();

void remindersOnButtonPressed();

void remindersForceTrigger();

MedicineState remindersGetState();

#endif 

