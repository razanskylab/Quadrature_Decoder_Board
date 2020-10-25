function [] = Write_Command(PB,command)
  if ~isa(command,'uint16')
    error('Commands must be uint16!');
  end
  PB.Write_Data(command);
end
