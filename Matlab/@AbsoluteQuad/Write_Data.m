% function [] = Write_Data(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Write_Data(AQ,data)
  if AQ.isConnected
    tic();
    % AQ.VVPrintF_With_ID(' Writing %i bytes of data...',numel(data));
    if ~isa(data,'uint8')
      AQ.Verbose_Warn('   Data converted to uint8!');
      data = uint8(data);
    end
    writePort(AQ.serialPtr,data);
    % AQ.Done();
  else
    AQ.Verbose_Warn('Need to connect to Teensy before sening data!\n');
  end
end
