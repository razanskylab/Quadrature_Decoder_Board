% File: Start.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 28.04.2020

% Description: Starts the position based trigger scheme.

function Start_Blind(tc)

	flush(tc.S);
	writeline(tc.S, 'x'); %, "uint8");

end