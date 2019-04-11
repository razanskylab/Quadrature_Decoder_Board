

writePort(portPointer, typecast(uint16(77), 'uint8'));
% writePort(portPointer, typecast(uint16(77), 'uint8'));

nDataPoints = uint16(256/2);
writePort(portPointer, typecast(nDataPoints, 'uint8'));

numBytesToRead = double(nDataPoints*2); % factor 2 because we send 16 bit ints
% pause(0.5);
[byteStream , leftOverBytesInBuffer] = readPort(portPointer, numBytesToRead);

%% convert to uint16 again
posCounter = typecast(byteStream,'uint16');
