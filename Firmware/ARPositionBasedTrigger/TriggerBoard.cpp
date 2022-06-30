#include "TriggerBoard.h"

// just an empty constructor
TriggerBoard::TriggerBoard()
{
	freqTrigger.set_trigPin(TRIG_PINS[iPin]);
	posTrigger.set_trigPin(TRIG_PINS[iPin]);
}

void TriggerBoard::setup()
{
	// define all of our boards output pins and set them to an initial low
	#pragma unroll
	for (unsigned char iPin = 0; iPin < 3; iPin++)
	{
		pinMode(TRIG_PINS[iPin], OUTPUT);
		digitalWrite(TRIG_PINS[iPin], LOW);
	}

	// define all of the LED pins as outputs and set them to an initial low
	#pragma unroll
	for (unsigned char iPin = 0; iPin < 4; iPin++)
	{
		pinMode(STATUS_LEDS[iPin], OUTPUT);
		digitalWrite(STATUS_LEDS[iPin], LOW);
	}

	// start serial stream to computer
	Serial.begin(115200);

	return;

}

// wait until a certain number of serial bytes arrived
void TriggerBoard::wait_for_serial(const uint8_t nSerial)
{
	while(Serial.available() < nSerial)
	{
		delayMicroseconds(1);
	}
	return;
}

// identifies the trigger board
void TriggerBoard::identify()
{
	SerialNumbers::send_uint16(IDENTIFIER);
	#pragma unroll
	for (uint8_t idx = 0; idx < 3; idx++)
		digitalWrite(STATUS_LEDS[idx], HIGH);
	
	delay(250);
	#pragma unroll
	for (uint8_t idx = 0; idx < 3; idx++)
		digitalWrite(STATUS_LEDS[idx], LOW);
	
	return;
}

void TriggerBoard::operate()
{
	// await next instruction command
	wait_for_serial(1);
	uint8_t command = SerialNumbers::read_uint8();

	if (command == IDENTIFY)
	{
		identify();
		SerialNumbers::send_uint8(OK);
	}
	else if (command == SET_FREQ)
	{
		const float trigFreq = SerialNumbers::read_float();
		freqTrigger.set_trigFreq(trigFreq);
		SerialNumbers::send_float(freqTrigger.get_trigFreq());
		SerialNumbers::send_uint8(OK);
	}
	else if (command == SET_SPACE)
	{
		const uint32_t trigSteps = SerialNumbers::read_uint32();
		posTrigger.set_resolution(trigSteps);
		SerialNumbers::send_uint32(posTrigger.get_resolution());
		SerialNumbers::send_uint8(OK);
	}
	else if (command == GET_FREQ)
	{
		SerialNumbers::send_float(freqTrigger.get_trigFreq());
		SerialNumbers::send_uint8(OK);
	}
	else if (command == GET_SPACE)
	{
		SerialNumbers::send_uint32(posTrigger.get_resolution());
		SerialNumbers::send_uint8(OK);
	}
	else if (command == GET_PIN)
	{
		SerialNumbers::send_uint8(iPin);
		SerialNumbers::send_uint8(OK);
	}
	else if (command == SET_PIN)
	{
		const uint8_t newPin = SerialNumbers::read_uint8();
		if ((newPin >= 0) && (newPin <=2))
		{
			iPin = newPin;
			posTrigger.set_trigPin(iPin);
			freqTrigger.set_trigPin(iPin);
			SerialNumbers::send_uint8(iPin);
			SerialNumbers::send_uint8(OK);
		}
		else
		{
			SerialNumbers::send_uint8(iPin);
			SerialNumbers::send_uint8(ERROR);
		}

	}
	else if (command == SET_NFREQ)
	{
		const uint32_t nFreq = SerialNumbers::read_uint32(); //save nShots to nFreq 
		SerialNumbers::send_uint32(nFreq); //return to matlab and check
		freqTrigger.set_noShots(nFreq); //set numbers of shots
		SerialNumbers::send_uint8(OK);
	}
	else if (command == GET_NFREQ)
	{
		SerialNumbers::send_uint32(freqTrigger.get_noShots());
		SerialNumbers::send_uint8(OK);
	}
	else if (command == SET_NSPACE)
	{
		const uint32_t nSpace = SerialNumbers::read_uint32();
		SerialNumbers::send_uint32(nSpace);
		posTrigger.set_nTrigger(nSpace);
		SerialNumbers::send_uint8(OK);
	}
	else if (command == GET_NSPACE)
	{
		SerialNumbers::send_uint32(posTrigger.get_nTrigger());
		SerialNumbers::send_uint8(OK);	
	}
	else if (command == START_FREQ)
	{
		SerialNumbers::send_uint8(OK);
		freqTrigger.start();
		SerialNumbers::send_uint8(OK);
	}
	else if (command == STOP_FREQ)
	{
		// if we end up here something went wrong
		SerialNumbers::send_uint8(WARNING);
	}
	else
	{
		SerialNumbers::send_uint8(UNKNOWN_COMMAND);
	}

}