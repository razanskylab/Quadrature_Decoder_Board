% AbsoluteQuad
function [] = Restart_Teensy(Obj)
  Obj.VPrintF_With_ID('Restarting teensy MCU, this takes a second...\n');
  if Obj.isConnected
    Obj.Close();
  end
  % requires tycmd tool located at the following path...
  % download at https://github.com/Koromix/tytools 
  cmd1 = sprintf('C:\\Code\\TyTools\\tycmd.exe reset --board=%s',...
    Obj.TEENSY_ID);
  fullCmd = sprintf('powershell %s',cmd1);

  [status] = system(fullCmd); % sends restart command
  pause(0.25); % give matlab a chance to check what is going on, i.e. port is missing

  waitForPort = true;
  while(waitForPort)
    availPorts = serialportlist();
    if ~isempty(availPorts) && any(contains(availPorts,Obj.serialPort))
      waitForPort = false;
    else
      waitForPort = true;
      pause(0.1); % don't run this while loop at full speed
    end
  end
  Obj.Connect();

  if status
    Obj.VPrintF_With_ID('\n\n');
    short_warn('Restart failed:');
  else
    Obj.VPrintF_With_ID('Teensy restarted successfully!\n');
    short_warn('HCTL counter needs to be reset via F.Reset_Pos_Counter();!\n');
  end

end
