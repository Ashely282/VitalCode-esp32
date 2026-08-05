#include <Wire.h>
#include <U8g2lib.h>

// SH1106 128x64 I2C OLED
U8G2_SH1106_128X64_NONAME_F_HW_I2C display(U8G2_R0, U8X8_PIN_NONE);

void happyEyes() {
  display.clearBuffer();

  // Left eye
  display.drawDisc(38, 30, 10);

  // Right eye
  display.drawDisc(90, 30, 10);

  display.sendBuffer();
}

void blinkEyes() {
  display.clearBuffer();

  // Closed eyes
  display.drawLine(28, 30, 48, 30);
  display.drawLine(80, 30, 100, 30);

  display.sendBuffer();
}

void setup() {
  display.begin();
}

void loop() {

  happyEyes();
  delay(2500);

  blinkEyes();
  delay(180);

  happyEyes();
  delay(3000);

}
