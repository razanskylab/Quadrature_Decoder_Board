% function [] = Read_Data(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [byteData, twoByteData] = Read_Data(AQ, nBytes)

  if nargin == 1 % no nBytes specified, read "all" available bytes 
    fprintf('lets manually define');
    nBytes = AQ.serialPtr.NumBytesAvailable;
    % if too many bytes are available, only read max. available bytes
    nBytes = min(nBytes, AQ.MAX_BYTE_PER_READ); % make sure we don't try and read to many
  end

  if nBytes > AQ.MAX_BYTE_PER_READ
    error('Can''t read more than %i bytes at once!',...
      AQ.MAX_BYTE_PER_READ);
  end

  byteData = uint8(read(AQ.serialPtr, nBytes, 'uint8'));
  % tic();
  % AQ.VVPrintF_With_ID(' Reading %i bytes of data...',nBytes);
  % byteData = readPort(AQ.serialPtr, nBytes);

  %% convert to uint16 again
  twoByteData = typecast(byteData, 'uint16');

  % AQ.Done();
end
