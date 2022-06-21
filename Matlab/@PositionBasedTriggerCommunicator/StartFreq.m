% File: StartFreq.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 28.04.2020

% Description: Starts the timedomain based trigger scheme (SNRScope for example)
% Changelog:
% 		- include handshake if procedure done

function StartFreq(tc)
	freq = tc.triggerFreq;
	nShots = tc.nShots;

	fprintf("[TeensyCommunicator] Start freq trigger (%d shots at %.2f Hz)... ", ...
		nShots, freq);
	tStart = tic();

	write(tc.S, tc.START_FREQ, "uint8");
	tc.Handshake();

	% if the number of triggers is limited, we wait here for execution termination
	if (nShots > 0)
		% IF WE PLAN TO TRIGGER FOR LONG MAKE SURE THAT WE DO NOT RUN INTO A TIMEOUT
		tDelay = single(nShots) / freq;
		if (tDelay > 1)
			pause(tDelay - 0.2);
		end

		tc.Handshake();
		tStop = toc(tStart);
		fprintf("done after %.2f sec!\n", tStop);
	else
		fprintf("done!\n");
	end


end