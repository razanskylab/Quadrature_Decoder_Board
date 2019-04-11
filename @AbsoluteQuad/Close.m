% function [] = Close(VCS)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Close(AQ)
  tic;

  if ~isempty(AQ.serialPtr) && AQ.isConnected
    AQ.VPrintF('[AQ] Closing connection to counter...');
    closePort(AQ.serialPtr);
    AQ.serialPtr = [];
    AQ.Done();
  else
    AQ.VPrintF('[AQ] Connection was not open!\n');
  end

end
