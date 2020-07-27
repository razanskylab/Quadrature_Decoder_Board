% function [] = Update_Code(AQ)
% does something coole...
% Johannes Rebling, (johannesrebling@gmail.com), 2019

function [] = Update_Code(AQ)
  % requires Platformio to be installed and to be added to the system path!
  AQ.Hor_Div();
  AQ.VPrintF('[AQ] Updating teensy code using Platformio\n');
  AQ.Close();
  updateScript = 'C:\Code\Quadrature_Decoder_Board\TeensyPosCounter\update_code.cmd';
  [status,cmdout] = system(updateScript,'-echo');
  pause(1); % wait a second for teensy to start back up...
  AQ.Connect();
  AQ.Hor_Div();
end
