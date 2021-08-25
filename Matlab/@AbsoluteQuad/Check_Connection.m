function [success] = Check_Connection(Obj)
  flush(Obj.serialPtr); % make sure to get rid of old bytes...
  Obj.VPrintF_With_ID('Checking connection...');
  Obj.Write_Command(Obj.CHECK_CONNECTION);
  timeOut = 1; % 1 seconds default timeout

  % t1 = tic;
  % % wait for ready command...
  % while (Obj.bytesAvailable<2)
  %   if toc(t1) > timeOut
  %     Obj.Verbose_Warn('Teensy response timeout!\n');
  %     return;
  %   end
  % end
  % Obj.PrintF('got answer...');
  Obj.Wait_For_Bytes(2);

  [~, answer] = Obj.Read_Data(2);
  if answer ~= Obj.READY;
    error('  Something went wrong in the teensy!');
  else
    success = true;
    Obj.VPrintF('we are ready to go!\n');
  end

end
