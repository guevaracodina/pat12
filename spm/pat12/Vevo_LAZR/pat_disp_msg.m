function IOI = pat_disp_msg(IOI,msg)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
disp(msg);
try
    IOI.warning = [IOI.warning; msg];
catch
    IOI.warning = [IOI.warning msg];
end

% EOF
