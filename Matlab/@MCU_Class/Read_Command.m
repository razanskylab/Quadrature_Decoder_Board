% function [] = Read_Data(Obj)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [command] = Read_Command(Obj)
  Obj.Wait_For_Bytes(2); % wait for one uint16 number, 
  command = Obj.Read_Data(1,"uint16");
end


