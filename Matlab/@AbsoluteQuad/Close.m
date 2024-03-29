% function [] = Close(obj)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Close(Obj)
  tic;

  if ~isempty(Obj.serialPtr) && Obj.isConnected
    Obj.VPrintF_With_ID('Closing connection to counter...');
    Obj.serialPtr = [];
    Obj.Done();
  else
    Obj.VPrintF_With_ID('Connection was not open!\n');
    Obj.isConnected = false;
  end

end
