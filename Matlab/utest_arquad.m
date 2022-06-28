
clear all; close all;

T = PositionBasedTriggerCommunicator('COM4');

for i=1:10
	T.Identify();
end

% test set frequency
fprintf("Defining different temporal frequencies... ");
freqsList = single(0.1:10:200);
for iFreq = 1:length(freqsList)
	T.triggerFreq = freqsList(iFreq); % has inherent check, set triggerFreg to Arduino

	% test get frequency
	setFreq = T.triggerFreq; %get TriggerFreq from Arduino
	if (freqsList(iFreq) ~= setFreq )
		strMsg = sprintf("Device returned %f instead of %f", ...
			freqsList(iFreq), setFreq);
		error(strMsg);
	end
end
fprintf("done!\n");

% test set spatial frequency
fprintf("Defining different spatial frequencies... ");
freqsList = uint32(1:10:200);
for iFreq = 1:length(freqsList)
	T.triggerSteps = freqsList(iFreq); % has inherent check, set

	% test get frequency
	setFreq = T.triggerSteps;
	if (freqsList(iFreq) ~= setFreq)
		strMsg = sprintf("Device returned %d instead of %d", ...
			freqsList(iFreq), setFreq);
		error(strMsg);
	end
end
fprintf("done!\n");

fprintf("Defining pins... ");
for iPin = 0:1:2
	T.trigPin = iPin;
end


fprintf("done!\n");

if (T.trigPin ~= 2)
	error("Some pins are not being set correctly");
end

% try setting an invalid pin
try 
	T.trigPin = 10;
	% error("Setting this value should not be allows");
catch ME	
	if ~strcmp(ME.message, 'Something went wrong while setting the trigger pin')
		error("This should throw a different error");
	end
end


nShots = 0:10:1000;
for (iShot = 1:length(nShots))
	T.nShots = nShots(iShot);
	if (nShots(iShot) ~= T.nShots)
		error("Something went wrong while receiving the trigger freqeuncy");
	end
end

% T.trigPin
T.nShots = 100;
for i = 1:10
	T.StartFreq();
end % Start freq trigger (100 shots at 190.10 Hz)... done after 0.53 sec!

T.nShots = 0; %set noShots=0 to Arduino, means permanent fire
tPause = linspace(0.1, 10, 10);
for i=1:length(tPause)
	T.StartFreq();
	pause(tPause(i));
	T.StopFreq();
end   %Some problem when showing (0 shots at 190.10 Hz), actually it's many shots

T.Identify();

clear all;