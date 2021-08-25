% function [] = Disable_Scope(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Disable_Scope(AQ,timeOut)
  if nargin == 1
    timeOut = 1; % 5 seconds default timeout
  end

  % starts recording of the calibration data in the teensy
  t1 = tic();
  AQ.VPrintF_With_ID('Disabling scope trigger\n');

  AQ.Write_Command(AQ.STOP);
  AQ.Confirm_Command(AQ.STOP);
  
  % wait for data to come in...
  AQ.Wait_For_Bytes(4);
  
  [byteData, ~] = AQ.Read_Data(4); % get 32 bit trigger counter value
  AQ.lastTrigCount = double(typecast(byteData,'uint32'));
  
  AQ.VPrintF_With_ID(' Triggered %i times!\n', AQ.lastTrigCount);
  AQ.Wait_Done();
end
