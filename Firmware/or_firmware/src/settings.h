#ifndef QUAD_SETTINGS
#define QUAD_SETTINGS

// DEFINE DIGITAL PINS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#define MEGA 1000000L

// https://www.pjrc.com/teensy/td_pulse.html
constexpr int8_t HCTL_CLOCK_PIN = 10;
constexpr int8_t HCTL_RST_PIN = 11;
constexpr int8_t HCTL_OE_PIN = 12;
constexpr int8_t HCTL_SEL_PIN = 24;
constexpr int8_t HCTL_MANUAL_RESET_PIN = 25; // push button connected here
constexpr int8_t TRIG_COUNT_RESET = 26; // push button connected here

// NOTE - not connected
constexpr int8_t BUSY_LED = 27;
constexpr int8_t RANGE_LED = 28;
constexpr int8_t TRIGGER_LED = 30;
constexpr int8_t CALIB_LED = 29; // activated during running calibration

constexpr int8_t TRIG_OUT_PINS[3] = {15,18,19}; // channels 0 1 2

// HCTL related constants
constexpr int8_t HCTL_PIN_TABLE[] = {2,14,7,8,6,20,21,5};
  // direct pins between HCTL port and teensy, picked to be read as one read
const uint32_t HCTL_CLOCK_SIGNAL = MEGA*10; // DO NOT CHANGE!!!
const uint8_t HCTL_CLOCK_DUTY_CYCLE = 160; // DO NOT CHANGE!!!

// define global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#define POS_DATA_ARRAY_SIZE 2048 // hard limit is approx. 120k data points
#define MAX_BYTE_PER_READ 4096


// define general constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#define NOP __asm__ __volatile__ ("nop\n\t") 
#define WAIT_12_NS NOP; NOP; NOP;
#define WAIT_24_NS WAIT_12_NS; WAIT_12_NS;
#define WAIT_48_NS WAIT_24_NS; WAIT_24_NS;
#define WAIT_96_NS WAIT_48_NS; WAIT_48_NS;
#define WAIT_96_NS WAIT_48_NS; WAIT_48_NS;
#define WAIT_192_NS WAIT_96_NS; WAIT_96_NS;

// does not seem to work
// #define CPU_RESTART_ADDR (uint32_t *)0xE000ED0C
// #define CPU_RESTART_VAL 0x5FA0004
// #define CPU_RESTART (*CPU_RESTART_ADDR = CPU_RESTART_VAL);

#endif
