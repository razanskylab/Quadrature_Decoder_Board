% File: TeensyCommunicator.m @ TeensyCommunicator
% Author: Urs Hofmann
% Mail: hofmannu@biomed.ee.ethz.ch
% Date: 14.04.2020

% Description: Class interfacing with our position based trigger board.

classdef PositionBasedTriggerCommunicator < handle

	properties
		flagVerbose(1, 1) logical = 0; % turns off all the output
		S = []; % serialport object
	end

	properties (SetAccess = private)
		port(1, :) char; % defines com port of teensy communicator
		isRunning(1, 1) logical = 0;
	end

	properties (SetAccess = private, Hidden)
	end

	properties(Dependent)
		nShots(1, 1) uint32; % number of shots during freq trigger
		nSteps(1, 1) uint32; % number of steps during scan
		triggerFreq(1, 1) single {mustBeNonnegative}; % [Hz]
		triggerSteps(1, 1) uint32; % [microm]
		trigPin(1, 1) uint8; % sma pin we use (1 ... 3) corresponds to (0 ... 2) here
		isCorrectDevice(1, 1) logical;
		positionCounter(1, 1) uint16;
		position(1, 1) double; % [mm]
		isConnected(1, 1) logical = 0;
	end

	properties(Hidden, Constant)
		encoderResolution(1, 1) double = 2; % steps per microm
		BAUD_RATE(1, 1) double = 115200;
		TERMINATOR(1, :) char = 'CR';

		IDENTIFY(1, 1) uint8 = 00;
		IDENTIFIER(1, 1) uint16 = 76; % unique device for AZbsoluteQuad teensy

		SET_FREQ(1, 1) uint8 = 11;
		SET_SPACE(1, 1) uint8 = 12;
		SET_NFREQ(1, 1) uint8 = 13;
		SET_NSPACE(1, 1) uint8 = 14;
		SET_PIN(1, 1) uint8 = 15;

		GET_FREQ(1, 1) uint8 = 21; % returns frequency of temporal trigger
		GET_SPACE(1, 1) uint8 = 22; % retruns frequency of spatial domain trigger
		GET_NFREQ(1, 1) uint8 = 23;
		GET_NSPACE(1, 1) uint8 = 24; 
		GET_PIN(1, 1) uint8 = 25;

		START_FREQ(1, 1) uint8 = 31;
		START_SPACE(1, 1) uint8 = 32;

		STOP_FREQ(1, 1) uint8 = 41;
		STOP_SPACE(1, 1) uint8 = 42;

		OK(1, 1) uint8 = 91;
		WARNING(1, 1) uint8 = 92;
		ERROR(1, 1) uint8 = 93;
		UNKNOWN_COMMAND(1, 1) uint8 = 94

	end

	methods
		% Constructor
		function tc = PositionBasedTriggerCommunicator(varargin)
			if (nargin == 1)
				tc.port = varargin{1};
			elseif (nargin == 0)
				% check if file exists and if so load port from there
				tc.port = get_com_port('Trigger'); % read com port
			else
				error("Invalid number of input arguments");
			end

			tc.Connect();
		end

		% destructor
		function delete(tc)
			tc.Disconnect();
		end

		Identify(tc);
		returnVal = Handshake(tc);		
		Disconnect(tc); % closes serial port connection to device
		Connect(tc); % opens serial port conenction and checks status

		% not implemmeneted yet
		Clear_Serial_Input(tc); 
		Initialize(tc, reps); % sends configuration over to Teensy
		StartFreq(tc); % starts frequency domain trigger 
		StopFreq(tc);
		Find_Com_Port(tc);
		Reset_Counter(tc); % resets the counter of the quadrature decoder board
		Update_Position(tc); % updates the position
		VPrintf(tc, txtMsg, flagName);

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

		% set and get function for temporal triggering
		function set.triggerFreq(tc, triggerFreq)
			% tell device that we set trigger frequency
			write(tc.S, tc.SET_FREQ, "uint8");
			write(tc.S, single(triggerFreq), "single");
			returnVal = read(tc.S, 1, "single");
			if (returnVal ~= triggerFreq)
				error("Invalid frequency returned from device");
			end
			tc.Handshake();
		end

		function triggerFreq = get.triggerFreq(tc)
			write(tc.S, tc.GET_FREQ, "uint8");
			triggerFreq = read(tc.S, 1, "single");
			tc.Handshake();
		end

		% set and get function of triggerSteps (spatial frequency)
		function set.triggerSteps(tc, triggerSteps)
			% tell device that we set trigger frequency
			write(tc.S, tc.SET_SPACE, "uint8");
			write(tc.S, uint32(triggerSteps), "uint32");
			returnVal = read(tc.S, 1, "uint32");
			if (returnVal ~= triggerSteps)
				error("Invalid stepsize returned from device");
			end
			tc.Handshake();
		end

		function triggerSteps = get.triggerSteps(tc)
			write(tc.S, tc.GET_SPACE, "uint8");
			triggerSteps = read(tc.S, 1, "uint32");
			tc.Handshake();
		end

		% set and get function for the trigger pin
		function trigPin = get.trigPin(tc)
			write(tc.S, tc.GET_PIN, "uint8");
			trigPin = read(tc.S, 1, "uint8");
			tc.Handshake();
		end

		function set.trigPin(tc, trigPin)
			write(tc.S, tc.SET_PIN, "uint8");
			write(tc.S, uint8(trigPin), "uint8");
			returnVal = read(tc.S, 1, "uint8");
			if (trigPin ~= returnVal)
				returnVal = read(tc.S, 1, "uint8"); % clean up handshake byte
				error("Something went wrong while setting the trigger pin");
			end
			tc.Handshake();
		end

		% number of triggers during frequency based trigger
		function set.nShots(tc, nShots)
			write(tc.S, tc.SET_NFREQ, "uint8");
			write(tc.S, uint32(nShots), "uint32");
			returnVal = read(tc.S, 1, "uint32");
			if (returnVal ~= nShots)
				msgErr = sprintf("Invalid value returned, %d instead of %d", ...
					returnVal, nShots)
				error(msgErr);
			end
			tc.Handshake();
		end

		function nShots = get.nShots(tc)
			write(tc.S, tc.GET_NFREQ, "uint8");
			nShots = read(tc.S, 1, "uint32");
			tc.Handshake();
		end

		% number of steps during position based trigger
		function set.nSteps(tc, nSteps)
			write(tc.S, tc.SET_NSPACE, "uint8");
			write(tc.S, uint32(nSteps), "uint32");
			returnVal = read(tc.S, 1, "uint32");
			if (returnVal ~= nSteps)
				error("Returned value seems to be wrong");
			end
			tc.Handshake();
		end

		function nSteps = get.nSteps(tc)
			write(tc.S, ts.GET_NSPACE, "uint8");
			nSteps = read(tc.S, 1, "uint32");
			tc.Handshake();
		end


	end

end