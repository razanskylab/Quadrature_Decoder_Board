



#include "teensy_lib.cpp"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void setup() {
  setup_io_pins();

  // PWM clock for HCTL
  analogWriteFrequency(HCTL_CLOCK_PIN, MEGA*10); // HCTL max clk is 14 MHz
  analogWrite(HCTL_CLOCK_PIN, 160); // set to slight more than 50% duty cycle

  Serial.begin(9600);
  // reset counter on start up 
  // (its' done automatically but we don't like implicit stuff...)
  reset_hctl();
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FASTRUN void loop()
{
  // while true avoids overhead of main loop
  while(true){
    // read a command if one was send
    if (Serial.available() > 1) {
      currentCommand = serial_read_16bit();      // read the incoming byte:
    }

    if (currentCommand == DO_NOTHING){
      digitalWriteFast(BUSY_LED, HIGH);
    }
    else{
      digitalWriteFast(BUSY_LED, LOW);
    }

    // here starts our state machine
    // commands define in
    switch (currentCommand) {
      // -----------------------------------------------------------------------
      case DO_NOTHING:
        break;
      // -----------------------------------------------------------------------
      case RECORD_CALIB_DATA: //
        record_calibration_data();
        serial_write_16bit(DONE); // send the "ok, we are done" command
        currentCommand = DO_NOTHING; // exit state machine
        break;

      // -----------------------------------------------------------------------
      case SEND_CALIB_DATA:
        send_calibration_data();
        serial_write_16bit(DONE); // send the "ok, we are done" command
        currentCommand = DO_NOTHING;
        break;

      // -----------------------------------------------------------------------
      case SEND_CURRENT_POS:
        update_counter();
        serial_write_16bit(posCounter);
        currentCommand = DO_NOTHING; // exit state machine
        break;

      // -----------------------------------------------------------------------
      case ENABLE_POS_TRIGGER:
        pos_based_triggering();
        serial_write_16bit(DONE); // send the "ok, we are done" command
        currentCommand = DO_NOTHING; // exit state machine
        break;

      // -----------------------------------------------------------------------
      case RESET_HCTL_COUNTER:
        reset_hctl();
        serial_write_16bit(DONE); // send the "ok, we are done" command
        currentCommand = DO_NOTHING; // exit state machine
        break;

      // -----------------------------------------------------------------------
      case CHECK_CONNECTION:
        serial_write_16bit(DONE); // send the "ok, we are done" command
        currentCommand = DO_NOTHING; // exit state machine
        break;

      case ENABLE_SCOPE_MODE:
        digitalWriteFast(BUSY_LED, LOW);
        scope_mode(); // send the "ok, we are done" command
        serial_write_16bit(DONE); // send the "ok, we are done" command
        delay(1000);
        digitalWriteFast(BUSY_LED, HIGH);
        currentCommand = DO_NOTHING; // exit state machine
        break;

      // -----------------------------------------------------------------------
      default:
        // statements
        currentCommand = DO_NOTHING; // exit state machine
        break;
    }
  }
} // close void loop
