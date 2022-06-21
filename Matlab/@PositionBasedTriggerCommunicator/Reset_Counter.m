% File: Reset_Counter.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 01.05.2020

% Description: Resets quadrature decoding counter chip

% Changelog:
% 	- add handshake

function Reset_Counter(tc)

	tc.VPrintf('Resetting counter.\n', 1);
	flush(tc.S);
	write(tc.S, 'r', "uint8");

	% afterwards wait for handshake
	response = char(read(tc.S, 2, "string"));
	if ~strcmp(response(1), "r")
		error('Teensy did not give handshake for start command');
	end

end