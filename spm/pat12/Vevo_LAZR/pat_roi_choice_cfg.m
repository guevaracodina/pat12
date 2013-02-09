function ROI_choice = pat_roi_choice_cfg
% Choose all ROIs/seeds or a selected list to process.
%_______________________________________________________________________________
% Copyright (C) 2010 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
all_ROIs                = cfg_branch;
all_ROIs.tag            = 'all_ROIs';
all_ROIs.name           = 'All ROIs';
all_ROIs.val            = {};
all_ROIs.help           = {'All ROIs will be processed'};

selected_ROIs           = cfg_entry;
selected_ROIs.tag       = 'selected_ROIs';
selected_ROIs.name      = 'Enter list of ROIs';
selected_ROIs.strtype   = 'r';
selected_ROIs.num       = [1 Inf];
selected_ROIs.val{1}    = 1;
selected_ROIs.help      = {'Enter list of ROIs to process.'};

select_ROIs             = cfg_branch;
select_ROIs.tag         = 'select_ROIs';
select_ROIs.name        = 'Select ROIs';
select_ROIs.val         = {selected_ROIs};
select_ROIs.help        = {'Choose some ROIs to be processed'};

ROI_choice              = cfg_choice;
ROI_choice.name         = 'Choose ROI selection method';
ROI_choice.tag          = 'ROI_choice';
ROI_choice.values       = {all_ROIs,select_ROIs};
ROI_choice.val          = {all_ROIs};
ROI_choice.help         = {'Choose ROI selection method'}';

% EOF
