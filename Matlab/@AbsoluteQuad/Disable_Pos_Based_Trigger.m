% read back data once stage AQ has finished it's pos-based triggering
% force stop of triggering when called with doForce = true;
% only works if stage is not in trigger range (there we do nothing but trigger)

function [success] = Disable_Pos_Based_Trigger(Obj,doForce)
  success = false;
  Obj.VPrintF_With_ID('Disabling position based trigger: ');
  if nargin<2
    doForce = false;
  end

  if doForce
    Obj.Write_Command(Obj.STOP)
  end

  % read back stop command, uint32 number with trigger count and DONE command
  conf = Obj.Confirm_Command(Obj.STOP);
  if ~conf
    short_warn('MCU not responding!');
    return;
  end
  Obj.Wait_For_Bytes(4); % wait for 32bit number
  Obj.lastTrigCount = double(Obj.Read_Data(1,'uint32'));
  Obj.Confirm_Command(Obj.DONE);
  if ~conf
    short_warn('MCU not responding!');
    success = false;
  else
    Obj.VPrintF('Triggered %i times!\n',Obj.lastTrigCount);
    success = true;
  end

end
