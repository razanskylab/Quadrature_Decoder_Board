% function [] = Record_Calib_Data(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Record_Calib_Data(AQ)
% starts recording of the calibration data in the teensy
  t1 = tic();
  recTime = AQ.CALIB_ARRAY_SIZE./AQ.samplingFreq;
  AQ.PrintF('Recording calibration data\n');
  AQ.VPrintF('   num data points: %i\n',AQ.CALIB_ARRAY_SIZE);
  AQ.VPrintF('   sampling freq:   %1.0f Hz\n',AQ.samplingFreq);
  AQ.VPrintF('   recording time:  %1.2f s\n',recTime);
  AQ.Write_Command(AQ.RECORD_CALIB_DATA);
  AQ.Write_16Bit(AQ.samplingPeriod);
  AQ.VPrintF('   Starting recording...');  

end
