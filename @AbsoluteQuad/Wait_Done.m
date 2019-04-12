% function [] = Wait_Done(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [success] = Wait_Done(AQ,timeOut)
  success = false;
  if nargin == 1
    timeOut = 3; % 1 seconds default timeout
  end
  t1 = tic;
  % wait for ready command...
  while (AQ.bytesAvailable<2)
    if toc(t1) > timeOut
      AQ.Verbose_Warn('Teensy response timeout!\n');
      return;
    end
  end

  [~,answer] = AQ.Read_Data();
  if answer ~= AQ.DONE
    error('[AQ] Something went wrong in the teensy!');
  else
    success = true;
  end
end
