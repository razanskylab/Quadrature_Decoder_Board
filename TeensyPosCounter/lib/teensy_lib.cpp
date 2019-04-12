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
  msb = GPIOD_PDIR & 0xFF; // read msb
  digitalWriteFast(HCTL_SEL_PIN, HIGH); // select low bit
  // get msb, write directly to counter, also turns uint to int...lots of magic here
  // we do this after changing pin, as data now needs time to settle...
  // ((uint8_t *)&counter)[1] = msb;
  ((unsigned char *)&posCounter)[1] = msb;

  WAIT_100_NS; // allow high bit to be stable
  lsb = GPIOD_PDIR & 0xFF; // read lsb
  // finish read out
  digitalWriteFast(HCTL_OE_PIN, HIGH);
  digitalWriteFast(HCTL_SEL_PIN, HIGH);
  // might need to add delay here...

  // get lsb, write directly to counter, also turns uint to int...lots of magic here
  // ((uint8_t *)&counter)[0] = lsb;
  ((unsigned char *)&posCounter)[0] = lsb;
  // if (posCounter == minusOne)
  //   Serial.println("OVERFLOW WARN!");
}

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void trigger_ch(uint8_t channel) {
  trigPinState[channel] = !trigPinState[channel]; // invert, good old Urs trick ;-)
  digitalWriteFast(TRIG_OUT[channel], trigPinState[channel]); // select high bit
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
  // same as serial_read_16bit but not checking for available bytes \
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
    calibLedState = ~calibLedState;
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
  uint16_t lastCount = 0;
  uint16_t diffCount = 0;

  init_calibration_data(); // set position to all zeros...we then fill part of it
  uint16_t arrayPos = 0;

  lowRange = serial_read_16bit(); // get range min
  upRange = serial_read_16bit();  // get range max
  stepSize = serial_read_16bit();  // get range max
  // get nTriggers?
  doTrigger = true;
  triggerCounter[2] = 0; // trigger counter for channel 2
  while(doTrigger)
  {
    update_counter();     // update current counter value (stored in posCounter)
    bool inRange = (posCounter >= lowRange) && (posCounter <= upRange);
    if (inRange){ // we are in range again,
      trigger_ch(2); //send first trigger signal at border of ROI
      if (arrayPos < POS_DATA_ARRAY_SIZE){
        posDataArray[arrayPos++] = posCounter; // FIXME just for debugging
      }
      lastCount = posCounter; // save last position
      digitalWriteFast(RANGE_LED, HIGH); // set the range led
    }
    else{
      digitalWriteFast(RANGE_LED, LOW);
    }
    while(inRange)
    {
      // check if still in range
      update_counter();     // update current counter value (stored in posCounter)
      inRange = (posCounter >= lowRange) && (posCounter <= upRange);
      diffCount = abs(posCounter-lastCount);
      if (diffCount>=stepSize){
        trigger_ch(2);
        if (arrayPos < POS_DATA_ARRAY_SIZE){
          posDataArray[arrayPos++] = posCounter; // FIXME just for debugging
        }
        lastCount = posCounter; // save last position
      }
    }

    // check if we got a new serial command to stop triggering
    // COMMAND_CHECK_INTERVALL is high, so we only check once in a while
    if((millis()-lastCommandCheck)>=COMMAND_CHECK_INTERVALL)
    {
      lastCommandCheck = millis();
      if (Serial.available() >= 2)
      {
        currentCommand = serial_read_16bit_no_wait();
        if (currentCommand == DISABLE_POS_TRIGGER)
        {
          doTrigger = false;
        }
      }
    }
  } // while triggering
  // send total trigger count over serial port to matlab
  serial_write_32bit(triggerCounter[2]);
  serial_write_16bit(DONE); // send the "ok, we are done" command
  send_calibration_data();
  // serial_write_16bit(DONE); // send the "ok, we are done" command
  // enable trigger mode -> enter while loop
  // check every 500 ms if we still want to be in trigger mode
}
