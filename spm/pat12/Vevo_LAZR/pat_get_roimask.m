function [PAT mask] = pat_get_roimask(PAT,job)
% Get binary masks from ROIs/seeds
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

[all_ROIs selected_ROIs] = pat_get_rois(job);
% loop over ROIs
for r1 = 1:length(PAT.res.ROI)
    if all_ROIs || sum(r1==selected_ROIs)
        vol = spm_vol(PAT.res.ROI{r1}.fname);
        tmp_mask = logical(spm_read_vols(vol));
        mask{r1} = tmp_mask;
    end
end

% EOF
