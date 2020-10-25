#include <Arduino.h>
#include "quad_decoder.h"
quad::QuadDecoder QD;

void setup() {
  QD.Setup();
}

FASTRUN void loop() {
  while(true){ // loop has overhead, while true is faster
    QD.Handle_Matlab_Interface();
  } // while true
}