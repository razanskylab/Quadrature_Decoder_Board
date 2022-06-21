% File: Handshake.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: mail@hofmannu.org
% Date: 22.03.2022

function returnVal = Handshake(tc)

	returnVal = read(tc.S, 1, "uint8");
	if (returnVal == tc.OK)
		% nothing to do, handshake was nice
	elseif (returnVal == tc.WARNING)
		warning("Controller did throw warning");
	elseif (returnVal == tc.ERROR)
		error("Something went wronmg during execution, microcontroller returned error");
	elseif (isempty(returnVal))
		error("The microcontroller did not return anything (empty response)");
	else
		errMsg = sprintf("Invalid return from microcontroller during handshake: %d", ...
			returnVal);
		error(errMsg);
	end

end