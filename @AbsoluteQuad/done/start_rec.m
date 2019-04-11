sampl_per=10000;

writePort(portPointer, typecast(uint16(66), 'uint8'));

nDataPoints_16 = uint16(sampl_per);

writePort(portPointer, typecast(nDataPoints_16, 'uint8'));
