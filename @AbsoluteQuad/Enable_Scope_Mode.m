% function [] = Enable_Scope_Mode(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Scope_Mode(AQ,nTrigger)
  % starts recording of the calibration data in the teensy
  %  triggerPeriod = serial_read_16bit();
  %  nTrigger = serial_read_16bit(); // trigger how many times?
  if nargin == 1
    nTrigger = 0; % default scope mode, i.e. free running
  end

  triggerPeriod = uint16(AQ.samplingPeriod);
  nTrigger = uint16(nTrigger);
  slowMode = uint16(AQ.slowSampling)

  if (nTrigger == 0)
    AQ.PrintF('[AQ] Enabling free-running trigger @ %2.2fkHz.\n',AQ.samplingFreq*1e-3);
  else
    AQ.PrintF('[AQ] Enabling %i trigger @ %2.2fkHz.\n',nTrigger,AQ.samplingFreq*1e-3);
  end

  AQ.Write_Command(AQ.ENABLE_SCOPE_MODE);
  AQ.Write_16Bit(slowMode);
  AQ.Write_16Bit(triggerPeriod);
  AQ.Write_16Bit(nTrigger);
end
