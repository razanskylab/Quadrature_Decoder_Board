function [success] = Check_Connection(Obj)
  success = false;

  Obj.Flush_Serial(); % make sure to get rid of old bytes...

  Obj.VPrintF_With_ID('Checking connection');
  Obj.Write_Command(Obj.CHECK_CONNECTION);
  
  Obj.Wait_For_Bytes(2,1); % give MCU time to answer with 2 bytes, timeout = 1s
  Obj.PrintF('...');
  answer = Obj.Read_Command(); % read two byte answers (uint16)
  if answer ~= Obj.READY
    short_warn(' unexpected return value!');
    error('Something went wrong in the teensy!');
  else
    Obj.PrintF('we are ready to go!\n');
  end
  
  % also make sure we are connected to the right MCU 
  % as other MCUs might use same communication protocol

  Obj.VPrintF_With_ID('Checking MCU ID...');
  Obj.Write_Command(Obj.CHECK_ID);
  
  nRequiredBytes = strlength(Obj.MCU_ID); % this is how many bytes we expect
  Obj.Wait_For_Bytes(nRequiredBytes); % give MCU time to answer
  answer = Obj.Read_Data(nRequiredBytes,"string");

  if strcmp(answer,Obj.MCU_ID)
    Obj.PrintF('correct MCU!\n');
    success = true;
  else
    short_warn(' Wrong MCU connected!');
  end

end
