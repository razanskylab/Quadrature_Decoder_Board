% non functional example class to be used as basis for new hardware interfacing
% class, as they alls should have similar structure and content

classdef AbsoluteQuad < handle

  properties
    classId = '[AbsoluteQuad]';
    serialPort(1, :) char = 'COM11';
    baudRate(1, 1) = 9600;
    samplingFreq(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite} = 100;
    trigRange(1, 2) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [mm]
    trigStepSize(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [um]
    nTotalBScans(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [um]
    verboseOutput(1, 1) logical = 1;
    serialPtr;
    timeOut(1, 1) single = 1; % timeout for serial communication
  end

  % depended properties are calculated from other properties
  properties (Dependent = true)
    pos(1, 1) {mustBeNumeric}; % [mm] current stage position, read from quad encoder and coverted to mm
    posCount(1, 1) {mustBeNumeric}; % [counts] current stage position, read from quad encoder
    nTriggers(1, 1) {mustBeNumeric};
    % expected number of triggers, based on trigger range and step size
    trigRangeCounts(1, 2) {mustBeInteger, mustBeNonnegative, mustBeFinite}; % [pos counter pos.]
    trigStepSizeCounts(1, 1) {mustBeInteger, mustBeNonnegative, mustBeFinite}; % [pos counter steps]
    samplingPeriod(1, 1) uint16 {mustBeInteger, mustBeNonnegative};
    % [us or ms] -> see Enable_Scope_Mode for details on ms vs us
    slowSampling(1, 1); % sets samplingPeriod in us or ms
    isConnected(1, 1) = 0;
  end

  % things we don't want to accidently change but that still might be interesting
  properties (SetAccess = private, Transient = true)
    lastTrigCount(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite};
  end

  % things we don't want to accidently change but that still might be interesting
  properties (Constant)
    DO_AUTO_CONNECT = true; % connect when object is initialized?
    MCU_ID = 'aq_decoder';
    MCU_BOOT_TIME = 1; % [s]
    SERIAL_TIMEOUT = 1; % we should only get timeouts when something is wrong

    STEP_SIZE = 200e-6; % [mm] one microstep = 0.2 micron
    MICRON_STEP = 5; % 5 counter steps are one micron
    MAX_BYTE_PER_READ = 4096; % we can read this many bytes over serial at once
    CALIB_ARRAY_SIZE = AbsoluteQuad.MAX_BYTE_PER_READ ./ 2; % number of data points in the calibration array

    %% Comands defined in teensy_lib.h
    DO_NOTHING(1, 1) uint16 = 00;
    SEND_CURRENT_POS(1, 1) uint16 = 12;
    RESET_HCTL_COUNTER(1, 1) uint16 = 33;
    ENABLE_POS_TRIGGER(1, 1) uint16 = 55;
    START_FREE_RUNNING_TRIGGER(1, 1) uint16 = 66;
    RESTART_MCU(1, 1) uint16 = 91;
    STOP(1, 1) uint16 = 93;
    CLOSE_CONNECTION(1, 1) uint16 = 94;
    CHECK_ID(1, 1) uint16 = 95;
    CHECK_CONNECTION(1, 1) uint16 = 96;
    ERROR(1, 1) uint16 = 97;
    READY(1, 1) uint16 = 98;
    DONE(1, 1) uint16 = 99;
  end

  % constructor, desctructor, save obj
  methods
    % constructor, called when class is created
    function Obj = AbsoluteQuad(varargin)

      % no argument passed --> follow default behaviour
      if nargin < 1
        doConnect = Obj.DO_AUTO_CONNECT;
      end
      
      % if a char is passed this means that we got a serial port
      if (nargin == 1) && (ischar(varargin{1}))
        Obj.serialPort = varargin{1};
        doConnect = 1;
      elseif (nargin == 1) && (any(varargin{1} == [0, 1]))
        doConnect = varargin{1};
      else
        error("Invalid argument passed to function");
      end

      if doConnect && ~Obj.isConnected
        Obj.Connect();
      elseif ~Obj.isConnected
        Obj.VPrintF_With_ID('Initialized but not connected yet.\n');
      end
    end

    function delete(Obj)
      if ~isempty(Obj.serialPtr)
        Obj.serialPtr = [];
      end
    end

    % when saved, hand over only properties stored in saveObj
    function SaveObj = saveobj(Obj)
      SaveObj = Obj; % see class def for info
    end

  end

  methods % short methods, which are not worth putting in a file

    function [steps] = MM_To_Steps(Obj, mm)

      if mod(mm, Obj.STEP_SIZE)
        short_warn('MM_To_Steps(): Non integer conversion!');
      end

      steps = round(mm ./ Obj.STEP_SIZE); % max rounding error is 200 nm...
    end

    function [mm] = Steps_To_MM(Obj, steps)
      mm = steps .* Obj.STEP_SIZE;
    end

  end

  methods % set / get methods

    function isConnected = get.isConnected(Obj)
      isConnected = ~isempty(Obj.serialPtr);
    end

    function [pos] = get.pos(Obj)
      pos = Obj.Steps_To_MM(Obj.posCount);
    end

    function [posCount] = get.posCount(Obj)

      if Obj.isConnected
        Obj.Write_Command(Obj.SEND_CURRENT_POS); % pushs task over to teensy
        Obj.Confirm_Command(Obj.SEND_CURRENT_POS); % confirms the received command
        Obj.Wait_For_Bytes(2); % wait for uint16 which is 2 bytes
        posCount = double(read(Obj.serialPtr, 1, 'uint16')); 
        Obj.Confirm_Command(Obj.DONE);
      else
        posCount = [];
      end

    end

    function [slowSampling] = get.slowSampling(Obj)

      if Obj.samplingFreq > 20
        % samplingPeriod in us
        slowSampling = false;
      else
        % samplingPeriod in ms
        slowSampling = true;
      end

    end

    function [samplingPeriod] = get.samplingPeriod(Obj)

      if Obj.slowSampling
        % samplingPeriod in ms
        samplingPeriod = uint16(1 ./ Obj.samplingFreq * 1e3);
      else
        % samplingPeriod in us
        samplingPeriod = uint16(1 ./ Obj.samplingFreq * 1e6);
      end

    end


    function [nTriggers] = get.nTriggers(Obj)
      distance = Obj.trigRangeCounts(2) - Obj.trigRangeCounts(1);
      nTriggers = distance ./ Obj.trigStepSizeCounts;
      nTriggers = nTriggers + 1;
    end

    function [trigRangeCounts] = get.trigRangeCounts(Obj)
      lowTrigRangeCnt = Obj.MM_To_Steps(Obj.trigRange(1));
      highTrigRangeCnt = Obj.MM_To_Steps(Obj.trigRange(2));
      trigRangeCounts(1) = lowTrigRangeCnt;
      trigRangeCounts(2) = highTrigRangeCnt;
    end

    function [trigStepSizeCounts] = get.trigStepSizeCounts(Obj)
      trigStepSizeCounts = Obj.MM_To_Steps(Obj.trigStepSize * 1e-3);
    end

  end % <<<<<<<< END SET?GET METHODS

end % <<<<<<<< END BASE CLASS
