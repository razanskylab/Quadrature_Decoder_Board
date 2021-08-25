% function [] = Collect_Calib_Data(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [pos,rawPos] = Collect_Calib_Data(AQ)
  tic;
  AQ.VPrintF_With_ID('Collecting callibration data\n');

  % fancy wait bar, all it does it waiting
  recTime = AQ.CALIB_ARRAY_SIZE./AQ.samplingFreq;
  recTime = recTime*0.90; % make a bit shorter
  extraTime = recTime*(1-0.90);
  nWaitSteps = 25;
  waitTime = recTime./nWaitSteps;
  cpb = prep_console_progress_bar(nWaitSteps);
  cpb.start();
  for iWait = 1:nWaitSteps
    % text = sprintf('Recording calib data...');
    % text = sprintf('Recording calib data... %d/%d', iWait, nWaitSteps);
    % cpb.setText(text);
    cpb.setValue(iWait);
    pause(waitTime);
  end
  cpb.stop(); 
  fprintf('\n');

  % make sure data has been recorded
  AQ.Wait_Done(extraTime+2);

  % recording on the counter board is done and stored in memory there, lets grab it
  AQ.Write_Command(AQ.SEND_CALIB_DATA);
  AQ.Write_16Bit(uint16(AQ.MAX_BYTE_PER_READ));
  while (AQ.bytesAvailable < AQ.MAX_BYTE_PER_READ)
  end
  [~,posCount] = AQ.Read_Data_Large(AQ.MAX_BYTE_PER_READ);
  AQ.Wait_Done(); % last thing teensy sends is an OK, we are done
  % after this, there should be no more bytes available
  if AQ.bytesAvailable
    error('should not have bytes here!');
  end

  rawPos = posCount;
  pos = AQ.Steps_To_MM(double(posCount));

end
