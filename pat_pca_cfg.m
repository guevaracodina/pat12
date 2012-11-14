function pca1 = pat_pca_cfg
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
npcs1         = cfg_entry; % This is the generic data entry item
npcs1.name    = 'Number of principal components'; % The displayed name
npcs1.tag     = 'nPCs';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
npcs1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
npcs1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
npcs1.val     = {10};
npcs1.help    = {'Number of principal components to keep.'}; % help text displayed

savefigs1         = cfg_menu; % This is the generic data entry item
savefigs1.name    = 'Save Figures?'; % The displayed name
savefigs1.tag     = 'save_figures';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
savefigs1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
savefigs1.values  = {0,1};
savefigs1.val     = {1};
savefigs1.help    = {'This option will save figures.'}; % help text displayed

% Executable Branch
pca1      = cfg_exbranch;       % This is the branch that has information about how to run this module
pca1.name = 'Spectral Principal Component Analysis';             % The display name
pca1.tag  = 'pca1'; %Very important: tag is used when calling for execution
pca1.val  = {PATmat redo1 npcs1 savefigs1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
pca1.prog = @pat_pca_run;  % A function handle that will be called with the harvested job to run the computation
pca1.vout = @pat_cfg_vout_pca; % A function handle that will be called with the harvested job to determine virtual outputs
pca1.help = {'Multispectral Principal Component Analysis.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_pca(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
