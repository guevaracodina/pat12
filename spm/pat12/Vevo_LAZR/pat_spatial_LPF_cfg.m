function spatial_LPF1 = pat_spatial_LPF_cfg
% Graphical interface configuration function for pat_spatial_LPF_run
% Low-pass filtering of 2-D images with a rotationally symmetric gaussian kernel
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('ROI');
% Colors to include (OD,HbO,HbR,HbT,Flow)
IC                      = pat_include_colors_cfg(0,1,1,1,1);
% Spatial low-pass filter options
spatial_LPF_options     = pat_spatial_LPF_options_cfg;

% Executable Branch
spatial_LPF1            = cfg_exbranch;       % This is the branch that has information about how to run this module
spatial_LPF1.name       = 'Spatial low-pass filtering';             % The display name
spatial_LPF1.tag        = 'spatial_LPF1'; %Very important: tag is used when calling for execution
spatial_LPF1.val        = {PATmat redo1 PATmatCopyChoice IC spatial_LPF_options};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
spatial_LPF1.prog       = @pat_spatial_LPF_run;  % A function handle that will be called with the harvested job to run the computation
spatial_LPF1.vout       = @pat_cfg_vout_spatial_LPF; % A function handle that will be called with the harvested job to determine virtual outputs
spatial_LPF1.help       = {'Low-pass filtering of 2-D images using a rotationally symmetric gaussian kernel.'
    'Usually done after computing concentrations/flow.'}';

return

% Make PAT.mat available as a dependency
function vout = pat_cfg_vout_spatial_LPF(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF

