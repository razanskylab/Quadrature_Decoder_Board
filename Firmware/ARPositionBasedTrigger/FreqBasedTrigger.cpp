#include "FreqBasedTrigger.h"

//static void trigger_outer();

// Initialize frequency based trigger
FreqBasedTrigger::FreqBasedTrigger(void)
{
	pinMode(OUTPUT_POSBOARD, OUTPUT);
	pinMode(LED_BUILTIN, OUTPUT);
	digitalWriteFast(OUTPUT_POSBOARD, oldOutput);
}

// Define the trigger frequency
void FreqBasedTrigger::setTrigFreq(const uint32_t& _trigFreq)
{
	// Check for upper and lower limit
	if (_trigFreq == 0){
		trigFreq = 1;
	}else if (_trigFreq > maxTriggerFreq){ // upper limit for trigger frequency
		trigFreq = maxTriggerFreq;
	}else{
	  trigFreq = _trigFreq; 
	}
  
	period = 1000000 / double(trigFreq); // trigger period in µs
	return;
}

// define number of shots to fire
void FreqBasedTrigger::setNoShots(const uint32_t& _noShots)
{
	noShots = _noShots;
	return;
}

// Start trigger if not running
void FreqBasedTrigger::start()
{
	digitalWriteFast(LED_BUILTIN, HIGH);

	// noShots == 0 means we will fire forever, so don't increase the counter
	flagRunning = 1;
	uint32_t counter = 0;

	// clear serial input
	clear_serial();

	while (flagRunning)
	{
		triggerSignal();

		if (noShots > 0) // if finite number of shots
		{
			counter++;
			if (counter >= noShots)
				flagRunning = 0;
		}
		else // serial interrupt 
		{
			if (Serial.available() > 0)
				flagRunning = 0;
		}

		if (period < 16383)
			delayMicroseconds(period);
		else
			delay(period / 1000);
	}

	digitalWriteFast(LED_BUILTIN, LOW);
	return;
}

// Stop trigger if running
void FreqBasedTrigger::stop()
{
	digitalWriteFast(LED_BUILTIN, LOW);
	return;
}

// Switch polarity of output signal
void FreqBasedTrigger::triggerSignal()
{
	oldOutput = !oldOutput;
	digitalWriteFast(OUTPUT_POSBOARD, oldOutput);
	digitalWriteFast(LED_BUILTIN, oldOutput);
	return;
}

// clear all serial content at input
void FreqBasedTrigger::clear_serial()
{
	while(Serial.available() > 0)
		Serial.read();

	return;
}