% function [] = Enable_Pos_Based_Trigger(Obj)
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Enable_Pos_Based_Trigger(Obj)
% starts recording of the calibration data in the teensy

  % convert mm and um to stage steps
  lowTrigRangeCnt = uint16(Obj.trigRangeCounts(1));
  highTrigRangeCnt = uint16(Obj.trigRangeCounts(2));
  stepCnt = uint16(Obj.trigStepSizeCounts);
  nBScan = uint16(Obj.nTotalBScans);

  Obj.VPrintF_With_ID('Enabling position based trigger:\n');
  Obj.VPrintF('   range: %2.1f<->%2.1f mm (%i<->%i)\n',...
    Obj.trigRange,lowTrigRangeCnt,highTrigRangeCnt);
  Obj.VPrintF('   step size: %1.0f um (steps %i)\n',Obj.trigStepSize,stepCnt);
  Obj.VPrintF('   total B-scans: %i \n',nBScan);

  Obj.Write_Command(Obj.ENABLE_POS_TRIGGER);
  % check MCU is actually ready to go, then send over data 
  if Obj.Confirm_Command(Obj.ENABLE_POS_TRIGGER)
    Obj.Write_Data(lowTrigRangeCnt);
    Obj.Write_Data(highTrigRangeCnt);
    Obj.Write_Data(stepCnt);
    Obj.Write_Data(nBScan);
    Obj.Confirm_Command(lowTrigRangeCnt);
    Obj.Confirm_Command(highTrigRangeCnt);
    Obj.Confirm_Command(stepCnt);
    Obj.Confirm_Command(nBScan);
  else
    error('Error during Enable_Pos_Based_Trigger...');
  end

end
