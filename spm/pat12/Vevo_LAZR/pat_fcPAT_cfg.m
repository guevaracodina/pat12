function fcPAT = pat_fcPAT_cfg
% Graphical interface configuration function for functional connectivity mapping
% based on photoacoustic tomography (fcPAT) signals.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

fcPAT        = cfg_choice;
fcPAT.name   = 'Functional connectivity mapping (fcPAT)';
fcPAT.tag    = 'fcPAT';
fcPAT.values = {pat_brainmask_cfg pat_create_roi_cfg pat_spatial_LPF_cfg...
    pat_extract_roi_time_series_cfg pat_filtdown_cfg pat_fc_GLM_on_ROI_cfg ...
    pat_correlation_map_cfg pat_plot_roi_cfg pat_send_email_cfg};
% fcPAT.values = {
%      pat_group_corr_cfg  ...
%     pat_fcIOS_maps_cfg};
fcPAT.help   = {'These modules perform resting-state functional connectivity mapping based on photoacoustic tomography (fcPAT) signals.'};

% EOF
