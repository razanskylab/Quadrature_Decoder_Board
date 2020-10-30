% function [] = Read_Data(Obj)
% check if checkCommand was recieved
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [confirmed] = Confirm_Command(Obj,checkCommand)
  gotData = Obj.Wait_For_Bytes(2); % wait for one uint16 number, our command
  
  if gotData
    recievedCommand = Obj.Read_Data(1,"uint16");
  else
    short_warn('Could not confirm recieved command!\n');
    confirmed = false;
    return;
  end

  if (recievedCommand == checkCommand)
    confirmed = true;
  else
    short_warn('Could not confirm recieved command!\n');
    warnString = sprintf('   Expected: %i, Recieved: %i\n',checkCommand, recievedCommand);
    short_warn(warnString);
    confirmed = false;
  end
end


