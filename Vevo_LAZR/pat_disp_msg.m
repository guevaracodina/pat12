function PAT = pat_disp_msg(PAT,msg)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Mol�culaire
%                    �cole Polytechnique de Montr�al
%_______________________________________________________________________________
disp(msg);
try
    PAT(1).warning = [PAT(1).warning; msg];
catch
    PAT(1).warning = [PAT(1).warning msg];
end

% EOF
