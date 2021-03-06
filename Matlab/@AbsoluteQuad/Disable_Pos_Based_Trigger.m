% function [] = Disable_Pos_Based_Trigger(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Disable_Pos_Based_Trigger(AQ,timeOut)
  if nargin == 1
    timeOut = 1; % 5 seconds default timeout
  end

  t1 = tic();
  AQ.VPrintF_With_ID('Disabling position based trigger: ');
  % AQ.Write_Command(AQ.DISABLE_POS_TRIGGER);
  % wait for data to come in...
  while (AQ.bytesAvailable<4)
    if toc(t1) > timeOut
      AQ.Verbose_Warn('Teensy response timeout!\n');
      AQ.lastTrigCount = 0;
      return;
    end
  end
  [byteData,~] = AQ.Read_Data(4); % get 32 bit trigger counter value
  AQ.lastTrigCount = double(typecast(byteData,'uint32'));
  AQ.VPrintF('Triggered %i times!\n',AQ.lastTrigCount);
  AQ.Wait_Done(); % last thing teensy sends is an OK, we are done

end
