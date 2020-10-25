function [] = Write_32bit(PB,command)
  error("This needs some more love fo shure!");
  if ~isa(command,'uint32')
    error('Data must be uint32!');
  end
  command = typecast(command, 'uint8'); % commands send as 2 byte
  PB.Write_Data(command);
end
