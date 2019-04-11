% function [] = Disable_Pos_Based_Trigger(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Disable_Pos_Based_Trigger(AQ)
% starts recording of the calibration data in the teensy
  t1 = tic();
  AQ.PrintF('[AQ] Disabling position based trigger\n');
  AQ.Write_Command(AQ.DISABLE_POS_TRIGGER);
  while (AQ.bytesAvailable<4)
  end
  [byteData,twoByteData] = AQ.Read_Data(4); % get 32 bit trigger counter value
  AQ.lastTrigCount = double(typecast(byteData,'uint32'));
  AQ.VPrintF('[AQ] Triggered %i times!\n',AQ.lastTrigCount);
  AQ.Wait_Done();
end
