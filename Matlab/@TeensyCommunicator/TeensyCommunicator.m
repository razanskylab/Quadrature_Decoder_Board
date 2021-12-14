% File: TeensyCommunicator.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14.04.2020

% Description: Class interfacing with our position based trigger board.

classdef TeensyCommunicator < handle

	properties
		triggerFreq(1, 1) uint32 {mustBeNonnegative} = 100; % [Hz]
		triggerSteps(1, 1) uint32 = 100; % [microm]
		nShots(1, 1) uint32 {mustBeNonnegative} = 0; 
		% 0 means fire until serial stop, used for both position and frequency
		triggerType(1, 1) char = 'f'; % f for frequency based, s for scan based
		flagVerbose(1, 1) logical = 0; % turns off all the output
	end

	properties (SetAccess = private)
		port(1, :) char; % defines com port of teensy communicator
	end

	properties (SetAccess = private, Hidden)
		S = []; % serial port object
	end

	properties(Hidden, Constant)
		encoderResolution(1, 1) double = 2; % steps per microm
		BAUD_RATE(1, 1) double = 115200;
		TERMINATOR(1, :) char = 'CR';
	end

	properties(Dependent)
		isCorrectDevice(1, 1) logical;
		positionCounter(1, 1) uint16;
		position(1, 1) double; % [mm]
		isConnected(1, 1) logical = 0;
	end


	methods
		% Constructor
		function tc = TeensyCommunicator()

			% check if file exists and if so load port from there
			tc.port = get_com_port('Trigger'); % read com port
			
			tc.Connect();
			
			% if (~tc.isCorrectDevice)
			% 	error("We are connected to the wrong device");
			% end
		end

		% destructor
		function delete(tc)
			tc.Disconnect();
		end

		Clear_Serial_Input(tc); 
		Initialize(tc, reps); % sends configuration over to Teensy
		Start(tc);
		Start_Blind(tc); 
		Stop(tc);
		Disconnect(tc); % closes serial port connection to device
		Connect(tc); % opens serial port conenction and checks status
		Find_Com_Port(tc);
		Reset_Counter(tc); % resets the counter of the quadrature decoder board
		Update_Position(tc); % updates the position
		VPrintf(tc, txtMsg, flagName);

		function set.triggerFreq(tc, tf)
			tc.triggerFreq = uint32(tf);
		end

		function isCorrectDevice = get.isCorrectDevice(tc)
			write(tc.S, 'i', "uint8");
			response = readline(tc.S);
			isCorrectDevice = strcmp(response, "TeensyBasedTrigger");
		end

		function positionCounter = get.positionCounter(tc)
			write(tc.S, 'p', "uint8");
			positionCounter = uint32(str2double(readline(tc.S)));
		end

		function position = get.position(tc)
			position = double(tc.positionCounter) / tc.encoderResolution / 1e3;
		end

		function isConnected = get.isConnected(tc)
			if isempty(ts.S)
				isConnected = 0;
			else
				isConnected = 1;
			end
		end 
	end

end