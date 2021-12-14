/*
	File: FreqBasedTrigger.h
	Author: Urs Hofmann
	Mail: hofmannu@biomed.ee.ethz.ch
	Date: 14.04.2020
	Description: Temporal frequency domain trigger class for Teensy
*/

#ifndef FREQ_BASED_TRIGGER_H
#define FREQ_BASED_TRIGGER_H

#include "Arduino.h"
#include "PinMapping.h"

const uint32_t maxTriggerFreq = 100000; // maximum allowed trigger freq

class FreqBasedTrigger{

private:
	uint32_t trigFreq = 10; // frequency of trigger events [Hz]
	uint32_t noShots = 0; // number of shots to fire
	// 0 means until serial interrupt
	// values > 0 correspond to number of shots

	uint32_t period = 100000; // time between two shots [micros]
	bool oldOutput = 0; // previous state of output line (falling and rising edge)
	bool flagRunning = 0; // indicates if trigger is running or not

public:
	FreqBasedTrigger();
	void triggerSignal();
	void setTrigFreq(const uint32_t& _trigFreq);
	void setNoShots(const uint32_t& _noShots);
	void start();
	void stop();
	void clear_serial();
};

extern FreqBasedTrigger FBTx; 

#endif	
