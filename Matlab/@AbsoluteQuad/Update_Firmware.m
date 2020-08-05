% function [] = Update_Code(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Update_Firmware(Obj)
  % requires Platformio to be installed and to be added to the system path!
  Obj.Hor_Div();
  if Obj.isConnected
    Obj.Close();
  end
  Obj.PrintF('[%s] Updating teensy code using Platformio:\n',Obj.ID);
  Obj.Close();
  % get path to matlab class file, then navigate to Firmware folder from
  % there
  classPath = which('AbsoluteQuad');
  basePath = classPath(1:strfind(classPath,'Matlab')-1);
  matlabPath = cd([basePath '\Firmware\']);
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
  pause(1); % wait a second for teensy to start back up...
  Obj.Connect();
  Obj.Hor_Div();
end
