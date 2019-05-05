% function [] = Enable_Pos_Based_Trigger(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Pos_Based_Trigger(AQ)
% starts recording of the calibration data in the teensy

  % convert mm and um to stage steps
  lowTrigRangeCnt = uint16(AQ.trigRangeCounts(1));
  highTrigRangeCnt = uint16(AQ.trigRangeCounts(2));
  stepCnt = uint16(AQ.trigStepSizeCounts);
  nBScan = uint16(AQ.nTotalBScans);

  AQ.PrintF('[AQ] Enabling position based trigger\n');
  AQ.VPrintF('   range: %2.1f<->%2.1f mm (%i<->%i)\n',...
    AQ.trigRange,lowTrigRangeCnt,highTrigRangeCnt);
  AQ.VPrintF('   step size: %1.0f um (steps %i)\n',AQ.trigStepSize,stepCnt);
  AQ.VPrintF('   total B-scans: %i \n',nBScan);

  AQ.Write_Command(AQ.ENABLE_POS_TRIGGER);
  AQ.Write_16Bit(lowTrigRangeCnt);
  AQ.Write_16Bit(highTrigRangeCnt);
  AQ.Write_16Bit(stepCnt);
  AQ.Write_16Bit(nBScan);
end
