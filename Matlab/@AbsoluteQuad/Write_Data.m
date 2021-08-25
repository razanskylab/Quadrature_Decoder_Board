% function [] = Write_Data(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Write_Data(AQ, data)
  if AQ.isConnected
    tic();
    % AQ.VVPrintF_With_ID(' Writing %i bytes of data...',numel(data));
    if ~isa(data,'uint8')
      warning('Data converted to uint8!');
      data = uint8(data);
    end
    write(AQ.serialPtr, data, 'uint8');
    % AQ.Done();
  else
    warning('Need to connect to Teensy before sening data!\n');
  end
end
