% File: Update_Position.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 01.05.2020

% Description: Updates the position of stage and sends it to matlab trhough serial

function Update_Position(tc)

	write(tc.S, 'p', "uint8");
	position = str2double(readline(tc.S));
	position = position / tc.encoderResolution / 1000

end