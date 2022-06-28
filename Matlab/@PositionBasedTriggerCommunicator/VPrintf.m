% File: VPrintf.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 28.05.2020

% Description: Verbose output of class

function VPrintf(tc, txtMsg, flagName)

	if tc.flagVerbose
		if flagName
			txtMsg = ['[PositionBasedTrigger] ', txtMsg];
		end
		fprintf(txtMsg);
	end

end