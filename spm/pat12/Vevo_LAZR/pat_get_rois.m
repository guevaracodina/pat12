function [all_ROIs selected_ROIs] = pat_get_rois(job)
% Returns the selection of ROIs.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

if isfield(job.ROI_choice,'select_ROIs')
    all_ROIs        = false;
    selected_ROIs   = job.ROI_choice.select_ROIs.selected_ROIs;
else
    all_ROIs        = true;
    selected_ROIs   = [];
end

% EOF
