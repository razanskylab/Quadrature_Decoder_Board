% function [] = Disable_Scope(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Disable_Free_Running_Trigger(AQ)
  % starts recording of the calibration data in the teensy
  AQ.VPrintF_With_ID('Disabling free running trigger.\n');
  AQ.Write_Command(AQ.STOP);
  
  % we expect MCU to send back stop command, then the trigger count, then DONE
  AQ.Confirm_Command(AQ.STOP);
  AQ.Wait_For_Bytes(4); % wait for 32bit number
  AQ.lastTrigCount = double(AQ.Read_Data(1,'uint32'));
  AQ.Confirm_Command(AQ.DONE);
  AQ.VPrintF_With_ID('Triggered %i times!\n',AQ.lastTrigCount);
end
