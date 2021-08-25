% function [] = Connect(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

% Changelog:
%     - hopfmannu: adapted to serialport library

function [] = Connect(AQ)
  t1 = tic;
  if ~isempty(AQ.serialPtr) && AQ.isConnected
    AQ.VPrintF_With_ID('Already connected!\n');
  else
    AQ.VPrintF_With_ID('Connecting...');
    AQ.serialPtr = serialport(AQ.serialPort, AQ.baudRate);
    AQ.Done(t1);
  end
end
