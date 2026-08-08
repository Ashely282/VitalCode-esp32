#ifndef FACE_H
#define FACE_H

#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include "config.h"

// ============================================================
// FACE MODULE
// Draws the robot's face (eyes + mouth) on the OLED and handles
// all expressions + animations. Non-blocking: update() is called
// every loop() and uses millis() internally, never delay().
// ============================================================

enum Expression {
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
  EXPR_LOADING
};

// look like consistent rounded squares, never circles/plain blocks.
    void drawEye(int x, int y, int w, int h, int radius = 6, bool filled = true);

    // --- per-expression drawers ---
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

    // --- shared helpers ---
    void drawMouth(int style); // 0=flat 1=smile 2=frown 3=talking-O 4=small
    void maybeAutoBlink();
    void drawHeart(int cx, int cy);
    void drawPillIcon(int x, int y);
};

#endif // FACE_H

