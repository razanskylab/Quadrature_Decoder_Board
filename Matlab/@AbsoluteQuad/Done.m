function Done(Obj,ticMarker)
  if nargin == 2
    Obj.VPrintF('done (%3.2f s).\n',toc(ticMarker));
  else
    Obj.VPrintF('done (%3.2f s).\n',toc());
  end

end
