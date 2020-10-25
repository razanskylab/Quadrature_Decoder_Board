// Just testing something here...

#include "ml_serial_interface.h"

namespace mlSerial {  
  
  /******************************************************************************/
  // check for new command -------------------------------------------------------
  // if one available, return it...
  uint16_t MLSerial::Check_For_New_Command(){
    if (Serial.available() >= 2)
      return Read_Command();
    else
      return 0;
  }

  /******************************************************************************/
  // Timed_Command_Check only checks for command every so often
  // use this when it's more important for you code to run fast and it's fine
  // if a command is not read back immediately
  uint16_t MLSerial::Timed_Command_Check()
  {
    uint16_t newCommand = 0;
    // need to set cmdCheckInterval before calling this fct! default is 1000ms
    // check if we got a new serial command 
    if((millis()-lastCommandCheck) >= cmdCheckInterval)
    {
      lastCommandCheck = millis();
      newCommand = Check_For_New_Command();
      if (newCommand)
        return newCommand;
      else
        return 0; // no new command
    }
  }

  /******************************************************************************/
  uint8_t MLSerial::Serial_Read_8bit() {
    uint8_t readData = Serial.read();
    return readData; 
  }

  /******************************************************************************/
  uint16_t MLSerial::Serial_Read_16bit() {
    uint16_t readData = (Serial.read() << 0*8) + (Serial.read() << 1*8);
    return readData;  // read a 16-bit number from 2 bytes
  }

  /******************************************************************************/
  uint16_t MLSerial::Serial_Read_16bit(bool doWait) {
    if (doWait)
      Wait_Bytes(2);
    return Serial_Read_16bit();  
  }

  /******************************************************************************/
  uint32_t MLSerial::Serial_Read_32bit() {
    uint32_t readData = (Serial.read() << 0*8) + (Serial.read() << 1*8) +
      (Serial.read() << 2*8) + (Serial.read() << 3*8);
    return readData;  // read a 32-bit number from 4 bytes
  }

  /******************************************************************************/
  uint32_t MLSerial::Serial_Read_32bit(bool doWait) {
    if (doWait)
      Wait_Bytes(4);
    return Serial_Read_32bit();  
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_8bit(const uint8_t writeData){
    uwriteBuffer_.val = writeData;
    Serial.write(uwriteBuffer_.bytes, 1);
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_16bit(const uint16_t writeData){
    uwriteBuffer_.val = writeData;
    Serial.write(uwriteBuffer_.bytes, 2);
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_32bit(const uint32_t writeData){
    uwriteBuffer_.val = writeData;
    Serial.write(uwriteBuffer_.bytes, 4);
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_8bit(const int8_t writeData){
    writeBuffer_.val = writeData;
    Serial.write(writeBuffer_.bytes, 1);
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_16bit(const int16_t writeData){
    writeBuffer_.val = writeData;
    Serial.write(writeBuffer_.bytes, 2);
  }

  /******************************************************************************/
  void MLSerial::Serial_Write_32bit(const int32_t writeData){
    writeBuffer_.val = writeData;
    Serial.write(writeBuffer_.bytes, 4);
  }

  /******************************************************************************/
  // wait for the next, 2 byte long command
  void MLSerial::Wait_Next_Command(){
    Wait_Bytes(2);
  }

  /******************************************************************************/
    // wait for nBytes to be available
  void MLSerial::Wait_Bytes(const int nBytes){
    while(Serial.available() < nBytes){}
  }

  /******************************************************************************/
  // wait for nBytes to be available for a certain amount of time
  bool MLSerial::Wait_Bytes(const int nBytes, uint32_t waitTimeout){
    bool keepWaiting = true;
    bool waitedToLong = false;
    bool gotData = false;
    uint32_t startMillis = millis();
    while (keepWaiting){
      uint32_t waitedMillis =  millis() - startMillis;
      waitedToLong = waitedMillis > waitTimeout;
      gotData = (Serial.available() >= nBytes);
      keepWaiting = (!gotData && !waitedToLong);
    }
    return gotData; // return info if data is available or not
  }

  /****************************************************************************/
  // send uint16 command 
  void MLSerial::Send_Command(const uint16_t command){
    Serial_Write_16bit(command);
  }
  
  /****************************************************************************/
  // read uint16 command 
  uint16_t MLSerial::Read_Command(){
    return Serial_Read_16bit(); // read 2 bytes, aka one uint16 command
  }
}