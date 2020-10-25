% function [] = Enable_Scope_Mode(Obj)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Free_Running_Trigger(Obj,nTrigger)
  % starts recording of the calibration data in the teensy
  %  triggerPeriod = serial_read_16bit();
  %  nTrigger = serial_read_16bit(); // trigger how many times?
  if nargin == 1
    nTrigger = 0; % default scope mode, i.e. free running
  end

  freqStr = num2sip(Obj.samplingFreq);
  if (nTrigger == 0)
    Obj.VPrintF_With_ID('Enabling free-running trigger @%sHz.\n',freqStr);
  else
    Obj.VPrintF_With_ID('Enabling %i trigger @%sHz.\n',nTrigger,freqStr);
  end
  
  triggerPeriod = uint16(Obj.samplingPeriod);
  nTrigger = uint16(nTrigger);
  slowMode = uint16(Obj.slowSampling);

  Obj.Flush_Serial();
  Obj.Write_Command(Obj.START_FREE_RUNNING_TRIGGER);
  if Obj.Confirm_Command(Obj.START_FREE_RUNNING_TRIGGER);

    Obj.Write_Data(slowMode);
    Obj.Write_Data(triggerPeriod);
    Obj.Write_Data(nTrigger);

    % make sure MCU understood us correctly...
    if (slowMode ~= Obj.Read_Data(1,'uint16'))
      short_warn('slowMode error');
    end
    if (triggerPeriod ~= Obj.Read_Data(1,'uint16'))
      short_warn('slowMode error');
    end
    if (nTrigger ~= Obj.Read_Data(1,'uint16'))
      short_warn('slowMode error');
    end
  else
    error('Error during Enable_Free_Running_Trigger...');
  end

end
