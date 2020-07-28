
if ~exist('AQ') %#ok<*EXIST>
  AQ = AbsoluteQuad(false);
  AQ.SERIAL_PORT = 'COM4'; % change from default com port
  AQ.Connect(); % now connect via serial
end
