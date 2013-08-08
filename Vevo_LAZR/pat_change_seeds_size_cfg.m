function seed_radius = pat_change_seeds_size_cfg
% Graphical interface configuration function for pat_change_seeds_size_run
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Select PAT.mat
PATmat                  = pat_PATmat_cfg();
% Force processing
redo1                   = pat_redo_cfg(1);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('seedRadius');
% Choose ROI selection method (all/selected)
ROI_choice              = pat_roi_choice_cfg;
ManualROIradius         = cfg_entry;
ManualROIradius.name    = 'Radius size of ROIs/seeds';
ManualROIradius.tag     = 'ManualROIradius';       
ManualROIradius.strtype = 'r';
ManualROIradius.val{1}  = 5;                    % Default value
ManualROIradius.num     = [1 1];     
ManualROIradius.help    = {'Enter radius of the ROIs/seeds in mm.'}'; 
% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% Executable Branch
seed_radius             = cfg_exbranch; % This is the branch that has information about how to run this module
seed_radius.name        = 'Change seed radius'; % The display name
seed_radius.tag         = 'seed_radius'; %Very important: tag is used when calling for execution
seed_radius.val         = {PATmat redo1 PATmatCopyChoice ROI_choice ManualROIradius...
                        generate_figures save_figures};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
seed_radius.prog        = @pat_change_seeds_size_run; % A function handle that will be called with the harvested job to run the computation
seed_radius.vout        = @pat_cfg_vout_change_seeds_size; % A function handle that will be called with the harvested job to determine virtual outputs
seed_radius.help        = {'Gets the correlation between each seed and its contralateral homologue. Then performs a non-paired t-test for each seed set, to have a group comparison.'}';

return

% Make PAT.mat available as a dependency
function vout           = pat_cfg_vout_change_seeds_size(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
