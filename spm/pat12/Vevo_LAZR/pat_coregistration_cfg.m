function coregistration1 = pat_coregistration_cfg
% Graphical interface configuration function for pat_coregistration_run
% Coregistration of raw.pamode images to raw.bmode images.
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('coreg');
% Colors to include (HbT, SO2, Bmode)
IC                      = pat_include_colors_cfg(true, true);
% if true, chooses PAT image to be centered on B-mode image
AUTO                    = cfg_menu;
AUTO.tag                = 'AUTO';
AUTO.name               = 'Automatic';
AUTO.labels             = {'No','Yes'};
AUTO.values             = {false,true};
AUTO.val                = {true};
AUTO.help               = {'If automatic is chosen, then PAT image is centered on B-mode image'}';
% Image to display
frame2display           = cfg_entry;
frame2display.tag       = 'frame2display';
frame2display.name      = 'Frame to display';
frame2display.strtype   = 'r';
frame2display.num       = [1 1];
frame2display.val{1}    = 1;
frame2display.help      = {'Enter frame to display'};

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [4 2];
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
coregistration1       	= cfg_exbranch; % This is the branch that has information about how to run this module
coregistration1.name    = 'Coregistration'; % The display name
coregistration1.tag     = 'coregistration1'; %Very important: tag is used when calling for execution
coregistration1.val     = { PATmat redo1 PATmatCopyChoice IC AUTO frame2display...
                            generate_figures save_figures figSize figRes figCmap};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
coregistration1.prog	= @pat_coregistration_run; % A function handle that will be called with the harvested job to run the computation
coregistration1.vout    = @pat_cfg_vout_coregister; % A function handle that will be called with the harvested job to determine virtual outputs
coregistration1.help    = {'Manual/semi-automatic coregistration of raw.pamode images to raw.bmode image'}';
return

% Make IOI.mat available as a dependency
function vout           = pat_cfg_vout_coregister(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
