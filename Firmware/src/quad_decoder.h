#ifndef QUAD_DECODER
#define QUAD_DECODER

#include <Arduino.h>

#include <ml_serial_interface.h>

#include "settings.h"
#include "matlab_commands.h"

namespace quad {

  class QuadDecoder {
   public:
    /**************************************************************************/
    // public properties
    mlSerial::MLSerial MLS; // custom matlab interface
    uint16_t currentCommand = NO_NEW_COMMAND; 
    int8_t triggerOutCh = 0; // hardware port that is connected to trigger board

    /**************************************************************************/
    // public methods
    void Setup();
    void Handle_Matlab_Interface(); // read commands and act accordingly...

  /****************************************************************************/
   private:
    // private properties
    // private methods
    uint16_t posCounter = 0; // latest position value from HCTL
    bool trigPinState[3] = {0,0,0}; // trigger pin is toggled on/off 
    uint32_t triggerCounter[3] = {0,0,0};

    void Setup_IO_Pins() const; // setup IO pins 
    void Reset_HCTL() const; // reset hctl to reset to zero 
    void Read_HCTL_Counter(); // get latest counter value from HCTL
    void Free_Running_Trigger(); // get latest counter value from HCTL
    void Pos_Based_Trigger(); // get latest counter value from HCTL
    void Toggle_Trigger_Channel(int8_t channel);
  };
} // namespace

#endif // QUAD_DECODER
