#ifndef FACE_H
#define FACE_H
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include "config.h"
enum Expression
{
  EXPR_NEUTRAL,
  EXPR_HAPPY,
  EXPR_SAD,
  EXPR_SLEEP,
  EXPR_THINKING,
  EXPR_EXCITED,
  EXPR_ANGRY,
  EXPR_LOVE,
  EXPR_DIZZY,
  EXPR_LISTENING,
  EXPR_TALKING,
  EXPR_WINK,
  EXPR_LOOK_LEFT,
  EXPR_LOOK_RIGHT,
  EXPR_SHAKEN,
  EXPR_MEDICINE_REMINDER,
  EXPR_CHARGING,
  EXPR_LOADING,
};
    void drawEye(int x, int y, int w, int h, int radius = 6, bool filled = true);
    void drawNeutral();
    void drawHappy();
    void drawSad();
    void drawSleep();
    void drawThinking();
    void drawExcited();
    void drawAngry();
    void drawLove();
    void drawDizzy();
    void drawListening();
    void drawTalking();
    void drawWink();
    void drawLookLeft();
    void drawLookRight();
    void drawShaken();
    void drawMedicineReminder();
    void drawCharging();
    void drawLoading();
    void drawMouth(int style); 
    void maybeAutoBlink();
    void drawHeart(int cx, int cy);
    void drawPillIcon(int x, int y);
};
#endif 

