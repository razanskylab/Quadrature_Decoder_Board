/* 

	--> put this on the teensy
	
	STATUS_LEDS[0] --> waiting for Serial input	
	STATUS_LEDS[1] --> we are in time domain trigger mode
	STATUS_LEDS[2] --> we are in position based trigger mode

	Changelog:
		Switched serial communcation from uint16_t to uint32_t
		Took out 1 second delay in time domain tigger before start

*/
#include "TriggerBoard.h"

TriggerBoard instance;

// setting up board
void setup()
{
	instance.setup();
}

void loop()
{
	instance.operate();
}