function [confirmed] = Confirm_Command(aq, command)
	% also here we want to make sure that the argument we compare against is 
	% of the correct type

	if ~isa(command, 'uint16')
    	error('Commands must be uint16!');
  	end

  	aq.Wait_For_Bytes(2);
	response = read(aq.serialPtr, 1, 'uint16');

	% check if we received a response in the first place
	if isempty(response)
		error("Did not receive any response from teensy");
	end

	if ~(response == command)
		confirmed = 0;
		response
		error("Could not confirm the command boy");
	else
		confirmed = 1;
	end
end