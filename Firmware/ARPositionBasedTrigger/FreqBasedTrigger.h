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
#include "SerialNumbers.h"

const float maxTriggerFreq = 100000; // maximum allowed trigger freq

class FreqBasedTrigger
{

private:
	float trigFreq = 10; // frequency of trigger events [Hz]
	uint32_t noShots = 0; // number of shots to fire
	// 0 means until serial interrupt
	// values > 0 correspond to number of shots
	float period = 100000; // time between two shots [micros]
	bool oldOutput = 0; // previous state of output line (falling and rising edge)
	bool flagRunning = 0; // indicates if trigger is running or not
	uint8_t trigPin = 19; // arduino pin on which we do trigger
public:
	FreqBasedTrigger();
	void triggerSignal();
	
	// set and get function for 
	void set_trigFreq(const float& _trigFreq);
	float get_trigFreq() const {return trigFreq;};

	void set_noShots(const uint32_t& _noShots);
	uint32_t get_noShots() const {return noShots;};

	void set_trigPin(const uint8_t& _trigPin);
	uint8_t get_trigPin() const {return trigPin;};

	void start(); // starts the trigger
};

#endif	
