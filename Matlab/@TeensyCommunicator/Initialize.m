% File: Initialize.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14.04.2020

% Description: Pushs information about both scan pattern and freq over 
% to teensy

function Initialize(tc)

	tc.Clear_Serial_Input();

	% either use triggerFreq or triggerSteps 
	if (tc.triggerType == 'f')
		freq = tc.triggerFreq;
	elseif (tc.triggerType == 's')
		freq = tc.triggerSteps;			
	else
		error('Unknown trigger mode');
	end

	string = [tc.triggerType, ...
			typecast(uint32(freq), 'uint8'), ...
			typecast(uint32(tc.nShots), 'uint8')];

	write(tc.S, string, "uint8");
	pause(0.01);
	response = readline(tc.S);
	idealResp = [tc.triggerType, ': ', num2str(freq), ' x ', num2str(tc.nShots)];

	% check response
	if ~strcmp(idealResp, response)
		txtMsg = ['Trigger board gave bad response: ', char(response)];
		error(txtMsg);
	end

end