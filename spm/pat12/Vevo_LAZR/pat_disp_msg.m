function IOI = pat_disp_msg(IOI,msg)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Mol�culaire
%                    �cole Polytechnique de Montr�al
%_______________________________________________________________________________
disp(msg);
try
    IOI.warning = [IOI.warning; msg];
catch
    IOI.warning = [IOI.warning msg];
end

% EOF
