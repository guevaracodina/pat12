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
regressROIMotion.name   = 'ROIs/seeds as regressors';
regressROIMotion.val    = {ROI_list};
regressROIMotion.help   = { 'Include ROIs/seeds and motion (realignment) parameters as regressors' 
                            'See PAT.ROI.ROIname for the complete ROIs name list.'
                            'There are 6 realignment parameters obtained by rigid body head motion correction'};

regressor_choice        = cfg_choice;
regressor_choice.tag    = 'regressor_choice';
regressor_choice.name   = 'Regress global brain signal';
regressor_choice.values = {regressBrainSignal regressROI regressROIMotion};
regressor_choice.val    = {regressBrainSignal};
regressor_choice.help   = {'Choose whether to include global brain signal as regressor'}';

% EOF
