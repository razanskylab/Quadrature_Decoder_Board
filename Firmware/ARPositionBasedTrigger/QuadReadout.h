#include "WaitNS.h"
#include "PinMapping.h"
#include "Arduino.h"

#ifndef QUADREADOUT_H
#define QUADREADOUT_H

class QuadReadout{
public:
	QuadReadout(); // constructor
	~QuadReadout(); // destructor
	
	void reset_hctl(); // reset counter chip values to zero
	void update_counter();
	void startN(bool& lastState);
	void setXResolution(const uint32_t& _resolution);
	void setNTrigger(const uint32_t& _nTrigger);
	void triggerSignal(bool& lastState);
	uint16_t posCounter; // stores the 16 bit version of out readout
private:
	uint32_t encoderResolution = 2; // [1/µm]
	uint32_t resolution = 100; // step size of scan [µm]
	uint32_t nTrigger = 501; // number of trigger events per b scan
	uint32_t iTrigger = 0;
	uint32_t stepSize = 200; // step size in counter events of quad decoder board

	const uint32_t HCTL_CLOCK_SIGNAL = MEGA * 20; // DO NOT CHANGE!!!
};

#endif