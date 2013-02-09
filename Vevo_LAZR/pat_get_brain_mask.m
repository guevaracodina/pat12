function [PAT mask] = pat_get_brain_mask(PAT)
% Loads the brain mask used in functional connectivity mapping with
% photoacoustic tomography (fcPAT)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Only one brain mask per subject
r1 = 1; 
% Read NIfTI file
vol = spm_vol(PAT.fcPAT.mask.fname);
tmp_mask = logical(spm_read_vols(vol));
mask{r1} = tmp_mask;

% EOF
