% File: Start.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 28.04.2020

% Description: Starts the position based trigger scheme.
% Changelog:
% 		- include handshake if procedure done

function Start(tc)

	flush(tc.S);
	writeline(tc.S, 'x'); %, "uint8");

	response = char(read(tc.S, 2, "string"));
	if ~strcmp(response(1), "r")
		error('Teensy did not give handshake for start command');
	end

end