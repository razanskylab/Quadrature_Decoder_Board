% function [] = Enable_Pos_Based_Trigger(AQ)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Pos_Based_Trigger(AQ)
% starts recording of the calibration data in the teensy

  % convert mm and um to stage steps
  lowTrigRangeCnt = uint16(AQ.MM_To_Steps(AQ.trigRange(1)));
  highTrigRangeCnt = uint16(AQ.MM_To_Steps(AQ.trigRange(2)));
  stepCnt = uint16(AQ.MM_To_Steps(AQ.trigStepSize*1e-3));

  AQ.PrintF('[AQ] Enabling position based trigger\n');
  AQ.VPrintF('   range: %2.1f<->%2.1f mm\n',AQ.trigRange);
  AQ.VPrintF('   step size: %1.0f um (steps %i)\n',AQ.trigStepSize,stepCnt);


  AQ.Write_Command(AQ.ENABLE_POS_TRIGGER);
  AQ.Write_16Bit(lowTrigRangeCnt);
  AQ.Write_16Bit(highTrigRangeCnt);
  AQ.Write_16Bit(stepCnt);
end