% File: Write_Command.m @ AbsoluteQuad
% Author: Urs Hofmann
% Mail: hofmannu@ethz.ch

function Write_Command(aq, command)
	% make sure that command is of the coirrect type
	if ~isa(command,'uint16')
    	error('Commands must be uint16!');
  	end
  	write(aq.serialPtr, command, 'uint16');
  	% PB.Write_Data(command);

	% writeline(aq.serialPtr, command);
end