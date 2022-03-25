// Name: SerialNumbers.h
// Author: Urs Hofmann
// Mail: mail@hofmannu.org
// Date: 22.03.2022

// Description: reads and writes serial numbers from and to MATLAB

#include "SerialNumbers.h"

namespace SerialNumbers 
{
	void wait_serial(const uint8_t nSerial)
	{
		while(Serial.available() < nSerial)
		{
			delayMicroseconds(1);
		}
		return;
	}

	void send_float(const float floatToSend)
	{
		union {
	    	float float_variable;
	    	char temp_array[4];
	  	} u;
	  	u.float_variable = floatToSend;
	  	Serial.write(&u.temp_array[0], 4);
		return;
	}

	// receives a float over serial from matlab
	float read_float()
	{
		wait_serial(4);
		union {
			float float_variable;
			char temp_array[4];
		} u;
		Serial.readBytes(&u.temp_array[0], 4);
		return u.float_variable;
	}

	uint64_t read_uint64()
	{
		wait_serial(8);
		union {
			uint64_t number;
			char temp_array[8];
		} u;
		Serial.readBytes(&u.temp_array[0], 8);
		return u.number;
	}

	uint32_t read_uint32()
	{
		wait_serial(4);
		union {
			uint32_t number;
			char temp_array[4];
		} u;
		Serial.readBytes(&u.temp_array[0], 4);
		return u.number;
	}

	uint16_t read_uint16()
	{
		wait_serial(2);
		union {
			uint16_t number;
			char temp_array[2];
		} u;
		Serial.readBytes(u.temp_array, 2);
		return u.number;
	}

	uint8_t read_uint8()
	{
		wait_serial(1);
		union {
			uint8_t number;
			char temp_array[1];
		} u;
		Serial.readBytes(u.temp_array, 1);
		return u.number;
	}

	void send_uint64(const uint64_t number)
	{
		union {
	    	uint64_t number;
	    	char temp_array[8];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 8);
		return;
	}

	void send_uint32(const uint32_t number)
	{
		union {
	    	uint32_t number;
	    	char temp_array[4];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 4);
		return;
	}

	void send_uint16(const uint16_t number)
	{
		union {
	    	uint16_t number;
	    	char temp_array[2];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 2);
		return;
	}

	void send_uint8(const uint8_t number)
	{
		union {
	    	uint8_t number;
	    	char temp_array[1];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 1);
		return;
	}

	int64_t read_int64()
	{
		wait_serial(8);
		union {
			int64_t number;
			char temp_array[8];
		} u;
		Serial.readBytes(u.temp_array, 8);
		return u.number;
	}

	int32_t read_int32()
	{
		wait_serial(4);
		union {
			int32_t number;
			char temp_array[4];
		} u;
		Serial.readBytes(u.temp_array, 4);
		return u.number;
	}

	int16_t read_int16()
	{
		wait_serial(2);
		union {
			int16_t number;
			char temp_array[2];
		} u;
		Serial.readBytes(u.temp_array, 2);
		return u.number;
	}

	void send_int64(const int64_t number)
	{
		union {
	    	int64_t number;
	    	char temp_array[8];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 8);
		return;
	}

	void send_int32(const int32_t number)
	{
		union {
	    	int32_t number;
	    	char temp_array[4];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 4);
		return;
	}

	void send_int16(const int16_t number)
	{
		union {
	    	int16_t number;
	    	char temp_array[2];
	  	} u;
	  	u.number = number;
	  	Serial.write(u.temp_array, 2);
		return;
	}
}
