function ica1 = pat_ica_cfg
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
        
%% Input Items
PATmat         = cfg_files; %Select NIRS.mat for this subject 
PATmat.name    = 'PAT.mat'; % The displayed name
PATmat.tag     = 'PATmat';       %file names
PATmat.filter  = 'mat';
PATmat.ufilter = '^PAT.mat$';    
PATmat.num     = [1 Inf];     % Number of inputs required 
PATmat.help    = {'Select PAT.mat for the scan.'}; % help text displayed

redo1         = cfg_menu; % This is the generic data entry item
redo1.name    = 'Force Redo?'; % The displayed name
redo1.tag     = 'redo';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
redo1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
redo1.values  = {0,1};
redo1.val     = {0};
redo1.help    = {'This option will force recomputation.'}; % help text displayed


%% Input Items for display mask
tol1         = cfg_entry; % This is the generic data entry item
tol1.name    = 'Tolerance factor to terminate'; % The displayed name
tol1.tag     = 'tolerance_factor';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
tol1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
tol1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
tol1.val     = {1e-6};
tol1.help    = {'Tolerance factor to stop iterations.'}; % help text displayed

mu1         = cfg_entry; % This is the generic data entry item
mu1.name    = 'Spatio temporal parameter'; % The displayed name
mu1.tag     = 'st_param';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
mu1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
mu1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
mu1.val     = {0.5};
mu1.help    = {'Parameter weighting spectral vs spatial components. 1 = pure spectral, 0 = pure spatial.'}; % help text displayed

maxrounds1         = cfg_entry; % This is the generic data entry item
maxrounds1.name    = 'Maximum number of rounds'; % The displayed name
maxrounds1.tag     = 'max_rounds';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
maxrounds1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
maxrounds1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
maxrounds1.val     = {100};
maxrounds1.help    = {'Maximum number of rounds in the ICA process.'}; % help text displayed

%% Input Items for display mask
nics1         = cfg_entry; % This is the generic data entry item
nics1.name    = 'Number of independent components'; % The displayed name
nics1.tag     = 'nICs';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
nics1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
nics1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
nics1.val     = {10};
nics1.help    = {'Number of independent components to aim for.'}; % help text displayed

% Executable Branch
ica1      = cfg_exbranch;       % This is the branch that has information about how to run this module
ica1.name = 'Independent Component Analysis';             % The display name
ica1.tag  = 'ica1'; %Very important: tag is used when calling for execution
ica1.val  = {PATmat redo1 nics1 maxrounds1 mu1 tol1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
ica1.prog = @pat_ica_run;  % A function handle that will be called with the harvested job to run the computation
ica1.vout = @pat_cfg_vout_ica; % A function handle that will be called with the harvested job to determine virtual outputs
ica1.help = {'Multispectral Independent Component Analysis.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_ica(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
