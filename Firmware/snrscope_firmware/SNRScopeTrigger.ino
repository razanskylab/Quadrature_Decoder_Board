/*
	SNRScopeTrigger.ino
	a simple teensy based waveform generator controllable from matlab

*/

#define OUTPUT_PIN 19
#include "FreqBasedTrigger.h"
FreqBasedTrigger freqBasedTrig(OUTPUT_PIN); // class used for frequency based triggering

void setup()
{
	// make led ready and blink
	pinMode(LED_BUILTIN, OUTPUT);
	digitalWriteFast(LED_BUILTIN, HIGH);
	delay(500);
	digitalWriteFast(LED_BUILTIN, LOW);
}

void clear_serial()
{
	while(Serial.available() > 0)
		Serial.read();

	return;
}

// serial read of a uint32
uint32_t serialReadUint32()
{
	char uintBuffer[4];
	Serial.readBytes(uintBuffer, 4);
	uint32_t value = (uintBuffer[3] << 24) + (uintBuffer[2] << 16) + 
	  	(uintBuffer[1] << 8) + uintBuffer[0];
	return value;
}

// wait until a certain amount of serial bytes is available
void wait_for_serial(int nSerial)
{
	while (Serial.available() < nSerial){
		delayMicroseconds(1); // do nothing but wait
	}
	return;
} 

void loop()
{

	// clear every fucking serial until an f appeared
	do
	{
		wait_for_serial(1);
	}while(Serial.read() != 'f');

	wait_for_serial(8);

  uint32_t freq = serialReadUint32();
  uint32_t noShots = serialReadUint32();

  // Let computer know what we understood
  Serial.print("f: ");
  Serial.print(freq);
  Serial.print(" x ");
  Serial.print(noShots);
  Serial.print("\r");
  freqBasedTrig.setTrigFreq(freq);
  freqBasedTrig.setNoShots(noShots);
    
  char input = 'x';
  while (input != 'o')
  {
    wait_for_serial(1);

    input = Serial.read();
    if (input == 'x'){
    	Serial.print("r\r"); // let matlab know that we are ready to go
      freqBasedTrig.start();
    }
    else if (input == 'o')
    {
    	freqBasedTrig.stop();
    }
  }
	

	clear_serial();

}