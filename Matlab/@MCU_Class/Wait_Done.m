% function [] = Wait_Done(Obj)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [success] = Wait_Done(Obj)
  Obj.Wait_For_Bytes(2);
  
  answer = Obj.Read_Data(1,'uint16');
  if answer ~= Obj.DONE
    short_warn('[MCU] unexpected return value:');
    success = false;
  else
    success = true;
  end
end
