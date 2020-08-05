% function [] = Update_Code(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Restart_Teensy(Obj)
  % make sure we can find the teensy software, which handles rebooting etc...
  % we assume this is located in the platformio packages folder, if this does 
  % not exist, we just stop here...
  usrFolder =  getenv('USERPROFILE');
  teensyFolder = [usrFolder '\.platformio\packages\tool-teensy\'];
  teensyExe = [teensyFolder 'teensy.exe'];
  teensyReboot = [teensyFolder 'teensy_reboot.exe'];
  Obj.VPrintF_With_ID('Checking for teensy toolbox for restart...');
  teensyFound = exist(teensyExe,'file') == 2;
  if ~teensyFound
    error('Can not find teensy.exe, make sure Platformio and teensy platform are installed!');
  else
    Obj.PrintF('found!\n');
  end

  Obj.VPrintF_With_ID('Restarting uC, this takes a few seconds.\n');
  if Obj.isConnected
    Obj.Close();
  end


  % cmd1 = sprintf('$port= new-Object System.IO.Ports.SerialPort %s,134,None,8,one',...
    % Obj.SERIAL_PORT);
  % cmd2 = '$port.open()';
  % cmd3 = '$port.Close()';
  % fullCmd = sprintf('powershell %s; %s; %s',cmd1, cmd2, cmd3);
  % [status] = system(fullCmd); % sends restart command

  system([teensyExe ' &']); % open teensy exe
  rebootStatus = system(teensyReboot); % run reboot

  % pause(0.25); % give matlab a chance to check what is going on, i.e. port is missing
  Obj.PrintF('  Restart initiated, waiting for teensy to show up\n');
  waitForPort = true;
  while(waitForPort)
    availPorts = serialportlist();
    if ~isempty(availPorts) && any(contains(availPorts,Obj.SERIAL_PORT))
      waitForPort = false;
      Obj.PrintF('\n');
    else
      waitForPort = true;
      Obj.PrintF('.');
      % pause(0.1); % don't run this while loop at full speed
    end
  end
  Obj.Connect();

  if rebootStatus
    Obj.PrintF('\n\n');
    short_warn('  Restart failed:');
  else
    Obj.PrintF('  Microcontroller restarted successfully!\n');
    Obj.PrintF('  You can close the opened windows!\n');
  end

end


