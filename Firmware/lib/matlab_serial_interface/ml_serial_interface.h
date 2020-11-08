#ifndef ML_SERIAL_INTERFACE
#define ML_SERIAL_INTERFACE

#include <Arduino.h>

namespace mlSerial {

  // used to send signed integers over serial port
  union WriteBuffer {
    uint8_t bytes[8];
    int64_t val;
  };
  
  // used to send unsigned integers over serial port
  union UWriteBuffer {
    uint8_t bytes[8];
    uint64_t val;
  };

  // used to send unsigned integers over serial port
  union FloatingWriteBuffer {
    uint8_t bytes[4];
    float val;
  };

  // used to send unsigned integers over serial port
  union DoubleWriteBuffer {
    uint8_t bytes[8];
    double val;
  };

  class MLSerial{
  public:
    uint16_t Check_For_New_Command();
    uint16_t Timed_Command_Check();

    uint8_t  Serial_Read_8bit();
    uint16_t Serial_Read_16bit();
    uint16_t Serial_Read_16bit(bool doWait);
    uint32_t Serial_Read_32bit();
    uint32_t Serial_Read_32bit(bool doWait);

    // send uint data as bytes over serial port

    // send uint data as bytes over serial port
    void Serial_Write_8bit(uint8_t writeData);
    void Serial_Write_16bit(uint16_t writeData);
    void Serial_Write_32bit(uint32_t writeData);
    
    // send int data as bytes over serial port
    void Serial_Write_8bit(int8_t writeData);
    void Serial_Write_16bit(int16_t writeData);
    void Serial_Write_32bit(int32_t writeData);

    void Serial_Write_Float(float writeData);
    void Serial_Write_Double(double writeData);

    // general commands
    void Wait_Next_Command();
    void Wait_Bytes(const int nBytes);
    bool Wait_Bytes(const int nBytes, uint32_t waitTimeout);

    void Send_Command(const uint16_t command);
    uint16_t Read_Command(); 

  private:
    WriteBuffer writeBuffer_;
    UWriteBuffer uwriteBuffer_;
    FloatingWriteBuffer flwriteBuffer_;
    DoubleWriteBuffer doubwriteBuffer_;

    uint32_t lastCommandCheck = 0;
    uint32_t cmdCheckInterval = 1000; // how ofter to check for a new command

  }; // MLSerial - class def
} // mlSerial namespace

#endif // ML_SERIAL_INTERFACE