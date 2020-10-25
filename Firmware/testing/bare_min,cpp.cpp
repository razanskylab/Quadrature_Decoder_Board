#include <Arduino.h> // always required when using platformio

#define MEGA 1000000L
#define NOP __asm__ __volatile__ ("nop\n\t")
//
#define WAIT_1_NOP NOP;
#define WAIT_2_NOP NOP; NOP;
#define WAIT_4_NOP NOP; NOP; NOP; NOP;
#define WAIT_5_NOP NOP; NOP; NOP; NOP; NOP;
#define WAIT_10_NOP WAIT_5_NOP; WAIT_5_NOP;
#define WAIT_25_NOP WAIT_10_NOP; WAIT_10_NOP; WAIT_5_NOP;
#define WAIT_50_NOP WAIT_25_NOP; WAIT_25_NOP;



//#define WAIT_40_NS WAIT_20_NS; WAIT_20_NS;
//#define WAIT_60_NS WAIT_20_NS; WAIT_20_NS; WAIT_20_NS;
//#define WAIT_80_NS WAIT_40_NS; WAIT_40_NS;
//#define WAIT_100_NS WAIT_80_NS; WAIT_20_NS;

void setup() {
  // put your setup code here, to run once:
  // HCTL_CLOCK_PIN = 10;
  // HCTL_CLOCK_SIGNAL = MEGA*25
  // analogWriteFrequency(1, MEGA*10);
  analogWriteFrequency(10, MEGA*12);
  analogWrite(10, 256/2); // set to 50% duty cycle
  // analogWrite(1, 128); // set to 50% duty cycle
  pinMode(11, OUTPUT);
  Serial.begin(9600);
}

FASTRUN void loop() {
  
  while(true){ //Loop inside void loop () avoids the overhead of the main loop
    for (uint32_t i = 0; i < 10000000; i++)
    {
      WAIT_50_NOP;
      digitalWriteFast(11, LOW);
      WAIT_50_NOP;
      digitalWriteFast(11, HIGH);
    }
    
    Serial.println(tempmonGetTemp());
  }

}