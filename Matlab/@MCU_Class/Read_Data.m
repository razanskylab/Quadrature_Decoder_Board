% function [] = Read_Data(Obj)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [serialData] = Read_Data(Obj,nDataPoints,dataType)
  if Obj.isConnected
    if nargin == 1
      % no nDataPoints specified, read "all" available bytes as uint8...
      nDataPoints = Obj.bytesAvailable();
      dataType = "uint8";
    elseif nargin < 3
      error("Need to specify nDataPoints and dataType!");
    end
    serialData = Obj.SerialPortObj.read(nDataPoints,dataType);
      % NOTE not sure about order this is read back...
  else
    Obj.Verbose_Warn('Need to connect to MCU before reading data!\n');
  end

end


