/*
	superclass to allow different spatial and frequency domain triggers
	Author: Urs Hofmann
	Mail: mail@hofmannu.org
	Date: 25.03.2022
*/


#ifndef TRIGGERBOARD_H
#define TRIGGERBOARD_H

#include "SerialNumbers.h"
#include "FreqBasedTrigger.h"
#include "QuadReadout.h"

class TriggerBoard
{
private:
	FreqBasedTrigger freqTrigger;    //define two objects to the two classes
	QuadReadout posTrigger;

	// pin definitions
	const unsigned char TRIG_PINS[3] = {15, 18, 19}; // former TRIG_PINS, We use 19 connect to triggerPin 3. 
	const unsigned char STATUS_LEDS[4] = {27, 28, 29, 30};
	const unsigned char HCTL_CLOCK_PIN = 10;
	const unsigned char HCTL_RST_PIN = 11;
	const unsigned char HCTL_OE_PIN = 12;
	const unsigned char HCTL_SEL_PIN = 24;
	const unsigned char HCTL_MANUAL_RESET_PIN = 25; // push button connected here
	const unsigned char TRIG_COUNT_RESET = 26; // push button connected here
	const unsigned char OUTPUT_POSBOARD = 19; 

	// communication definition
	const uint8_t IDENTIFY = 00; // identify device
	
	const uint8_t SET_FREQ = 11; // defines frequency of temporal trigger
	const uint8_t SET_SPACE = 12; // defines frequency of spatial domain trigger
	const uint8_t SET_NFREQ = 13; // defimes the number of freq trigger
	const uint8_t SET_NSPACE = 14; // defines the number of spatial trigger events
	const uint8_t SET_PIN = 15; // defines on which SMA connector we trigger

	const uint8_t GET_FREQ = 21; // returns frequency of temporal trigger
	const uint8_t GET_SPACE = 22; // retruns frequency of spatial domain trigger
	const uint8_t GET_NFREQ = 23; // returns the number of frequency domain triggers
	const uint8_t GET_NSPACE = 24; // returns the number of spatial domain triggers
	const uint8_t GET_PIN = 25; // returns the pin number of the SMA connector

	const uint8_t START_FREQ = 31; // starts time domain trigger
	const uint8_t START_SPACE = 32; // starts spatial domain trigger
	
	const uint8_t STOP_FREQ = 41; // stops the time domain trigger
	const uint8_t STOP_SPACE = 42; // stops the spatial trigger

	const uint8_t OK = 91;
	const uint8_t WARNING = 92;
	const uint8_t ERROR = 93;
	const uint8_t UNKNOWN_COMMAND = 94;
	const uint16_t IDENTIFIER = 76; // identifier that we are the TriggerBoard

	uint8_t iPin = 2;

	void wait_for_serial(const uint8_t nSerial);
	void identify();

public:

	// class constructor and destructor
	TriggerBoard();
	void setup();
	void operate(); // runs the main control loop of the state machine


};

#endif