function filtdown1 = pat_filtdown_cfg
% Graphical interface configuration function for pat_filtdown_run
%_______________________________________________________________________________
% Copyright (C) 2010 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat              = pat_PATmat_cfg(1);
% Force re-do
redo1               = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice    = pat_PATmatCopyChoice_cfg('BPF');
% Choose ROI selection method (all/selected)
ROI_choice          = pat_roi_choice_cfg;
% Colors to include (HbT, SO2, Bmode)
IC                  = pat_include_colors_cfg(true, true);

% Bandpass filtering
bpf                 = pat_bpf_cfg(1, [0.009 0.08], 2, 'butter');

% Generate / save figures
[generate_figures ...
    save_figures]   = pat_generate_figures_cfg;

% Figure resolution
figRes              = cfg_entry;
figRes.tag          = 'figRes';
figRes.name         = 'Figure resolution';
figRes.strtype      = 'r';
figRes.num          = [1 1];
figRes.val{1}       = 300;
figRes.help         = {'Enter figure resolution in dpi [300-1200]'};

% Filter whole images
wholeImage          = cfg_menu;
wholeImage.tag      = 'wholeImage';
wholeImage.name     = 'Filter whole image time-series';
wholeImage.labels   = {'Yes','No'};
wholeImage.values   = {1,0};
wholeImage.val      = {1};
wholeImage.help     = {'Filter whole image time-series. It creates a new sub-folder for each session'};

% Executable Branch
filtdown1           = cfg_exbranch; % This is the branch that has information about how to run this module
filtdown1.name      = 'Temporal filtering';             % The display name
filtdown1.tag       = 'filtdown1'; %Very important: tag is used when calling for execution
filtdown1.val       = {PATmat redo1 PATmatCopyChoice ROI_choice IC bpf wholeImage generate_figures save_figures figRes};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
filtdown1.prog      = @pat_filtdown_run;  % A function handle that will be called with the harvested job to run the computation
filtdown1.vout      = @pat_cfg_vout_filtdown; % A function handle that will be called with the harvested job to determine virtual outputs
filtdown1.help      = {'Temporal band-pass filtering of a given time trace [HbT/SO2], either on a seed or on the whole image series.'};

return

% Make PAT.mat available as a dependency
function vout = pat_cfg_vout_filtdown(job)
vout                = cfg_dep;                  % The dependency object
vout.sname          = 'PAT.mat';                % Displayed dependency name
vout.src_output     = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec       = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
