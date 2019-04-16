#ifndef TEENSY_LIB
#define TEENSY_LIB

#include <Arduino.h> // always required when using platformio

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// function declarations

void print_bits(uint8_t myByte);
void print_more_bits(uint16_t myByte);
void update_counter();
void reset_hctl();
void trigger_ardu();
void setup_io_pins();
uint16_t serial_read_16bit();
void serial_write_16bit(uint16_t writeData);
void serial_write_32bit(uint32_t writeData);
uint16_t serial_read_16bit_no_wait();
void serial_wait_next_command();
void pos_based_triggering();
void record_calibration_data();
void send_calibration_data();
void init_calibration_data();


// define global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool calibLedState = 0; // trigger pin is toggled on/off every "stepSize"


// used for HCTL communication
uint8_t msb = 0;
uint8_t lsb = 0;

// position & trigger counters / variables
uint16_t posCounter = 0; // position value stored in HCTL counter
bool trigPinState[3] = {0,0,0}; // trigger pin is toggled on/off every "stepSize"
uint32_t triggerCounter[3] = {0,0,0};

bool firstTrig = true;
bool doTrigger = false;
  // we trigger between these two limits
uint16_t stepSize; // trigger every nSteps
uint32_t lastCommandCheck;

// constants for read/write during the calibration step
#define POS_DATA_ARRAY_SIZE 2048 // hard limit is approx. 120k data points
#define MAX_BYTE_PER_READ 4096
#define MEGA 1000000L

// stage calibration variables
uint16_t currentCommand = 0; // for incoming serial data
uint16_t posDataArray[POS_DATA_ARRAY_SIZE]; // storage for position data during stage calibration
uint32_t lastSamplingTime; // used during stage calibration
uint16_t samplingPeriodCalib; // sampling period during stage calibration
uint16_t nBytesCalib; // send this many bytes during calibration mode
uint16_t* posDataPtr = posDataArray; // pointer to posData

const uint16_t COMMAND_CHECK_INTERVALL = 100; // [ms] wait this long before checking for serial
const uint16_t MAX_RANGE = 60000; // max value stage can reach
const uint8_t MICRON = 5; // one micron = 5 steps

// define general constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// wait a few clock cycles
#define NOP __asm__ __volatile__ ("nop\n\t") // ~6 ns = one clock cycle
#define WAIT_10_NS NOP; NOP;
#define WAIT_20_NS NOP; NOP; NOP; NOP;
#define WAIT_40_NS WAIT_20_NS; WAIT_20_NS;
#define WAIT_60_NS WAIT_20_NS; WAIT_20_NS; WAIT_20_NS;
#define WAIT_80_NS WAIT_40_NS; WAIT_40_NS;
#define WAIT_100_NS WAIT_80_NS; WAIT_20_NS;

// define commands
#define DO_NOTHING 0
#define RECORD_CALIB_DATA 11
#define SEND_CURRENT_POS 12
#define SEND_CALIB_DATA 22
#define RESET_HCTL_COUNTER 33
#define RESET_TEENSY 44
#define ENABLE_POS_TRIGGER 55
#define DISABLE_POS_TRIGGER 56
#define CHECK_CONNECTION 98
#define DONE 99

// HCTL related constants
const uint32_t HCTL_CLOCK_SIGNAL = MEGA*40; // DO NOT CHANGE!!!
const uint8_t pinTable[] = {2,14,7,8,6,20,21,5};

// position related con

// communication consts
#define CPU_RESTART_ADDR (uint32_t *)0xE000ED0C
#define CPU_RESTART_VAL 0x5FA0004
#define CPU_RESTART (*CPU_RESTART_ADDR = CPU_RESTART_VAL);

// DEFINE ANALOG PINS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// DEFINE DIGITAL PINS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// https://www.pjrc.com/teensy/td_pulse.html
const uint8_t HCTL_CLOCK_PIN = 10;
const uint8_t HCTL_RST_PIN = 11;
const uint8_t HCTL_OE_PIN = 12;
const uint8_t HCTL_SEL_PIN = 24;
const uint8_t HCTL_MANUAL_RESET_PIN = 25; // push button connected here
const uint8_t TRIG_COUNT_RESET = 26; // push button connected here

const uint8_t BUSY_LED = 27;
const uint8_t RANGE_LED = 28;
const uint8_t TRIGGER_LED = 30;
const uint8_t CALIB_LED = 29; // activated during running calibration

const uint8_t TRIG_OUT[3] = {15,18,19};
// const uint8_t TRIG_OUT_2 = 18;
// const uint8_t TRIG_OUT_3 = 19;


#endif
