% non functional example class to be used as basis for new hardware interfacing
% class, as they alls should have similar structure and content

classdef AbsoluteQuad < McuSerialInterface

  properties
    classId = '[Decoder]';
    serialPort char = COM_Ports.AQ;
%     TEENSY_ID = COM_Ports.AQId;
    baudRate = 9600;

    samplingFreq(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite} = 100;
    trigRange(1, 2) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [mm]
    trigStepSize(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [um]
    nTotalBScans(1, 1) {mustBeNumeric, mustBeNonnegative, mustBeFinite}; % [um]
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
    SEND_CURRENT_POS = uint16(12);
    RESET_HCTL_COUNTER = uint16(33);
    ENABLE_POS_TRIGGER = uint16(55);
    START_FREE_RUNNING_TRIGGER = uint16(66);
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % constructor, desctructor, save obj
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % constructor, called when class is created
    function Obj = AbsoluteQuad(varargin)
      if nargin < 1
        doConnect = Obj.DO_AUTO_CONNECT;
      end
      
      if nargin == 1 && ischar(varargin{1})
        Obj.serialPort = varargin{1};
        doConnect = true;
      elseif nargin == 1 && islogical(varargin{1})
        doConnect = varargin{1};
      end

      if doConnect && ~Obj.isConnected
        Obj.Connect();
      elseif ~Obj.isConnected
        Obj.VPrintF('[Blaster] Initialized but not connected yet.\n');
      end
    end

    %*************************************************************************%
    function delete(Obj)
      if ~isempty(Obj.SerialPortObj)
        Obj.Close();
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % when saved, hand over only properties stored in saveObj
    function SaveObj = saveobj(Obj)
      SaveObj = Obj; % see class def for info
    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % short methods, which are not worth putting in a file

    %*************************************************************************%
    function Reset_HCTL_Counter(Obj)
      if Obj.isConnected
        Obj.Flush_Serial();
        Obj.VPrintF_With_ID('Resetting HCTL counter...');
        Obj.Write_Command(Obj.RESET_HCTL_COUNTER);
        Obj.Confirm_Command(Obj.RESET_HCTL_COUNTER);
        Obj.Confirm_Command(Obj.DONE);
        Obj.Done();
      else
        short_warn('No serial connection established!\n');e
      end
    end

    %*************************************************************************%
    function [steps] = MM_To_Steps(Obj, mm)

      if mod(mm, Obj.STEP_SIZE)
        short_warn('MM_To_Steps(): Non integer conversion!');
      end

      steps = round(mm ./ Obj.STEP_SIZE); % max rounding error is 200 nm...
    end

    %*************************************************************************%
    function [mm] = Steps_To_MM(Obj, steps)
      mm = steps .* Obj.STEP_SIZE;
    end


  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % set / get methods
    %*************************************************************************%
    function [pos] = get.pos(Obj)
      pos = Obj.Steps_To_MM(Obj.posCount);
    end

    %*************************************************************************%
    function [posCount] = get.posCount(Obj)

      if Obj.isConnected
        Obj.Write_Command(Obj.SEND_CURRENT_POS);
        Obj.Confirm_Command(Obj.SEND_CURRENT_POS);
        Obj.Wait_For_Bytes(2); % wait for uint16
        posCount = double(Obj.Read_Data(1,'uint16'));
        Obj.Confirm_Command(Obj.DONE);
      else
        posCount = [];
      end

    end

    %*************************************************************************%
    function [slowSampling] = get.slowSampling(Obj)

      if Obj.samplingFreq > 20
        % samplingPeriod in us
        slowSampling = false;
      else
        % samplingPeriod in ms
        slowSampling = true;
      end

    end

    %*************************************************************************%
    function [samplingPeriod] = get.samplingPeriod(Obj)

      if Obj.slowSampling
        % samplingPeriod in ms
        samplingPeriod = uint16(1 ./ Obj.samplingFreq * 1e3);
      else
        % samplingPeriod in us
        samplingPeriod = uint16(1 ./ Obj.samplingFreq * 1e6);
      end

    end


    %*************************************************************************%
    function [nTriggers] = get.nTriggers(Obj)
      distance = Obj.trigRangeCounts(2) - Obj.trigRangeCounts(1);
      nTriggers = distance ./ Obj.trigStepSizeCounts;
      nTriggers = nTriggers + 1;
    end

    %*************************************************************************%
    function [trigRangeCounts] = get.trigRangeCounts(Obj)
      lowTrigRangeCnt = Obj.MM_To_Steps(Obj.trigRange(1));
      highTrigRangeCnt = Obj.MM_To_Steps(Obj.trigRange(2));
      trigRangeCounts(1) = lowTrigRangeCnt;
      trigRangeCounts(2) = highTrigRangeCnt;
    end

    %*************************************************************************%
    function [trigStepSizeCounts] = get.trigStepSizeCounts(Obj)
      trigStepSizeCounts = Obj.MM_To_Steps(Obj.trigStepSize * 1e-3);
    end

  end % <<<<<<<< END SET?GET METHODS

end % <<<<<<<< END BASE CLASS
