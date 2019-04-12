% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [byteAnswer,twoByteAnswer] = Wait_Data(AQ,timeOut)
  if nargin == 1
    timeOut = 1; % 5 seconds default timeout
  end
  t1 = tic;
  % wait for data to come in...
  while (AQ.bytesAvailable<2)
    if toc(t1) > timeOut
      AQ.Verbose_Warn('Teensy response timeout!\n');
      return;
    end
  end
  [byteAnswer,twoByteAnswer] = AQ.Read_Data();

end
