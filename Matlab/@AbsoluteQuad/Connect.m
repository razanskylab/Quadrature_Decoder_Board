% function [] = Connect(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Connect(AQ)
  t1 = tic;
  if ~isempty(AQ.serialPtr) && AQ.isConnected
    AQ.VPrintF_With_ID('Already connected!\n');
  else
    AQ.VPrintF_With_ID('Connecting...');
    try
      AQ.serialPtr = openPort(AQ.SERIAL_PORT,AQ.BAUD_RATE);
      AQ.isConnected = true;
      AQ.Done(t1);
    catch
      drawnow();
      AQ.Verbose_Warn('Opening serial connection failed!');
      AQ.Verbose_Warn('Is the white USB cable (green tape) connected?\n');
    end
  end
end
