#include "teensy_lib.h"

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setup_io_pins() {
  for (uint8_t i=0; i<8; i++)
  {
    pinMode(pinTable[i],INPUT_PULLUP);
  }

  pinMode(HCTL_RST_PIN, OUTPUT);
  pinMode(HCTL_OE_PIN, OUTPUT);
  pinMode(HCTL_SEL_PIN, OUTPUT);

  pinMode(BUSY_LED, OUTPUT);
  pinMode(RANGE_LED, OUTPUT);
  pinMode(TRIGGER_LED, OUTPUT);
  pinMode(CALIB_LED, OUTPUT);

  pinMode(TRIG_OUT[0], OUTPUT);
  pinMode(TRIG_OUT[1], OUTPUT);
  pinMode(TRIG_OUT[2], OUTPUT);

  pinMode(HCTL_MANUAL_RESET_PIN, INPUT);
  pinMode(TRIG_COUNT_RESET, INPUT);

  digitalWriteFast(HCTL_RST_PIN, HIGH);
  digitalWriteFast(HCTL_OE_PIN, HIGH);
  digitalWriteFast(HCTL_SEL_PIN, HIGH);

  digitalWriteFast(BUSY_LED, LOW);
  digitalWriteFast(RANGE_LED, LOW);
  digitalWriteFast(CALIB_LED, LOW);
  digitalWriteFast(TRIGGER_LED, LOW);
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void update_counter() {
  digitalWriteFast(HCTL_SEL_PIN, LOW); // select high bit
  digitalWriteFast(HCTL_OE_PIN, LOW); // start read

  WAIT_100_NS; // allow high bit to be stable
  ((unsigned char *)&posCounter)[1] = GPIOD_PDIR & 0xFF; // read msb

  digitalWriteFast(HCTL_SEL_PIN, HIGH); // select low bit
  // get msb, write directly to counter, also turns uint to int...lots of magic here
  // we do this after changing pin, as data now needs time to settle...
  // ((uint8_t *)&counter)[1] = msb;

  WAIT_100_NS; // allow high bit to be stable
  WAIT_100_NS; // allow high bit to be stable
  ((unsigned char *)&posCounter)[0] = GPIOD_PDIR & 0xFF; // read lsb
  // finish read out
  digitalWriteFast(HCTL_OE_PIN, HIGH);
  // digitalWriteFast(HCTL_SEL_PIN, HIGH);
  // might need to add delay here...

  // get lsb, write directly to counter, also turns uint to int...lots of magic here
  // ((uint8_t *)&counter)[0] = lsb;
  // if (posCounter == minusOne)
  //   Serial.println("OVERFLOW WARN!");
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void trigger_ch(uint8_t channel) {
  trigPinState[channel] = !trigPinState[channel]; // invert, good old Urs trick ;-)
  digitalWriteFast(TRIG_OUT[channel], trigPinState[channel]);
  triggerCounter[channel]++;
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// reset counter chip values to zero
void reset_hctl() {
  digitalWriteFast(HCTL_RST_PIN, LOW); // start read
  WAIT_60_NS;
  digitalWriteFast(HCTL_RST_PIN, HIGH);
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uint16_t serial_read_16bit()
{
  serial_wait_next_command(); // wait for 2 bytes
  return Serial.read() + (Serial.read() << 8);  // read a 16-bit number from 2 bytes
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uint16_t serial_read_16bit_no_wait()
{
  // same as serial_read_16bit but not checking for available bytes
  // used only where speed is critical
  return Serial.read() + (Serial.read() << 8);  // read a 16-bit number from 2 bytes
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void serial_write_16bit(uint16_t writeData){
  uint8_t outBuffer[2];
  outBuffer[0] = writeData & 255;
  outBuffer[1] = (writeData >> 8)  & 255;
  Serial.write(outBuffer, 2);
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void serial_write_32bit(uint32_t writeData){
  uint8_t outBuffer[4];
  outBuffer[0] = writeData & 255;
  outBuffer[1] = (writeData >> 1*8)  & 255;
  outBuffer[2] = (writeData >> 2*8)  & 255;
  outBuffer[3] = (writeData >> 3*8)  & 255;
  Serial.write(outBuffer, 4);
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void serial_wait_next_command(){
  // wait for 2 bytes to be available
  while(Serial.available() < 2){}
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void record_calibration_data(){
  samplingPeriodCalib = serial_read_16bit();

  for (uint16_t iPos=0; iPos<POS_DATA_ARRAY_SIZE; iPos++)
  {
    while((micros()-lastSamplingTime)<samplingPeriodCalib){} // wait for next meas point
    lastSamplingTime = micros();
    // transfer current counter value from HCTL chip to teensy
    update_counter();
    // get the current value of the position counter
    posDataArray[iPos] = posCounter;
    // use led to indicate we are calibrating
    calibLedState = !calibLedState;
    digitalWriteFast(CALIB_LED, calibLedState);
  }
  digitalWriteFast(CALIB_LED, false);
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void init_calibration_data(){
  for (uint16_t iData=0; iData<POS_DATA_ARRAY_SIZE; iData++)
  {
    posDataArray[iData] = 0;
  }
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void send_calibration_data(){
  nBytesCalib = serial_read_16bit();
  posDataPtr = posDataArray; // reset pointer to the start
  for (uint16_t iPos = 0; iPos < nBytesCalib/2; iPos++)
  {
    serial_write_16bit(*posDataPtr);
    posDataPtr++;
  }
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void pos_based_triggering(){
  uint16_t lowRange = serial_read_16bit(); // low lim to start triggering
  uint16_t upRange = serial_read_16bit();  // get range max
  uint16_t stepSize = serial_read_16bit();  // get range max
  uint16_t nTotalBscans = serial_read_16bit();  // get nBscans
  uint16_t nBScans = 0;  // get nBscans

  // get currentTriggers? -> no need, just calc here...
  triggerCounter[2] = 0; // trigger counter for channel 2
  uint8_t upwardsMoving = true;
  uint16_t nextTriggerPos = lowRange;

  digitalWriteFast(TRIGGER_LED, HIGH);

  while(nBScans < nTotalBscans)
  {
    update_counter();     // update current counter value (stored in posCounter)
    // we loop here until we leave the upwards moving trigger range
    while(upwardsMoving){
      update_counter();     // update current counter value (stored in posCounter)
      if (posCounter >= nextTriggerPos){
        trigger_ch(2);
        nextTriggerPos = nextTriggerPos + stepSize;
      }
      if (nextTriggerPos > upRange){
        upwardsMoving = false;
        nextTriggerPos = upRange;
        nBScans++;
      }
    }
    while(posCounter < (upRange + 2*stepSize)){
      update_counter();     // update current counter value (stored in posCounter)
    }; // leave range fully...

    while(!upwardsMoving){
      update_counter();     // update current counter value (stored in posCounter)
      if (posCounter <= nextTriggerPos){
        trigger_ch(2);
        nextTriggerPos = nextTriggerPos - stepSize;
      }
      if (nextTriggerPos < lowRange){
        upwardsMoving = true;
        nextTriggerPos = lowRange;
        nBScans++;
      }
    }
    while(posCounter > (lowRange - 2*stepSize)){
      update_counter();     // update current counter value (stored in posCounter)
    }; // leave range fully...

  } // while triggering
  digitalWriteFast(TRIGGER_LED, LOW);

  // send total trigger count over serial port to matlab
  serial_write_32bit(triggerCounter[2]);
  serial_write_16bit(DONE); // send the "ok, we are done" command
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void scope_mode(){
  uint16_t slowMode = serial_read_16bit(); // delay in ms or us
  uint16_t triggerPeriod = serial_read_16bit();
  uint16_t nTrigger = serial_read_16bit(); // trigger how many times?
  uint32_t lastCommandCheck = 0;
  triggerCounter[2] = 0; // trigger counter for channel 2
  bool doTrigger = true;
  digitalWriteFast(TRIGGER_LED, HIGH);

  while (doTrigger){
    // wait for next trigger point, we do this at least once!
    if (slowMode){
      while((millis()-lastSamplingTime)<triggerPeriod){};
      lastSamplingTime = millis();
    }
    else{
      while((micros()-lastSamplingTime)<triggerPeriod){};
      lastSamplingTime = micros();
    }
    trigger_ch(2); // triggers 2nd board, which then triggers different things...

    // if nTrigger = 0 we trigger indefinately
    if (nTrigger && (triggerCounter[2] >= nTrigger)){
      doTrigger = false;
    }

    // check if we got a new serial command to stop triggering
    // COMMAND_CHECK_INTERVALL is high, so we only check once in a while
    if((millis()-lastCommandCheck)>=COMMAND_CHECK_INTERVALL)
    {
      lastCommandCheck = millis();
      if (Serial.available() >= 2)
      {
        currentCommand = serial_read_16bit_no_wait();
        if (currentCommand == DISABLE_SCOPE)
        {
          doTrigger = false;
        }
      }
    }
  }
  serial_write_32bit(triggerCounter[2]);
  digitalWriteFast(TRIGGER_LED, LOW);
}
