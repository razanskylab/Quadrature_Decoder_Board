% File: Disconnect.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 22.07.2020

% Description: Clears the serial object, closing its connection

function Disconnect(tc)
	tc.S = []; % simply delete serial object to free it
end