% function [] = Enable_Scope_Mode(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Scope_Mode(AQ,nTrigger)
  % starts recording of the calibration data in the teensy
  %  triggerPeriod = serial_read_16bit();
  %  nTrigger = serial_read_16bit(); // trigger how many times?
  if nargin == 1
    nTrigger = 0; % default scope mode, i.e. free running
  end

  slowMode = uint16(AQ.slowSampling);
  triggerPeriod = uint16(AQ.samplingPeriod);
  nTrigger = uint16(nTrigger);

  if (nTrigger == 0)
    AQ.VPrintF_With_ID(...
      'Enabling free-running trigger @ %2.2f kHz.\n', AQ.samplingFreq * 1e-3);
  else
    AQ.VPrintF_With_ID(...
      'Enabling %i trigger @ %2.2f kHz.\n', nTrigger, AQ.samplingFreq * 1e-3);
  end

  AQ.Write_Command(AQ.START_FREE_RUNNING_TRIGGER); % write command to microcontroller
  AQ.Confirm_Command(AQ.START_FREE_RUNNING_TRIGGER); % wait for handshake

  % push configuration data over to microcontroller 
  write(AQ.serialPtr, slowMode, 'uint16');
  write(AQ.serialPtr, triggerPeriod, 'uint16');
  write(AQ.serialPtr, nTrigger, 'uint16');

  % check that configuration was defined correctly
  slowModeResponse = read(AQ.serialPtr, 1, 'uint16');
  triggerPeriodResponse = read(AQ.serialPtr, 1, 'uint16');
  nTriggerResponse = read(AQ.serialPtr, 1, 'uint16');

  checkArray = ~[...
    slowMode == slowModeResponse, ...
    triggerPeriod == triggerPeriodResponse, ...
    nTrigger == nTriggerResponse];

  if any(checkArray)
    error("Wrong configuration received from Terensy");
  end

end
