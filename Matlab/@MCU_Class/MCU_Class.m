% non functional example class to be used as basis for new hardware interfacing
% class, as they alls should have similar structure and content

classdef MCU_Class < BaseHardwareClass

  % must be implemented by the children class
  properties (Abstract = true)
    serialPort char;
    baudRate (1,1) {mustBeNumeric};
  end

  % depended properties are calculated from other properties
  properties (Dependent = true)
    bytesAvailable(1,1) {mustBeNumeric};
    isConnected(1,1) {mustBeNumericOrLogical};
  end

  % things we don't want to accidently change but that still might be interesting
  properties (SetAccess = private, Transient = true)
    SerialPortObj; % serial port object
  end

  % things we don't want to accidently change but that still might be interesting
  properties (Constant, Abstract = true)
    DO_AUTO_CONNECT; % connect when object is initialized?
    MCU_ID;
    MCU_BOOT_TIME;
    SERIAL_TIMEOUT;
  end

  properties (Constant)
    DO_NOTHING = uint16(00);
    STOP = uint16(93);
    CHECK_ID = uint16(95);
    CHECK_CONNECTION = uint16(96);
    ERROR = uint16(97);
    READY = uint16(98);
    DONE = uint16(99);

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % constructor, desctructor, save obj
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods
    % constructor, called when class is created
    function Obj = MCU_Class(varargin)
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
        Obj.VPrintF_With_ID('Initialized but not connected yet.\n');
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
    % flush serial io (input and output) buffers
    function [] = Flush_Serial(Obj)
      tic;
      nBytes = Obj.bytesAvailable;
      if nBytes
        Obj.VPrintF_With_ID('Flushing %i serial port bytes...',nBytes);
        flush(Obj.SerialPortObj);
        Obj.Done();
      end
    end

    %*************************************************************************%
    function [] = Write_16Bit(Obj, data)
      Obj.Write_Command(data); % same as command, but lets not confuse our users...
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods % set / get methods
    %*************************************************************************%
    function [bytesAvailable] = get.bytesAvailable(Obj)
      if Obj.isConnected
        bytesAvailable = Obj.SerialPortObj.NumBytesAvailable;
      else
        bytesAvailable = [];
      end
    end

    %*************************************************************************%
    function [isConnected] = get.isConnected(Obj)
      isConnected = ~isempty(Obj.SerialPortObj);
    end

  end % <<<<<<<< END SET?GET METHODS

end % <<<<<<<< END BASE CLASS
