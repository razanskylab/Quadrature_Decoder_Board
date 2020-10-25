% function [] = Close(VCS)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Close(Obj)
  tic;
  if ~isempty(Obj.SerialPortObj)
    Obj.VPrintF_With_ID('Closing connection...');
    Obj.SerialPortObj = [];
    Obj.Done();
  else
    Obj.VPrintF_With_ID('Connection was not open!\n');
  end

end
