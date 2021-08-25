% this file is intended to test the whole functionality of the class

clear all;
close all;

% before running, add the correct COMPORT here in the line below
comPort = 'COM11';

% CONNECTION TESTS

% make object without connecting, then manually connect
A = AbsoluteQuad(0);
A.serialPort = comPort;
A.Connect();
clear A;

% direct connection based on constructor variable
A = AbsoluteQuad(comPort);
clear A;

% check if we can close connection manually through close command
A = AbsoluteQuad(comPort);
A.Close(); % close connection
A.Connect(); % reopen connection
A.Check_Connection(); % check if connection checking works properly
A.Soft_Reset();
% fprintf("[unit_tests_absolutequad] Position of counter before reset: %f mm\n", A.pos);
% A.Reset_HCTL_Counter(); % check if we can reset the counter
% fprintf("[unit_tests_absolutequad] Position of counter after reset: %f mm\n", A.pos);
clear A;

% unit test for free running mode without number of shots
A = AbsoluteQuad(comPort);

tPts = [1, 5, 10];
for iTime = 1:3
	fprintf("[unit_tests_absolutequad] Running scope for %i sec\n", tPts(iTime));
	A.Enable_Scope_Mode(0);
	pause(tPts(iTime));
	A.Disable_Scope();
end

clear A;

% POSITION COUNTER TESTS
A = AbsoluteQuad(comPort);

fprintf("[unit_tests_absolutequad] Read position counter: %f.\n", A.posCount);
fprintf("[unit_tests_absolutequad] Read position: %f.\n", A.pos)


