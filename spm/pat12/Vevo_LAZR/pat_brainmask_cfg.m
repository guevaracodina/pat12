function mask1 = pat_brainmask_cfg
% Batch job configuration system for pat_brainmask_run
% Manual segmentation of the brain to provide a mask for fcOIS analysis
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% IOI copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('BrainMask');

% Executable Branch
mask1                   = cfg_exbranch; % This is the branch that has information about how to run this module
mask1.name              = 'Create Brain Mask'; % The display name
mask1.tag               = 'mask1'; %Very important: tag is used when calling for execution
mask1.val               = {PATmat redo1 PATmatCopyChoice};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
mask1.prog              = @pat_brainmask_run;  % A function handle that will be called with the harvested job to run the computation
mask1.vout              = @pat_cfg_vout_brainmask; % A function handle that will be called with the harvested job to determine virtual outputs
mask1.help              = {'Manual segmentation of the brain to provide a mask for fcOIS analysis'};

return

%make PAT.mat available as a dependency
function vout           = pat_cfg_vout_brainmask(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
