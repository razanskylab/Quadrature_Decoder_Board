% function [] = Write_Data(Obj)
% write data in native format to mcu
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Write_Data(Obj,data)
  if Obj.isConnected
    dataType = class(data);
    Obj.SerialPortObj.write(data,dataType);
  else
    Obj.Verbose_Warn('Need to connect to MCU before sending data!\n');
  end
end
