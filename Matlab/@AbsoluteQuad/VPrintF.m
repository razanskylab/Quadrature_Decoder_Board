function VPrintF(AQ,varargin)
	if AQ.verboseOutput
    	fprintf(varargin{:});
    	drawnow;
  	end
end