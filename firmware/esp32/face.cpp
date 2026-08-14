#include "face.h"
#include <Arduino.h>
#include <math.h>
static const int EYE_W = 24;
static const int EYE_H = 28;
static const int EYE_Y = 14;
static const int LEFT_EYE_X = 26;
static const int RIGHT_EYE_X = 128 - 26 - EYE_W;
static const int MOUTH_Y = 52;
Face::Face(Adafruit_SH1106G* displayRef)
{
  display = displayRef;
  currentExpression = EXPR_NEUTRAL;
  previousExpression = EXPR_NEUTRAL;
  lastFrameTime = 0;
  lastBlinkTime = 0;
  expressionStartTime = 0;
  timedExpressionUntil = 0;
  isBlinking = false;
  blinkStartTime = 0;
  animFrame = 0;
  chargePercent = 0;
}
void Face::begin()
{
  lastFrameTime = millis();
  lastBlinkTime = millis();
  expressionStartTime = millis();
}
void Face::setExpression(Expression e) 
{
  currentExpression = e;
  expressionStartTime = millis();
  timedExpressionUntil = 0; 
  animFrame = 0;
}
void Face::setExpressionTimed(Expression e, unsigned long holdMs) 
{
  previousExpression = currentExpression;
  currentExpression = e;
  expressionStartTime = millis();
  timedExpressionUntil = millis() + holdMs;
  animFrame = 0;
}
void Face::setChargePercent(int percent)
{
  chargePercent = constrain(percent, 0, 100);
}
void Face::drawEye(int x, int y, int w, int h, int radius, bool filled) 
{
  if (filled) {
    display->fillRoundRect(x, y, w, h, radius, SH110X_WHITE);
  } else {
    display->drawRoundRect(x, y, w, h, radius, SH110X_WHITE);
  }
}
void Face::drawMouth(int style) 
{
  int cx = 64;
  switch (style)
    {
    case 0:
      display->drawLine(cx - 8, MOUTH_Y, cx + 8, MOUTH_Y, SH110X_WHITE);
      break;
    case 1: 
      { 
      display->drawLine(cx - 10, MOUTH_Y, cx - 3, MOUTH_Y + 5, SH110X_WHITE);
      display->drawLine(cx - 3, MOUTH_Y + 5, cx + 3, MOUTH_Y + 5, SH110X_WHITE);
      display->drawLine(cx + 3, MOUTH_Y + 5, cx + 10, MOUTH_Y, SH110X_WHITE);
      break;
    }
    case 2:
      {
      display->drawLine(cx - 10, MOUTH_Y + 5, cx - 3, MOUTH_Y, SH110X_WHITE);
      display->drawLine(cx - 3, MOUTH_Y, cx + 3, MOUTH_Y, SH110X_WHITE);
      display->drawLine(cx + 3, MOUTH_Y, cx + 10, MOUTH_Y + 5, SH110X_WHITE);
      break;
    }
   case 3: 
      display->fillCircle(cx, MOUTH_Y + 2, 4, SH110X_WHITE);
      break;
    case 4: 
      display->drawLine(cx - 4, MOUTH_Y, cx + 4, MOUTH_Y, SH110X_WHITE);
      break;
  }
}
void Face::drawHeart(int cx, int cy)
{
  display->fillCircle(cx - 3, cy, 3, SH110X_WHITE);
  display->fillCircle(cx + 3, cy, 3, SH110X_WHITE);
  display->fillTriangle(cx - 6, cy + 1, cx + 6, cy + 1, cx, cy + 8, SH110X_WHITE);
}
void Face::drawPillIcon(int x, int y)
{
  display->drawRoundRect(x, y, 20, 10, 5, SH110X_WHITE);
  display->drawLine(x + 10, y, x + 10, y + 9, SH110X_WHITE);
  display->fillRoundRect(x + 10, y, 10, 10, 5, SH110X_WHITE);
}
void Face::drawNeutral()
{
  drawEye(LEFT_EYE_X, EYE_Y, EYE_W, EYE_H);
  drawEye(RIGHT_EYE_X, EYE_Y, EYE_W, EYE_H);
  drawMouth(0);
}
void Face::drawHappy() 
{
  int bounce = (animFrame / 5) % 2 == 0 ? 0 : -2; 
  drawEye(LEFT_EYE_X, EYE_Y + bounce, EYE_W, EYE_H - 6);
  drawEye(RIGHT_EYE_X, EYE_Y + bounce, EYE_W, EYE_H - 6);
  drawMouth(1);
}
void Face::drawSad()
{
  drawEye(LEFT_EYE_X, EYE_Y + 4, EYE_W, EYE_H - 6, 4);
  drawEye(RIGHT_EYE_X, EYE_Y + 4, EYE_W, EYE_H - 6, 4);
  drawMouth(2);
}
void Face::drawSleep() 
{
  drawEye(LEFT_EYE_X, EYE_Y + 12, EYE_W, 4, 2);
  drawEye(RIGHT_EYE_X, EYE_Y + 12, EYE_W, 4, 2);
  drawMouth(4);
  int zFrame = (animFrame / 8) % 3;
  display->setTextSize(1);
  display->setTextColor(SH110X_WHITE);
  if (zFrame >= 0) { display->setCursor(96, 8);  display->print("z"); }
  if (zFrame >= 1) { display->setCursor(103, 3); display->print("z"); }
  if (zFrame >= 2) { display->setCursor(110, -1);display->print("Z"); }
}
void Face::drawThinking() 
{
  drawEye(LEFT_EYE_X, EYE_Y - 3, EYE_W, EYE_H);
  drawEye(RIGHT_EYE_X + 3, EYE_Y, EYE_W - 4, EYE_H - 4);
  drawMouth(4);
}
void Face::drawExcited()
{
  drawEye(LEFT_EYE_X - 2, EYE_Y - 2, EYE_W + 4, EYE_H + 4, 8);
  drawEye(RIGHT_EYE_X - 2, EYE_Y - 2, EYE_W + 4, EYE_H + 4, 8);
  drawMouth(1);
  if ((animFrame / 6) % 2 == 0) {
    display->drawPixel(14, 6, SH110X_WHITE);
    display->drawPixel(114, 6, SH110X_WHITE);
  }
}
void Face::drawAngry()
{
  drawEye(LEFT_EYE_X, EYE_Y + 2, EYE_W, EYE_H - 4, 5);
  drawEye(RIGHT_EYE_X, EYE_Y + 2, EYE_W, EYE_H - 4, 5);
  display->drawLine(LEFT_EYE_X - 2, EYE_Y - 2, LEFT_EYE_X + EYE_W, EYE_Y + 4, SH110X_WHITE);
  display->drawLine(RIGHT_EYE_X, EYE_Y + 4, RIGHT_EYE_X + EYE_W + 2, EYE_Y - 2, SH110X_WHITE);
  drawMouth(2);
}
void Face::drawLove()
{
  drawHappy(); 
  drawHeart(64, 8);
}
void Face::drawDizzy()
{
  float angle = (animFrame * 20) * PI / 180.0;
  int cxL = LEFT_EYE_X + EYE_W / 2;
  int cxR = RIGHT_EYE_X + EYE_W / 2;
  int cy = EYE_Y + EYE_H / 2;
  drawEye(LEFT_EYE_X, EYE_Y, EYE_W, EYE_H, 6, false); 
  drawEye(RIGHT_EYE_X, EYE_Y, EYE_W, EYE_H, 6, false);
  int rx = 8, ry = 8;
  display->fillCircle(cxL + cos(angle) * rx, cy + sin(angle) * ry, 2, SH110X_WHITE);
  display->fillCircle(cxR + cos(angle + PI) * rx, cy + sin(angle + PI) * ry, 2, SH110X_WHITE);
  drawMouth(4);
}
void Face::drawListening() {
  drawNeutral(); 
  int base = 60;
  for (int i = 0; i < 3; i++) {
    int h = 2 + ((animFrame + i * 3) % 6);
    display->fillRect(56 + i * 8, base - h, 3, h, SH110X_WHITE);
  }
}
void Face::drawTalking()
{
  drawEye(LEFT_EYE_X, EYE_Y, EYE_W, EYE_H);
  drawEye(RIGHT_EYE_X, EYE_Y, EYE_W, EYE_H);

  if ((animFrame / 4) % 2 == 0)
  {
    drawMouth(3);
  }
  else
  {
    drawMouth(0);
  }
}
void Face::drawWink() {
  drawEye(LEFT_EYE_X, EYE_Y, EYE_W, EYE_H); 
  drawEye(RIGHT_EYE_X, EYE_Y + 12, EYE_W, 4, 2); 
  drawMouth(1);
}

