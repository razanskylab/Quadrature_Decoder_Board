 % File: Connect.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 25.04.2019

function Connect(tc)

	tc.VPrintf('Connecting to device... ', 1);
	tc.S = serialport(tc.port, tc.BAUD_RATE);
	configureTerminator(tc.S, tc.TERMINATOR);
	flush(tc.S);

	if (~tc.isCorrectDevice)
		error("Seems to be an incorrect device which we just connected");
	end
	tc.VPrintf('done!\n', 1);

end