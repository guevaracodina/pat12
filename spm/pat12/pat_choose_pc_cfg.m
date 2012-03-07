function pcsel1 = pat_choose_pc_cfg
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

% Executable Branch
pcsel1      = cfg_exbranch;       % This is the branch that has information about how to run this module
pcsel1.name = 'Principal Component selection';             % The display name
pcsel1.tag  = 'pcsel1'; %Very important: tag is used when calling for execution
pcsel1.val  = {PATmat redo1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
pcsel1.prog = @pat_choose_pc_run;  % A function handle that will be called with the harvested job to run the computation
pcsel1.vout = @pat_cfg_vout_choose_pc; % A function handle that will be called with the harvested job to determine virtual outputs
pcsel1.help = {'Principal Component Selection'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_choose_pc(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
