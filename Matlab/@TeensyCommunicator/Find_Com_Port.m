% File: Find_Com_Port.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 29.04.2019

% Description: Is used to determine on which com port teensy is connected.

function Find_Com_Port(tc)

	portArray = seriallist(); % get list containing all com ports
	nDevices = length(portArray); % number of com ports
	flagFound = 0; % indicates if com port was already found

	for iDevice = 1:nDevices % check through all devices
		if (flagFound == 0) % only perform this if we did not find teensy yet
			try
				obj = serial(portArray(iDevice)); % define serial object
				obj.BaudRate = 115200; % set baudrate
				obj.Timeout = 1; % set timeoput in sec
				fopen(obj); % open port
				fprintf(obj, 'i'); % request id
		    	pause(0.1);
				response = fscanf(obj); % read response from device
				if strcmp(response, 'TeensyBasedTrigger')
					fprintf('[TeensyCommunicator] Found TeensyBasedTrigger on port %s\n', portArray(iDevice));
					tc.port = portArray(iDevice); % assign port to class
					flagFound = 1;
				end
				fclose(obj); % close com port
			catch
				% do nothing if it did not work
			end
		end
	end

	if flagFound == 0
		error('Could not find position based trigger anywhere.');
	else % if found save port for future reference
		port_teensycommunicator = tc.port; % need to do this because we cannot save class properties directly
		if isfile(get_path('com_file')) % if file exists do not overwrite but append
			save(get_path('com_file'), 'port_teensycommunicator', '-append');
		else
			save(get_path('com_file'), 'port_teensycommunicator');
		end
	end

end