% function [] = Update_Code(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Update_Firmware(Obj)
  % requires Platformio to be installed and to be added to the system path!
  Obj.Hor_Div();
  if Obj.isConnected
    Obj.Close();
  end
  Obj.VPrintF_With_ID('Updating code using Platformio:\n');
  Obj.Close();
  % path stuff to reliably move to firmware path
  thisFilePath = mfilename('fullpath');
  targetPath = fileparts(thisFilePath);
  matlabPath = cd(targetPath);
  cd ../../Firmware; % two paths "up" we find the firmware path
  Obj.PrintF('Compiling and uploading,this might take a few seconds...\n');
  % run power shell, compile and upload using platformio (needs to be correctly installed)
  Obj.PrintF('\n\n');
  [status,cmdReturn] = system('powershell platformio run --target upload','-echo');
  wasSuccess = contains(cmdReturn,'[SUCCESS]');
  if ~wasSuccess || status
    Obj.PrintF('\n\n');
    short_warn('Uploading firmware failed:');
    Obj.PrintF('%s',cmdReturn);
  else
    Obj.PrintF('\n\nUploading firmware was a big success!\n');
  end
  cd(matlabPath); % return to original path
  Obj.PrintF('Waiting for MCU to boot up again...');
  pause(Obj.MCU_BOOT_TIME); % wait a second for teensy to start back up...
  Obj.Connect();
  Obj.Flush_Serial();
  Obj.Hor_Div();
end
