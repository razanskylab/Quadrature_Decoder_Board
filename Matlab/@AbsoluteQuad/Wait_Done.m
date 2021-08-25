% function [] = Wait_Done(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [success] = Wait_Done(AQ,timeOut)
  success = false;
  if nargin == 1
    timeOut = 3; % 1 seconds default timeout
  end
  t1 = tic;
  % wait for ready command...
  AQ.Wait_For_Bytes(2);

  [~, answer] = AQ.Read_Data();
  if answer ~= AQ.DONE
    error('[AQ] Something went wrong in the teensy!');
  else
    success = true;
  end
end
