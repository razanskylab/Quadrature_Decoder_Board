#ifndef ML_COMMANDS
#define ML_COMMANDS

  #include <Arduino.h>

  // Define serial communication commands (shared with matlab)
  constexpr char* MCU_ID = "aq_decoder"; // used to identify MCU

  // general communication commands -------------------------------------------
  constexpr uint16_t NO_NEW_COMMAND = 00; 
    // reserved as return value for no new command
  constexpr uint16_t CHECK_ID = 95;
  constexpr uint16_t CHECK_CONNECTION = 96;
  constexpr uint16_t ERROR = 97;
  constexpr uint16_t READY = 98;
  constexpr uint16_t DONE = 99;
  constexpr uint16_t STOP = 93;

  // AQ specific commands
  constexpr uint16_t SEND_CURRENT_POS = 12;
  constexpr uint16_t RESET_HCTL_COUNTER = 33;
  constexpr uint16_t ENABLE_POS_TRIGGER = 55;
  constexpr uint16_t START_FREE_RUNNING_TRIGGER = 66;

  constexpr uint16_t WAIT_COMMAND_TIMEOUT = 2000; // [ms]
    // max time to wait for serial commands 

#endif // ML_COMMANDS


