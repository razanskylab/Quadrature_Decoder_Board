function VPrintF_With_ID(AQ,varargin)
	baseStr = sprintf(varargin{:});
	AQ.VPrintF([AQ.classId ' ' baseStr]);
end