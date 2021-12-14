/* 

	STATUS_LEDS[0] --> waiting for Serial input	
	STATUS_LEDS[1] --> we are in time domain trigger mode
	STATUS_LEDS[2] --> we are in position based trigger mode

	Changelog:
		Switched serial communcation from uint16_t to uint32_t
		Took out 1 second delay in time domain tigger before start

*/
#include "QuadReadout.h"
#include "WaitNS.h"
#include "PinMapping.h"
#include "FreqBasedTrigger.h"

char mode; 
QuadReadout posBasedTrigger; // class used to perform readout from quadr board
FreqBasedTrigger freqBasedTrig; // class used for frequency based triggering
bool lastState = 0;

// setting up board
void setup()
{
	// declare all our status LEDs as output and set to low
	for (unsigned char iLed = 0; iLed < 4; iLed++){
		pinMode(STATUS_LEDS[iLed], OUTPUT);
		digitalWriteFast(STATUS_LEDS[iLed], LOW);
	}

	pinMode(OUTPUT_POSBOARD, OUTPUT);
	digitalWriteFast(OUTPUT_POSBOARD, lastState);

	Serial.begin(115200);
}

void wait_for_serial(int nSerial)
{
	while (Serial.available() < nSerial){
		delayMicroseconds(1); // do nothing but wait
	}
	return;
} 

// serial read of a uint32
uint32_t serialReadUint32()
{
	char uintBuffer[4];
	Serial.readBytes(uintBuffer, 4);
	uint32_t value = (uintBuffer[3] << 24) + (uintBuffer[2] << 16) + 
	  	(uintBuffer[1] << 8) + uintBuffer[0];
	return value;
}

// time domain triggering used for SNR scope
void time_domain_trigger_mode()
{
	// TODO requires implementation
	// declare temporary variables for frequency and position based 
  // triggering
	wait_for_serial(8);

  uint32_t freq = serialReadUint32();
  uint32_t noShots = serialReadUint32();

  // Let computer know what we understood
  Serial.print("f: ");
  Serial.print(freq);
  Serial.print(" x ");
  Serial.print(noShots);
  Serial.print("\r");
  freqBasedTrig.setTrigFreq(freq);
  freqBasedTrig.setNoShots(noShots);
    
  char input = 'x';
  while (input != 'o')
  {
    wait_for_serial(1);

    input = Serial.read();
    if (input == 'x'){
    	Serial.print("r\r"); // let matlab know that we are ready to go
      freqBasedTrig.start();
    }
    else if (input == 'o'){
      freqBasedTrig.stop();
    }
  }
	return;
}

// spatial domain triggering used for scans
void spatial_domain_trigger_mode()
{
	// declare temporary variables for step size and number of steps

  wait_for_serial(8); // wait for bits to arrive

	uint32_t stepSize = serialReadUint32();
	uint32_t nTrigger = serialReadUint32();

  // pass information back to MATLAB for doublecheck
  Serial.print("s: ");
  Serial.print(stepSize, DEC);
  Serial.print(" x ");
  Serial.print(nTrigger, DEC);
  Serial.print("\r");

  // pass resolution and number of trigger events to class
  posBasedTrigger.setXResolution(stepSize);
  posBasedTrigger.setNTrigger(nTrigger);

  char input = 'x';
  while (input != 'o'){
    // wait for starting command
    wait_for_serial(1);
  
    input = Serial.read();
    if (input == 'x'){
      if (nTrigger == 0){
      	Serial.print("r\r"); // let matlab know that we are ready to go
        // posBasedTrigger.start(); // keep running until stop Serial comes in
      }
      else{
      	Serial.print("r\r"); // let matlab know that we are ready to go
        posBasedTrigger.startN(lastState); // keep going for N steps
      }
    } 
  }
	return;
}



// repeated loop
void loop()
{
	digitalWriteFast(STATUS_LEDS[0], HIGH); // indicate that we are waiting
	wait_for_serial(1);
	
	digitalWriteFast(STATUS_LEDS[0], LOW);

	// read serial input and push to class
	mode = Serial.read();
	/*
		Serial commands supported
		f - time domain trigger mode
		s - spatial domain trigger mode
		i - identify device
		r - reset position counter
		p - return current position of hctl counter
	*/
	
	if (mode == 'f'){ // time domain trigger mode
		time_domain_trigger_mode();
	}else if (mode == 's'){ // spatial domain triggering
		spatial_domain_trigger_mode();
	}else if (mode == 'r'){ // reset position counter to 0
		posBasedTrigger.reset_hctl();
		Serial.print("r\r");
	}else if (mode == 'p'){
		// update position and return through serial 
		posBasedTrigger.update_counter();
		Serial.print(posBasedTrigger.posCounter);
		Serial.print("\r");
	}else if (mode == 'i'){ // identify yourself as board
		Serial.print("TeensyBasedTrigger\r");
	}else{
		Serial.print("Invalid mode! Returning to wait...\r");		
	}

	// Clear all data in Serial port and return to main application
 	while (Serial.available() > 0){
		Serial.read();
		delayMicroseconds(1);
 	}

}