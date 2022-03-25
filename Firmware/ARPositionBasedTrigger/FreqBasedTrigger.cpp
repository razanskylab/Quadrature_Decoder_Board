#include "FreqBasedTrigger.h"


// Initialize frequency based trigger
FreqBasedTrigger::FreqBasedTrigger(void)
{
	pinMode(LED_BUILTIN, OUTPUT);
}

// Define the trigger frequency [Hz]
void FreqBasedTrigger::set_trigFreq(const float& _trigFreq)
{
	// Check for upper and lower limit
	if (_trigFreq == 0)
	{
		trigFreq = 1;
	} 

	else if (_trigFreq > maxTriggerFreq)
	{ // upper limit for trigger frequency
		trigFreq = maxTriggerFreq;
	}
	else
	{
	  trigFreq = _trigFreq; 
	}
  	period = 1000000.0f / trigFreq; // trigger period in µs
	return;
}

// define number of shots to fire
void FreqBasedTrigger::set_noShots(const uint32_t& _noShots)
{
	noShots = _noShots;
	return;
}

void FreqBasedTrigger::set_trigPin(const uint8_t& _trigPin)
{
	trigPin = _trigPin;
	return;
}


// Start trigger if not running
void FreqBasedTrigger::start()
{
	digitalWriteFast(27, HIGH);

	// noShots == 0 means we will fire forever, so don't increase the counter
	flagRunning = 1;
	uint32_t counter = 0;

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
			{
				flagRunning = 0;
				uint8_t retVal = SerialNumbers::read_uint8();
			}
		}

		if (period < 16383)
			delayMicroseconds(period);
		else
			delay(period / 1000);
	}
	digitalWriteFast(27, LOW);
	return;
}

// Switch polarity of output signal
void FreqBasedTrigger::triggerSignal()
{
	oldOutput = !oldOutput;
	digitalWriteFast(trigPin, oldOutput);
	return;
}
