function hbohbr1 = pat_get_hbo_hbr_cfg
% Graphical interface configuration function for pat_get_hbo_hbr_run
% Get HbO & HbR from HbT & SO2
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('hbo_hbr');
% Choose ROI selection method (all/selected)
ROI_choice              = pat_roi_choice_cfg;
% Force all colors except B-mode
IC                      = pat_include_colors_cfg(true, true, false, true, true);

% Use scrubbing
scrubbing               = cfg_menu;
scrubbing.tag           = 'scrubbing';
scrubbing.name          = 'Scrubbing';
scrubbing.labels        = {'No','Yes'};
scrubbing.values        = {false, true};
scrubbing.val           = {true};
scrubbing.help          = {'Use scrubbing to remove artifacts before correlation computation'}';

% Seeds correlation matrix
seed2seedCorrMat        = cfg_menu;
seed2seedCorrMat.tag    = 'seed2seedCorrMat';
seed2seedCorrMat.name   = 'seed2seedCorrMat';
seed2seedCorrMat.labels = {'No', 'Yes'};
seed2seedCorrMat.values = {false, true};
seed2seedCorrMat.val    = {true};                      % Default value
seed2seedCorrMat.help   = {'Choose whether to compute a seed-to-seed correlation matrix'}';

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [1 1];
figSize.help            = {'Enter figure size in inches.'};

% Figure resolution
figRes                  = cfg_entry;
figRes.tag              = 'figRes';
figRes.name             = 'Figure resolution';
figRes.strtype          = 'r';
figRes.num              = [1 1];
figRes.val{1}           = 300;
figRes.help             = {'Enter figure resolution in dpi [300-1200]'};

% Colormap to use
figCmap                 = cfg_entry;
figCmap.tag             = 'figCmap';
figCmap.name            = 'Colormap';
figCmap.strtype         = 'e';
figCmap.num             = [Inf 3];
figCmap.val{1}          = gray(256);
figCmap.help            = {'Enter colormap to use. e.g. type jet(256), Input is evaluated'};
% ------------------------------------------------------------------------------

% Executable Branch
hbohbr1                 = cfg_exbranch; % This is the branch that has information about how to run this module
hbohbr1.name            = 'Get HbO & HbR'; % The display name
hbohbr1.tag             = 'hbohbr1'; %Very important: tag is used when calling for execution
hbohbr1.val             = { PATmat redo1 PATmatCopyChoice ROI_choice IC...
                            scrubbing seed2seedCorrMat generate_figures save_figures figSize figRes figCmap};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
hbohbr1.prog            = @pat_get_hbo_hbr_run; % A function handle that will be called with the harvested job to run the computation
hbohbr1.vout            = @pat_cfg_vout_hbo_hbr; % A function handle that will be called with the harvested job to determine virtual outputs
hbohbr1.help            = {'Get Oxy- & deoxy-hemoglobin (HbO & HbR) from total hemoglobin (HbT) & oxygen saturation (SO2)'}';
return

% Make IOI.mat available as a dependency
function vout           = pat_cfg_vout_hbo_hbr(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
