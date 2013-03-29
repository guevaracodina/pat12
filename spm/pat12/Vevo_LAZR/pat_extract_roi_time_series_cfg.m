function extract_roi1 = pat_extract_roi_time_series_cfg
% Graphical interface configuration function for pat_extract_roi_time_series_run
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('ROItimeCourse');
% Choose ROI selection method (all/selected)
ROI_choice              = pat_roi_choice_cfg;
% Colors to include (HbT, SO2, Bmode)
IC                      = pat_include_colors_cfg(true, true);


% Extract mean signal (from the brain mask pixels)
extractBrainMask        = cfg_menu;
extractBrainMask.tag    = 'extractBrainMask';
extractBrainMask.name   = 'Extract brain mask signal';
extractBrainMask.labels = {'Yes','No'};
extractBrainMask.values = {true, false};
extractBrainMask.val    = {false};   % Default value = 0
extractBrainMask.help   = {'Extract mean signal from the non-masked brain pixels'};
% Extract mean signal (from the brain mask pixels) -- this time using an
% activation map
activMask_choice        = pat_activation_mask_choice_cfg(false);

% Executable Branch
extract_roi1            = cfg_exbranch;       % This is the branch that has information about how to run this module
extract_roi1.name       = 'Extract ROI/seed';             % The display name
extract_roi1.tag        = 'extract_roi1'; %Very important: tag is used when calling for execution
extract_roi1.val        = {PATmat redo1 PATmatCopyChoice ...
    ROI_choice IC extractBrainMask activMask_choice };    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
extract_roi1.prog       = @pat_extract_roi_time_series_run;  % A function handle that will be called with the harvested job to run the computation
extract_roi1.vout       = @pat_cfg_vout_extract_roi; % A function handle that will be called with the harvested job to determine virtual outputs
extract_roi1.help       = {'Create regions of interest.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_extract_roi(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
