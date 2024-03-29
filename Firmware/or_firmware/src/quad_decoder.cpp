#include "quad_decoder.h"

namespace quad {  

/******************************************************************************/
// setup MCU 
void QuadDecoder::Setup(){
  Serial.begin(SERIAL_SPEED); // SERIAL_SPEED defined in platformio.ini 
  delay(250); 
  Serial.flush();
  
  Setup_IO_Pins();

  // PWM clock for HCTL
  analogWriteFrequency(HCTL_CLOCK_PIN, HCTL_CLOCK_SIGNAL); 
    // HCTL max clk is 14 MHz
  analogWrite(HCTL_CLOCK_PIN, HCTL_CLOCK_DUTY_CYCLE); 
    // set to slight more than 50% duty cycle

  // reset counter on start up 
  // (its' done automatically but we don't like implicit stuff...)
  Reset_HCTL();
} 

/******************************************************************************/
// setup IO pins 
void QuadDecoder::Setup_IO_Pins() const
{
  for (int8_t i=0; i<8; i++)
  {
    pinMode(HCTL_PIN_TABLE[i],INPUT_PULLUP);
  }

  pinMode(HCTL_RST_PIN, OUTPUT);
  pinMode(HCTL_OE_PIN, OUTPUT);
  pinMode(HCTL_SEL_PIN, OUTPUT);

  pinMode(TRIG_OUT_PINS[0], OUTPUT);
  pinMode(TRIG_OUT_PINS[1], OUTPUT);
  pinMode(TRIG_OUT_PINS[2], OUTPUT);
  digitalWriteFast(TRIG_OUT_PINS[0], LOW);
  digitalWriteFast(TRIG_OUT_PINS[1], LOW);
  digitalWriteFast(TRIG_OUT_PINS[2], LOW);

  pinMode(HCTL_MANUAL_RESET_PIN, INPUT);
  pinMode(TRIG_COUNT_RESET, INPUT);

  digitalWriteFast(HCTL_RST_PIN, HIGH);
  digitalWriteFast(HCTL_OE_PIN, HIGH);
  digitalWriteFast(HCTL_SEL_PIN, HIGH);

  // note leds are not in use...but we have the connections
  // pinMode(BUSY_LED, OUTPUT);
  // pinMode(RANGE_LED, OUTPUT);
  // pinMode(TRIGGER_LED, OUTPUT);
  // pinMode(CALIB_LED, OUTPUT);

  // digitalWriteFast(BUSY_LED, LOW);
  // digitalWriteFast(RANGE_LED, LOW);
  // digitalWriteFast(CALIB_LED, LOW);
  // digitalWriteFast(TRIGGER_LED, LOW);
}


/******************************************************************************/
// check for commands from matlab and act accordingly 
void QuadDecoder::Handle_Matlab_Interface(){
   // read a command if one was send
    if (Serial.available() > 1) {
      currentCommand = MLS.Serial_Read_16bit();      // read the incoming byte:
    } 

    // here starts our state machine
    // commands define in
    switch (currentCommand) {
      // -----------------------------------------------------------------------
      case NO_NEW_COMMAND:
        break;

      case SEND_CURRENT_POS:
        Send_Current_Position();
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      case RESET_HCTL_COUNTER:
        Reset_HCTL();
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      case CHECK_CONNECTION:
        MLS.Send_Command(READY);
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      case CHECK_ID:
        Serial.print(MCU_ID); // write string of serial
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      case ENABLE_POS_TRIGGER:
        Pos_Based_Trigger();
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      case START_FREE_RUNNING_TRIGGER:
        Free_Running_Trigger(); 
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;

      // -----------------------------------------------------------------------
      default:
        // statements
        currentCommand = NO_NEW_COMMAND; // exit state machine
        break;
    }
}


// reset hctl to reset to zero 
void QuadDecoder::Reset_HCTL() const
{
  MLS.Serial_Write_16bit(RESET_HCTL_COUNTER); // send as confirmation
  digitalWriteFast(HCTL_RST_PIN, LOW); 
  WAIT_96_NS; // min is 28ns but we have no rush here...
  digitalWriteFast(HCTL_RST_PIN, HIGH);
  MLS.Serial_Write_16bit(DONE); // send as confirmation
  return;
}

// reset hctl to reset to zero 
void QuadDecoder::Toggle_Trigger_Channel(int8_t channel)
{
  // invert, good old Urs trick ;-)
  trigPinState[channel] = !trigPinState[channel]; 
  digitalWriteFast(TRIG_OUT_PINS[channel], trigPinState[channel]);
  triggerCounter[channel]++; // increment trigger count
  return;
}

// reset hctl to reset to zero 
void QuadDecoder::Send_Current_Position()
{
  MLS.Serial_Write_16bit(SEND_CURRENT_POS); // send as confirmation
  Read_HCTL_Counter();
  MLS.Serial_Write_16bit(posCounter);
  MLS.Serial_Write_16bit(DONE); // send as confirmation
  return;
}

// get latest counter value from HCTL
void QuadDecoder::Read_HCTL_Counter()
{
  digitalWriteFast(HCTL_SEL_PIN, LOW); // select high bit
  digitalWriteFast(HCTL_OE_PIN, LOW); // start read
  // NOTE from SEL high/low to stable, selected data byte = 65 ns
  // we wait ~72 when using overclocked teensy
  // WAIT_24_NS; WAIT_48_NS;
  WAIT_48_NS; WAIT_48_NS;
  
  // get msb, write directly to counter, also turns uint to int...lots of magic here
  ((unsigned char *)&posCounter)[1] = GPIOD_PDIR & 0xFF; // read msb
  digitalWriteFast(HCTL_SEL_PIN, HIGH); // select low bit
  // NOTE from SEL high/low to stable, selected data byte = 65 ns
  // we wait ~72 when using overclocked teensy
  // WAIT_24_NS; WAIT_48_NS;
  WAIT_48_NS; WAIT_48_NS;
  ((unsigned char *)&posCounter)[0] = GPIOD_PDIR & 0xFF; // read lsb
  // finish read out
  digitalWriteFast(HCTL_OE_PIN, HIGH);
}


/******************************************************************************/
// start position based triggering
FASTRUN void QuadDecoder::Pos_Based_Trigger()
{
  MLS.Serial_Write_16bit(ENABLE_POS_TRIGGER);
  bool doWait = true;
  uint16_t lowRange = MLS.Serial_Read_16bit(doWait);
  uint16_t upRange = MLS.Serial_Read_16bit(doWait);
  uint16_t stepSize = MLS.Serial_Read_16bit(doWait);  // trigger ever stepSize steps
  uint16_t nTotalBscans = MLS.Serial_Read_16bit(doWait);  // get nBscans
  // uint32_t totalScanTime = MLS.Serial_Read_32bit(doWait);  // get total scan time

  // send back data we just read as our kind of handshake
  MLS.Serial_Write_16bit(lowRange); 
  MLS.Serial_Write_16bit(upRange); 
  MLS.Serial_Write_16bit(stepSize); 
  MLS.Serial_Write_16bit(nTotalBscans); 

  // TODO
  // send aproximate scan time to check if we got stuck...
  // TODO
  // check for serial commands when leaving upper / lower trigger range
  // at this point we know we have some time before we need to trigger again

  // local variables to keep track of stuff
  uint16_t nBScans = 0;  // completed b-scans
  //const uint8_t triggerOutCh = 0; 

  // always start with low signal on trigger channel
  digitalWriteFast(TRIG_OUT_PINS[triggerOutCh], LOW);
  triggerCounter[triggerOutCh] = 0; // reset trigger counter
  bool upwardsMoving = true;
  uint16_t nextTriggerPos = lowRange; // next position at which we have to trigger
  Read_HCTL_Counter(); // update current counter value (stored in posCounter)

  while(nBScans < nTotalBscans)
  {
    // we loop here until we leave the upwards moving trigger range ------------
    while(upwardsMoving)
    {
      Read_HCTL_Counter();     // update current counter value (stored in posCounter)
      if (posCounter >= nextTriggerPos)
      {
        Toggle_Trigger_Channel(triggerOutCh);
        nextTriggerPos = nextTriggerPos + stepSize; 
          // use last trigger pos, not current pos so we don't carry delays
        if (nextTriggerPos > upRange)
        {
          upwardsMoving = false;
          nextTriggerPos = upRange;
          nBScans++; 
        }
      }
    }

    // wait for stage to move to max position and come back --------------------
    while(posCounter < (upRange + 2 * stepSize)){
      Read_HCTL_Counter();   
    }

    // we loop here until we leave the downwards moving trigger range ----------
    while(!upwardsMoving){
      Read_HCTL_Counter();
      if (posCounter <= nextTriggerPos){
        Toggle_Trigger_Channel(triggerOutCh);
        nextTriggerPos = nextTriggerPos - stepSize;
        if (nextTriggerPos < lowRange){
          upwardsMoving = true;
          nextTriggerPos = lowRange;
          nBScans++;
        }
      }
    }

    if (nBScans > nTotalBscans){
      break;
    }
    // wait for stage to move to min position and come back --------------------
    while(posCounter > (lowRange - 2*stepSize)){
      Read_HCTL_Counter(); 
    }; 
  } // while triggering

  digitalWriteFast(TRIG_OUT_PINS[triggerOutCh], LOW);

  // send total trigger count over serial port to matlab
  MLS.Serial_Write_16bit(STOP); // send the stop command back as a handshake
  MLS.Serial_Write_32bit(triggerCounter[triggerOutCh]);
  MLS.Serial_Write_16bit(DONE); // send the "ok, we are done" command

  return;
}


// start free running trigger, formerly known as scope_mode
void QuadDecoder::Free_Running_Trigger()
{
  // send back START_FREE_RUNNING_TRIGGER to confirm what we are doing here
  MLS.Serial_Write_16bit(START_FREE_RUNNING_TRIGGER);

  // read settings from matlab
  bool waitForData = true;
  uint16_t slowMode = MLS.Serial_Read_16bit(waitForData); // delay in ms or us
  uint16_t triggerPeriod = MLS.Serial_Read_16bit(waitForData);
  uint16_t nTrigger = MLS.Serial_Read_16bit(waitForData); // trigger how many times?

  MLS.Serial_Write_16bit(slowMode); // switches between slow and fast version
  // fast is based on micros command, slow on millis
  MLS.Serial_Write_16bit(triggerPeriod);
  MLS.Serial_Write_16bit(nTrigger);

  uint32_t lastSamplingTime = 0;
  uint16_t lastCommand = 0;
  triggerCounter[triggerOutCh] = 0; // trigger counter for channel 2
  bool doTrigger = true;
  // MLS.lastCommandCheck = millis(); // reset our timer...

  while (doTrigger){
    // wait for next trigger point, we do this at least once!
    if (slowMode)
    {
      while((millis() - lastSamplingTime) < triggerPeriod)
      {
        // do nothing
      };
      lastSamplingTime = millis();
    }
    else
    {
      while((micros() - lastSamplingTime) < triggerPeriod)
      {
        // do nothing
      };
      lastSamplingTime = micros();
    }
    Toggle_Trigger_Channel(triggerOutCh); // change trigger signal on trig channel (zero indexed)

    // if nTrigger = 0 we trigger indefinately
    if (nTrigger && (triggerCounter[triggerOutCh] >= nTrigger))
    {
      doTrigger = false;
    }

    // check if MATLAB through a stop command at us
    lastCommand = MLS.Timed_Command_Check();
    if (lastCommand == STOP)
    {
      doTrigger = false; // this will get us out of the while loop
    }
  }
  MLS.Serial_Write_16bit(STOP); // send the "ok, we are stopped" command
  MLS.Serial_Write_32bit(triggerCounter[triggerOutCh]);
  MLS.Serial_Write_16bit(DONE); // send the "ok, we are done" command
}

} // namespace