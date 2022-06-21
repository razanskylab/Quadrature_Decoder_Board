% File: Stop.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 01.05.2020

% TODO Add check if command execution was successfull

function Stop(tc)

	fprintf("[TeensyCommunicator] Stopping freq based trigger... ");
	write(tc.S, tc.STOP_FREQ, "uint8");
	tc.Handshake();
	fprintf("done!\n");

end