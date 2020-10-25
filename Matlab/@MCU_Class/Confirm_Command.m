% function [] = Read_Data(Obj)
% check if checkCommand was recieved
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [confirmed] = Confirm_Command(Obj,checkCommand)
  Obj.Wait_For_Bytes(2); % wait for one uint16 number, our command
  recievedCommand = Obj.Read_Data(1,"uint16");
  if (recievedCommand == checkCommand)
    confirmed = true;
  else
    short_warn('Could not confirm recieved command!\n');
    warnString = sprintf('   Expected: %i, Recieved: %i\n',checkCommand, recievedCommand);
    short_warn(warnString);
  end
end


