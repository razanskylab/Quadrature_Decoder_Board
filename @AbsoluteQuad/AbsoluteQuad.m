% non functional example class to be used as basis for new hardware interfacing
% class, as they alls should have similar structure and content

classdef AbsoluteQuad < BaseHardwareClass
  properties
    samplingPeriod(1,1) uint16 {mustBeInteger,mustBeNonnegative} = 1000; % [us]
    trigRange(1,2) {mustBeNumeric,mustBeNonnegative,mustBeFinite}; % [mm]
    trigStepSize(1,1) {mustBeNumeric,mustBeNonnegative,mustBeFinite}; % [um]
  end

  % depended properties are calculated from other properties
  properties (Dependent = true)
    pos(1,1) {mustBeNumeric}; % [mm] current stage position, read from quad encoder and coverted to mm
    posCount(1,1) {mustBeNumeric}; % [counts] current stage position, read from quad encoder
    bytesAvailable(1,1) {mustBeNumeric}; % [counts] current stage position, read from quad encoder
    nTriggers(1,1) {mustBeNumeric};
      % expected number of triggers, based on trigger range and step size
    trigRangeCounts(1,2) {mustBeInteger,mustBeNonnegative,mustBeFinite}; % [pos counter pos.]
    trigStepSizeCounts(1,1) {mustBeInteger,mustBeNonnegative,mustBeFinite}; % [pos counter steps]
  end

  % things we don't want to accidently change but that still might be interesting
  properties (SetAccess = private, Transient = true)
    serialPtr = []; % pointer to serial port (we are using MEX Serial instead)
    isConnected = false;
    samplingFreq; % sampling frequency in HZ
    lastTrigCount(1,1) {mustBeNumeric,mustBeNonnegative,mustBeFinite};
  end

  % things we don't want to accidently change but that still might be interesting
  properties (Constant)
    % serial properties
    SERIAL_PORT = 'COM11';
    BAUD_RATE = 9600;

    STEP_SIZE = 0.2*1e-3; % [mm] one microstep = 0.2 micron
    MICRON_STEP = 5; % 5 counter steps are one micron
    DO_AUTO_CONNECT = true; % connect when object is initialized?
    MAX_BYTE_PER_READ = 4096; % we can read this many bytes over serial at once
    CALIB_ARRAY_SIZE = AbsoluteQuad.MAX_BYTE_PER_READ./2; % number of data points in the calibration array

    %% Comands defined in teensy_lib.h
    DO_NOTHING = uint16(0);
    RECORD_CALIB_DATA = uint16(11);
    SEND_CURRENT_POS = uint16(12);
    SEND_CALIB_DATA = uint16(22);
    RESET_HCTL_COUNTER = uint16(33);
    RESET_TEENSY = uint16(44);
    ENABLE_POS_TRIGGER = uint16(55);
    DISABLE_POS_TRIGGER = uint16(56);
    SCOPE_MODE = uint16(66); % TODO needs to be implemented!
    CHECK_CONNECTION = uint16(98);
    DONE = uint16(99);
  end

  % same as constant but now showing up as property
  properties (Hidden=true)
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % constructor, desctructor, save obj
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % constructor, called when class is created
    function AQ = AbsoluteQuad(doConnect)
      if nargin < 1
        doConnect = AQ.DO_AUTO_CONNECT;
      end

      if doConnect && ~AQ.isConnected
        AQ.Connect;
      elseif ~AQ.isConnected
        AQ.VPrintF('[AQ] Initialized but not connected yet.\n');
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function delete(AQ)
      if ~isempty(AQ.serialPtr) && AQ.isConnected
        AQ.Close();
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % when saved, hand over only properties stored in saveObj
    function SaveObj = saveobj(AQ)
      SaveObj = AQ; % see class def for info
    end
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % short methods, which are not worth putting in a file

    function [] = Write_Command(AQ,command)
      if ~isa(command,'uint16')
        error('Counter commands must be uint16!');
      end
      command = typecast(command, 'uint8'); % commands send as 2 byte
      AQ.Write_Data(command);
    end

    function [] = Rest_HCTL_Counter(AQ)
      AQ.VPrintF('[AQ] Resetting HCTL counter...');
      AQ.Write_Command(AQ.RESET_HCTL_COUNTER);
      AQ.Wait_Done();
      AQ.Done();
    end

    function [] = Reset_Teensy(AQ)
      AQ.VPrintF('[AQ] Resetting Teensy...');
      AQ.Write_Command(AQ.RESET_TEENSY);
      pause(5); % give teensy time to restart...
      % AQ.Wait_Done(); % NOTE don't wait here, teensy is restarting...
    end

    function [success] = Check_Connection(AQ)
      AQ.PrintF('[AQ] Checking teensy connection');
      AQ.Write_Command(AQ.CHECK_CONNECTION);
      success = AQ.Wait_Done();
      if success
        AQ.VPrintF('...looking good!\n');
      else
        AQ.VPrintF('...teensy requires reset!\n');
      end
    end

    function [] = Write_16Bit(AQ,data)
      AQ.Write_Command(data); % same as command, but lets not confuse our users...
    end

    function [steps] = MM_To_Steps(AQ,mm)
      steps = round(mm./AQ.STEP_SIZE); % max rounding error is 200 nm...
    end

    function [mm] = Steps_To_MM(AQ,steps)
      mm = steps.*AQ.STEP_SIZE;
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = private)
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % set / get methods
    % --------------------------------------------------------------------------
    function [pos] = get.pos(AQ)
      pos = AQ.Steps_To_MM(AQ.posCount);A
    end

    function [posCount] = get.posCount(AQ)
      if AQ.isConnected
        AQ.Write_Command(AQ.SEND_CURRENT_POS);
        [~,posCount] = AQ.Wait_Data();
        posCount = double(posCount);
      else
        posCount = [];
      end
      % posCount = AQ.Dev.get('posCount');
      % posCount = AQ.Steps_To_MM(posCount); % convert to steps
    end

    function [samplingFreq] = get.samplingFreq(AQ)
      samplingFreq = 1./(double(AQ.samplingPeriod)*1e-6); % sampling frequency in HZ
    end

    function [bytesAvailable] = get.bytesAvailable(AQ)
      if AQ.isConnected
        numBytesToRead = 0;
        [~ , bytesAvailable] = readPort(AQ.serialPtr, numBytesToRead);
      else
        bytesAvailable = [];
      end
    end

    function [nTriggers] = get.nTriggers(AQ)
      distance = AQ.trigRange(2) - AQ.trigRange(1);
      minTrigger = ceil(distance./(AQ.trigStepSize*1e-3));
      nTriggers = minTrigger + 1;
    end

    function [trigRangeCounts] = get.trigRangeCounts(AQ)
      lowTrigRangeCnt = AQ.MM_To_Steps(AQ.trigRange(1));
      highTrigRangeCnt = AQ.MM_To_Steps(AQ.trigRange(2));
      trigRangeCounts(1) = lowTrigRangeCnt;
      trigRangeCounts(2) = highTrigRangeCnt;
    end

    function [trigStepSizeCounts] = get.trigStepSizeCounts(AQ)
      trigStepSizeCounts = AQ.MM_To_Steps(AQ.trigStepSize*1e-3);
    end

  end % <<<<<<<< END SET?GET METHODS

end % <<<<<<<< END BASE CLASS
