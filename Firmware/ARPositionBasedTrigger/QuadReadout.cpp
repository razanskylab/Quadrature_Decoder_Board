#include "QuadReadout.h"

QuadReadout::QuadReadout(){
	// define all input pins to get position from counter
	for (unsigned char i = 0; i < 8; i++)
    pinMode(pinTable[i], INPUT_PULLUP);
  
	// define reset pin
	pinMode(HCTL_RST_PIN, OUTPUT);
	digitalWriteFast(HCTL_RST_PIN, HIGH);

	pinMode(HCTL_OE_PIN, OUTPUT);
	digitalWriteFast(HCTL_OE_PIN, HIGH);

	pinMode(HCTL_SEL_PIN, OUTPUT);
	digitalWriteFast(HCTL_SEL_PIN, HIGH);

	// define two knob pins as inputs
	pinMode(HCTL_MANUAL_RESET_PIN, INPUT);
	pinMode(TRIG_COUNT_RESET, INPUT);

	reset_hctl();

	// PWM clock for HCTL
  analogWriteFrequency(HCTL_CLOCK_PIN, HCTL_CLOCK_SIGNAL);
  analogWrite(HCTL_CLOCK_PIN, 128); // set to 50% duty cycle

}

// class destructor
QuadReadout::~QuadReadout(){
	// nothing here yet but an empty destructor
}

// reset counter chip values to zero
void QuadReadout::reset_hctl(){
	digitalWriteFast(HCTL_RST_PIN, LOW); // start reset
 	 WAIT_96_NS;
  digitalWriteFast(HCTL_RST_PIN, HIGH);
  return;
}

void QuadReadout::update_counter()
{
	digitalWriteFast(HCTL_OE_PIN, LOW); // start read
	WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; // allow high bit to be stable
	digitalWriteFast(HCTL_SEL_PIN, LOW); // select high bit
	WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; // allow high bit to be stable

	((unsigned char *)&posCounter)[1] = GPIOD_PDIR & 0xFF; // read msb

	digitalWriteFast(HCTL_SEL_PIN, HIGH); // select low bit
	// get msb, write directly to counter, also turns uint to int...lots of magic here
	// we do this after changing pin, as data now needs time to settle...
	// ((uint8_t *)&counter)[1] = msb;

	// WAIT_24_NS; WAIT_48_NS; // allow high bit to be stable
	WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; WAIT_48_NS; // allow high bit to be stable
	((unsigned char *)&posCounter)[0] = GPIOD_PDIR & 0xFF; // read lsb
	// finish read out
	digitalWriteFast(HCTL_OE_PIN, HIGH);
	
	return;
}

// runs position based trigger until Serial interrupt arrives
void QuadReadout::startN(bool& lastState){
	//update_counter();
	update_counter();
	digitalWriteFast(STATUS_LEDS[3], HIGH);
	uint16_t lastTrigger = posCounter;
	uint16_t upperLim;
	uint16_t lowerLim;
	iTrigger = 0;
	// induce initial trigger event
	triggerSignal(lastState);
	do{
		// calculate new boundaries
		upperLim = lastTrigger + stepSize;
		lowerLim = lastTrigger - stepSize;

		// check for overflow
		if ((upperLim > lastTrigger) && (lowerLim < lastTrigger)){
			// we are not expecting an overflow so value should be in boundaries
			do{
				update_counter();
			}while((posCounter < upperLim) && (posCounter > lowerLim));

			// update lastTrigger depending on direction
			if (posCounter < upperLim) // we moved in lower direction
				lastTrigger -= stepSize;
			else // we moved in upper direction
				lastTrigger += stepSize;

		}else{ // we are expecting an overflow	
			do{
				update_counter();
			}while(!((posCounter <= lowerLim) && (posCounter >= upperLim)));

			// update last trigger depending on direction
			if ((posCounter - upperLim) < (lowerLim - posCounter))
				lastTrigger += stepSize;
			else
				lastTrigger -= stepSize;
		}

		// induce trigger event
		triggerSignal(lastState);
	}while(iTrigger < nTrigger);
	digitalWriteFast(STATUS_LEDS[3], LOW);
	// delayMicroseconds(20);
	// triggerSignal(lastState);
}

// define the resolution of the scan pattern in microm
void QuadReadout::setXResolution(const uint32_t& _resolution){
	// Check if resolution is within desired range
	if (_resolution < 1){
		resolution = 1; 
		// is defined as the minimum resolution
	}
	else if (_resolution > 50000){
		resolution = 50000;
	}
	else{
		resolution = _resolution;
	}
	
	stepSize = resolution * encoderResolution; // convert resolution into counterLimit
}

// define the number of trigger events
void QuadReadout::setNTrigger(const uint32_t& _nTrigger){
	nTrigger = _nTrigger;
}

void QuadReadout::triggerSignal(bool& lastState){
	iTrigger++;
	lastState = !lastState;
	digitalWriteFast(OUTPUT_POSBOARD, lastState);
	return;
}