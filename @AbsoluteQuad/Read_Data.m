% function [] = Read_Data(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [byteData,twoByteData] = Read_Data(AQ,nBytes)
  if nargin == 1
    % no nBytes specified, read "all" available bytes
    nBytes = AQ.bytesAvailable();
    % if too many bytes are available, only read max. available bytes
    nBytes = min(nBytes,AQ.MAX_BYTE_PER_READ); % make sure we don't try and read to many
  end

  if nBytes > AQ.MAX_BYTE_PER_READ
    errMessage = sprintf('Can''t read more than %i bytes at once!',AQ.MAX_BYTE_PER_READ);
    error(errMessage);
  end

  % tic();
  % AQ.VPrintF('[AQ] Reading %i bytes of data...',nBytes);
  byteData = readPort(AQ.serialPtr, nBytes);

  %% convert to uint16 again
  twoByteData = typecast(byteData,'uint16');

  % AQ.Done();
end
