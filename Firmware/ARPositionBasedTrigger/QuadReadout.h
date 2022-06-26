#include "WaitNS.h"
#include "PinMapping.h"
#include "Arduino.h"

#ifndef QUADREADOUT_H
#define QUADREADOUT_H
#define LED_PORT GPIOD_PDOR  //Xiang

class QuadReadout{
private:
	uint32_t encoderResolution = 2; // [1/µm]
	uint32_t resolution = 100; // step size of scan [µm]
	uint32_t nTrigger = 501; // number of trigger events per b scan
	uint32_t iTrigger = 0;
	uint32_t stepSize = 200; // step size in counter events of quad decoder board
	uint8_t trigPin = 19;

	const uint32_t HCTL_CLOCK_SIGNAL = MEGA * 20; // DO NOT CHANGE!!!
	uint16_t posCounter; // stores the 16 bit version of out readout


public:
	QuadReadout(); // constructor
	~QuadReadout(); // destructor
	
	void reset_hctl(); // reset counter chip values to zero
	void update_counter();
	void startN(bool& lastState);
	void set_nTrigger(const uint32_t& _nTrigger);
	void triggerSignal(bool& lastState);

	// get and set functions
	void set_resolution(const uint32_t _resolution);
	uint32_t get_resolution() const {return resolution;};
	void set_trigPin(const uint8_t _trigPin);
	uint8_t get_trigPin() const {return trigPin;};
	uint32_t get_nTrigger() const {return nTrigger;};

};

#endif