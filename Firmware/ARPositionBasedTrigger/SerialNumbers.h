// Name: SerialNumbers.h
// Author: Urs Hofmann
// Mail: mail@hofmannu.org
// Date: 22.03.2022

// Description: reads and writes serial numbers from and to MATLAB

#ifndef SERIALNUMBERS_H
#define SERIALNUMBERS_H

#include <stdint.h>
#include <arduino.h>

namespace SerialNumbers 
{
	void wait_serial(const uint8_t nSerial);

	// floating point numbers
	void send_float(const float floatToSend);
	float read_float();
	
	// unsigned integer numbers
	uint8_t read_uint8();
	uint16_t read_uint16();
	uint32_t read_uint32();
	uint64_t read_uint64();
	
	void send_uint8(const uint8_t number);
	void send_uint16(const uint16_t number);
	void send_uint32(const uint32_t number);
	void send_uint64(const uint64_t number);
	
	// signed integer numbers
	int16_t read_int16();
	int32_t read_int32();
	int64_t read_int64();

	void send_int64(const int64_t number);
	void send_int32(const int32_t number);
	void send_int16(const int16_t number);
}

#endif