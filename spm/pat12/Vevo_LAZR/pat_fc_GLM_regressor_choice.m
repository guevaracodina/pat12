function regressor_choice = pat_fc_GLM_regressor_choice
% Configuration choice of the GLM regressors.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

ROI_list                = cfg_entry;
ROI_list.name           = 'ROIs/seeds';
ROI_list.tag            = 'ROI_list';
ROI_list.strtype        = 'r';
ROI_list.num            = [1 Inf];
ROI_list.val            = {1};
ROI_list.help           = {'Enter ROIs/seeds list.'}';

motionParams           	= cfg_entry;
motionParams.name       = 'Motion Parameters';
motionParams.tag        = 'motionParams';
motionParams.strtype    = 'r';
motionParams.num        = [1 Inf];
motionParams.val        = {[1 2 6]};
motionParams.help       = { 'Enter motion parameters list.'
                            '1. X translation'
                            '2. Y translation'
                            '3. Z translation'
                            '4. Pitch'
                            '5. Roll'
                            '6. Yaw'}';

regressBrainSignal      = cfg_branch;
regressBrainSignal.tag  = 'regressBrainSignal';
regressBrainSignal.name = 'Global brain signal as regressor';
regressBrainSignal.val  = {};
regressBrainSignal.help = {'Include global brain signal as regressor.'};

regressROI              = cfg_branch;
regressROI.tag          = 'regressROI';
regressROI.name         = 'ROIs/seeds as regressors';
regressROI.val          = {ROI_list};
regressROI.help         = { 'Include ROIs/seeds as regressors.' 
                            'See PAT.ROI.ROIname for the complete ROIs name list.'};

regressROIMotion        = cfg_branch;
regressROIMotion.tag    = 'regressROIMotion';
regressROIMotion.name   = 'ROIs/seeds AND motion parameters';
regressROIMotion.val    = {ROI_list motionParams};
regressROIMotion.help   = { 'Include ROIs/seeds and motion (realignment) parameters as regressors' 
                            'See PAT.ROI.ROIname for the complete ROIs name list.'
                            'There are 6 realignment parameters obtained by rigid body head motion correction'};

regressor_choice        = cfg_choice;
regressor_choice.tag    = 'regressor_choice';
regressor_choice.name   = 'Regress signal(s)';
regressor_choice.values = {regressBrainSignal regressROI regressROIMotion};
regressor_choice.val    = {regressBrainSignal};
regressor_choice.help   = { 'Choose signal(s) to include as nuisance regressors:'
                            'Include global brain signal as regressor.'
                            'Include ROIs/seeds as regressors.'
                            'Include ROIs/seeds and motion (realignment) parameters as regressors'
                            'See PAT.ROI.ROIname for the complete ROIs name list.'
                            'There are 6 realignment parameters obtained by rigid body head motion correction'
                            }';

% EOF
