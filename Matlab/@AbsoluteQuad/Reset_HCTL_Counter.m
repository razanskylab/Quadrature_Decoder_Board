function Reset_HCTL_Counter(Obj)
  if Obj.isConnected
    t = tic();
    % Obj.Flush_Serial();
    flush(Obj.serialPtr);
    Obj.VPrintF_With_ID('Resetting HCTL counter...');
    Obj.Write_Command(Obj.RESET_HCTL_COUNTER);
    Obj.Confirm_Command(Obj.RESET_HCTL_COUNTER);
    Obj.Confirm_Command(Obj.DONE);
    Obj.Done(t);
  else
    short_warn('No serial connection established!\n');e
  end
end