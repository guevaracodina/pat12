function DVARS = pat_compute_DVARS(PAT,c1)
% Computes DVARS
% DVARS (D referring to temporal derivative of timecourses, VARS referring to
% RMS variance over voxels) is a measure of how much the intensity of a brain
% image changes in comparison to the previous timepoint
% SYNTAX
% DVARS = pat_compute_DVARS(PAT,c1)
% INPUTS
% PAT       PAT structure
% c1        Color index
% OUTPUT
% DVARS     Parameter that represents image intensity variations.
% Reference
% [1] J. D. Power, K. A. Barnes, A. Z. Snyder, B. L. Schlaggar, and S. E.
% Petersen, “Spurious but systematic correlations in functional connectivity MRI
% networks arise from subject motion,” Neuroimage, vol. 59, no. 3, pp.
% 2142–2154, Feb. 2012.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% Read brain mask
volMask = spm_vol(PAT.fcPAT.mask.fname);
brainMask = logical(spm_read_vols(volMask));
% Read functional images
volPA = spm_vol(PAT.nifti_files{c1});
imPA = spm_read_vols(volPA);
% 1st order derivative
N = 1;
% differentiation along the temporal dimension
DIM = 4;
% Compute derivative
imPAdiff = diff(imPA,N,DIM);
% We add a zero at the beginning all subsequent images are aligned to the 1st.
imPAdiff = cat(DIM, zeros([size(imPAdiff,1) size(imPAdiff,2) 1 1]), imPAdiff);
nFrames = size(imPA,4);
DVARS = zeros([nFrames 1]);
% Compute RMS
for iFrames = 1:nFrames
    tmpFrame = squeeze(imPAdiff(:,:,1,iFrames));
    tmpFrame = tmpFrame(brainMask);
    DVARS(iFrames) = pat_rms(tmpFrame);
end
end

% EOF
