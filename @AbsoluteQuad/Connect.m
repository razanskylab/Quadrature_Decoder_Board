% function [] = Connect(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Connect(AQ)
  if ~isempty(AQ.serialPtr) && AQ.isConnected
    AQ.VPrintF('[AQ] Counter already connected!\n');
  else
    tic;
    AQ.VPrintF('[AQ] Connecting to counter...');
    try
      tic();
      AQ.serialPtr = openPort(AQ.SERIAL_PORT,AQ.BAUD_RATE);
      AQ.isConnected = true;
      % read back identifier to make sure we have a working connection
      % TODO
      AQ.Done();
    catch me
      AQ.VPrintF('\n');
      AQ.Verbose_Warn('Opening serial connection failed!\n');
  end
end
