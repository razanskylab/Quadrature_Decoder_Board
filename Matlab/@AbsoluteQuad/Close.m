% function [] = Close(obj)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Close(Obj)
  tic;

  if ~isempty(Obj.serialPtr) && Obj.isConnected
    Obj.VPrintF('[AQ] Closing connection to counter...');
    closePort(Obj.serialPtr);
    Obj.serialPtr = [];
    Obj.Done();
  else
    Obj.VPrintF('[AQ] Connection was not open!\n');
    Obj.isConnected = false;
  end

end
