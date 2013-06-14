function renameROI1 = pat_rename_roi_cfg
% Graphical interface configuration function for pat_rename_roi_run
% Rename ROI
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('ROIrename');

% ROIs names
ROInames                = cfg_entry;
ROInames.tag            = 'ROInames';
ROInames.name           = 'ROI names';
ROInames.strtype        = 'e';
ROInames.num            = [1 Inf];
ROInames.val            = {{    'CPu_L'     % Caudate putamen
                                'CPu_R'     % Caudate putamen
                                'LV_L'      % Lateral Ventricle
                                'LV_R'      % Lateral Ventricle
                                'M_L'       % Motor cortex
                                'M_R'       % Motor cortex
                                'S1_L'      % Primary somatosensory cortex
                                'S1_R'      % Primary somatosensory cortex
                                'S1BF_L'    % Barrel field primary somatosensory cortex
                                'S1BF_R'    % Barrel field primary somatosensory cortex
                                }'};  
                    
ROInames.help           = {'Enter ROIs names. Default: {''CPu_L'', ''CPu_R'', ''LV_L'', ''LV_R'', ''M_L'', ''M_R'', ''S1_L'', ''S1_R'', ''S1BF_L'', ''S1BF_r''}'};

% ------------------------------------------------------------------------------

% Executable Branch
renameROI1              = cfg_exbranch; % This is the branch that has information about how to run this module
renameROI1.name         = 'Rename ROIs'; % The display name
renameROI1.tag          = 'renameROI1'; %Very important: tag is used when calling for execution
renameROI1.val          = {PATmat redo1 PATmatCopyChoice ROInames};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
renameROI1.prog         = @pat_rename_roi_run; % A function handle that will be called with the harvested job to run the computation
renameROI1.vout         = @pat_cfg_vout_renameROI; % A function handle that will be called with the harvested job to determine virtual outputs
renameROI1.help         = {'Rename ROIs'}';
return

% Make IOI.mat available as a dependency
function vout           = pat_cfg_vout_renameROI(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