void Face::drawLookLeft() 
{
  drawEye(LEFT_EYE_X - 6, EYE_Y, EYE_W, EYE_H);
  drawEye(RIGHT_EYE_X - 6, EYE_Y, EYE_W, EYE_H);
  drawMouth(0);
}

void Face::drawLookRight() 
{
  drawEye(LEFT_EYE_X + 6, EYE_Y, EYE_W, EYE_H);
  drawEye(RIGHT_EYE_X + 6, EYE_Y, EYE_W, EYE_H);
  drawMouth(0);
}
oid Face::drawShaken() 
{
  drawEye(LEFT_EYE_X - 3, EYE_Y - 3, EYE_W + 6, EYE_H + 6, 12);
  drawEye(RIGHT_EYE_X - 3, EYE_Y - 3, EYE_W + 6, EYE_H + 6, 12);
  drawMouth(1);
  display->fillRoundRect(60, MOUTH_Y + 4, 8, 6, 3, SH110X_WHITE);
}

void Face::drawMedicineReminder()
{
  drawExcited();
  drawPillIcon(54, 2);
}
void Face::drawCharging()
{
  int cx = 64, cy = 28, r = 20;
  int totalDots = 24;
  int litDots = map(chargePercent, 0, 100, 0, totalDots);
  for (int i = 0; i < totalDots; i++) {
    float a = (i * 360.0 / totalDots) * PI / 180.0;
    int px = cx + cos(a) * r;
    int py = cy + sin(a) * r;
    if (i < litDots)
    {
      display->fillCircle(px, py, 1, SH110X_WHITE);
    } else
    {
      display->drawPixel(px, py, SH110X_WHITE);
    }
  }
  display->setTextSize(1);
  display->setCursor(cx - 10, cy - 4);
  display->print(chargePercent);
  display->print("%");
  drawMouth(4);
}
void Face::drawLoading()
{
  int cx = 64, cy = 28;
  float a = (animFrame * 15) * PI / 180.0;
  for (int i = 0; i < 4; i++) {
    float ai = a + i * (PI / 2);
    int px = cx + cos(ai) * 14 - 3;
    int py = cy + sin(ai) * 14 - 3;
    drawEye(px, py, 6, 6, 2);
  }
}
void Face::maybeAutoBlink()
{
  if (currentExpression != EXPR_NEUTRAL && currentExpression != EXPR_HAPPY &&
      currentExpression != EXPR_LISTENING && currentExpression != EXPR_TALKING)
  {
    return;
  }
  unsigned long now = millis();
  if (!isBlinking && now - lastBlinkTime >= BLINK_INTERVAL_MS)
  {
    isBlinking = true;
    blinkStartTime = now;
  }
}
void Face::update()
{
  unsigned long now = millis();
  if (now - lastFrameTime >= ANIMATION_FRAME_MS) {
    animFrame++;
    lastFrameTime = now;
  }
  if (timedExpressionUntil != 0 && now >= timedExpressionUntil)
  {
    currentExpression = previousExpression;
    timedExpressionUntil = 0;
    animFrame = 0;
  }
maybeAutoBlink();
  display->clearDisplay();
  if (isBlinking)
  {
    drawEye(LEFT_EYE_X, EYE_Y + 12, EYE_W, 4, 2);
    drawEye(RIGHT_EYE_X, EYE_Y + 12, EYE_W, 4, 2);
    drawMouth(0);
    if (now - blinkStartTime >= 150)
    {
      isBlinking = false;
      lastBlinkTime = now;
    }
  } else
  {
    switch (currentExpression)
      {
      case EXPR_NEUTRAL:          
        drawNeutral(); break;
      case EXPR_HAPPY:                    
        drawHappy(); break;
      case EXPR_SAD:              
        drawSad(); break;
      case EXPR_SLEEP:            
        drawSleep(); break;
      case EXPR_THINKING:       
        drawThinking(); break;
      case EXPR_EXCITED:          
        drawExcited(); break;
      case EXPR_ANGRY:            
        drawAngry(); break;
      case EXPR_LOVE:            
        drawLove(); break;
      case EXPER_DIZZY:
        drawDizzy(); break;
      case EXPR_LISTENING:           
        drawListening(); break;
      case EXPR_TALKING:             
        drawTalking(); break;
      case EXPR_WINK:                
        drawWink(); break;
      case EXPR_LOOK_LEFT:           
        drawLookLeft(); break;
      case EXPR_LOOK_RIGHT:          
        drawLookRight(); break;
      case EXPR_SHAKEN:              
        drawShaken(); break;
      case EXPR_MEDICINE_REMINDER:   
        drawMedicineReminder(); break;
      case EXPR_CHARGING:            
        drawCharging(); break;
      case EXPR_LOADING:             
        drawLoading(); break;
      default: drawNeutral(); break;
    }
  }
  display->display();
}
