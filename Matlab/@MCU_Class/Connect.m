% function [] = Connect(Obj)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Connect(Obj)
  tic;
  if ~isempty(Obj.SerialPortObj)
    Obj.VPrintF_With_ID('Already connected!\n');
    return;
  end

  % NOTE DO NOT use serialportlist as this resets the ESP32
  % comsReady = serialportlist("available")'; % get list of available com port
  % portAvailable = any(strcmp(comsReady,Obj.serialPort));
  Obj.VPrintF_With_ID('Connecting to MCU...');
  try
    Obj.SerialPortObj = serialport(Obj.serialPort,Obj.baudRate);
    % setting rts and dtr to false makes sure MCU does not reset 
    % when matlab disconnects
    Obj.SerialPortObj.setRTS(false);
    Obj.SerialPortObj.setDTR(false);
    Obj.SerialPortObj.Timeout = Obj.SERIAL_TIMEOUT;
    Obj.Done();
  catch ME
    Obj.VPrintF('\n');
    Obj.Verbose_Warn('Opening serial connection failed!\n');
    rethrow(ME);
  end
  pause(1);
  Obj.Flush_Serial();
  Obj.Check_Connection();

end
