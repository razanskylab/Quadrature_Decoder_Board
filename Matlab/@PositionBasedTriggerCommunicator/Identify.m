% File 		Identify.m @ TeensyCommunicator
% Author 	Urs Hofmann
% Mail 		mail@hofmannu.org
% Date 		21.03.2022

% Description: requests an identification ID from device

function Identify(tc)

	tStart = tic();
	fprintf("[TeensyCommunicator] Identifying device... ");

	write(tc.S, tc.IDENTIFY, "uint8");
	returnId = read(tc.S, 1, "uint16");
	if (returnId ~= tc.IDENTIFIER)
		strMsg = sprintf("Invalid ID %d returned from device", returnId);
		error(strMsg);
	end

	tc.Handshake();
	fprintf("done after %.2f sec!\n", toc(tStart));

end