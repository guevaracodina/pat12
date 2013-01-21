function PATmat = pat_PATmat_cfg(minPAT)
% Configuration file GUI to select PAT matrix
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________
PATmat          = cfg_files; %Select PAT.mat for this subject 
PATmat.name     = 'Select PAT.mat'; % The displayed name
PATmat.tag      = 'PATmat';       %file names
PATmat.filter   = 'mat';
PATmat.ufilter  = '^PAT.mat$';    
PATmat.num      = [minPAT Inf];     % Number of inputs required 
PATmat.help     = {'Select PATmat dependency if available. '
    'Otherwise, for each subject, select PAT.mat.'}'; % help text displayed

% EOF
