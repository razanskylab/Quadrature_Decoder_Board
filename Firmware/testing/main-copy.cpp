// #include "..\lib\teensy_lib.cpp"
#include <Arduino.h> // always required when using platformio

#define MEGA 1000000L

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setup() {
  // PWM clock for HCTL
  analogWriteFrequency(10, MEGA*50);
  analogWrite(10, 200); // set to 50% duty cycle
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void loop()
{
} // close void loop
