% Johannes Rebling, (johannesrebling@gmail.com), 2019
% if we close the connection to the AQ during position based
% or scope mode, we need to return to default state in AQ

function [resetWorked] = Soft_Reset(AQ)
  isConnected = AQ.Check_Connection();

  if ~isConnected && ~isempty(AQ.serialPtr)
    AQ.VPrintF('Attempting to gain AQ control back...\n');
    AQ.Disable_Pos_Based_Trigger(0.25);
    AQ.Disable_Scope(0.25);
    resetWorked = AQ.Check_Connection();
  end

end
