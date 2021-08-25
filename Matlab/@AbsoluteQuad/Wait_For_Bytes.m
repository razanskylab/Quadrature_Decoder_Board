% File: Wait_For_Bytes.m @ AbsoluteQuad
% Author: hofmannu, reglingj, liwe
% Date: 24.08.2021
% Mail: hofmannu@ethz.ch

% descriptions: holds the program until the specified number of bytes await us

function Wait_For_Bytes(aq, numBytes)
	t1 = tic; % start stopwatch for timeout
	while(aq.serialPtr.NumBytesAvailable < numBytes)
		if toc(t1) > aq.timeOut
			error("Teensy response timeout");
		end
		% do nothing
	end

end