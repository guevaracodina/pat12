function mc1 = pat_simu_montecarlo_cfg
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
PATmat.num     = [0 Inf];     % Number of inputs required 
PATmat.help    = {'Select PAT.mat for the scan.'}; % help text displayed

redo1         = cfg_menu; % This is the generic data entry item
redo1.name    = 'Force Redo?'; % The displayed name
redo1.tag     = 'redo';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
redo1.labels  = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
redo1.values  = {0,1};
redo1.val     = {0};
redo1.help    = {'This option will force recomputation.'}; % help text displayed

%% Input Items for display mask
wave1         = cfg_entry; % This is the generic data entry item
wave1.name    = 'Wavelengths'; % The displayed name
wave1.tag     = 'wavelengths';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
wave1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
wave1.num     = [1 Inf];     % Number of inputs required (2D-array with exactly one row and two column)
wave1.val     = {[680]};
wave1.help    = {'Wavelengths to simulate: vector.'}; % help text displayed

%% Input Items for display mask
dims1         = cfg_entry; % This is the generic data entry item
dims1.name    = 'Volume Dimension'; % The displayed name
dims1.tag     = 'dims';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
dims1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
dims1.num     = [1 3];     % Number of inputs required (2D-array with exactly one row and two column)
dims1.val     = {[50 50 30]};
dims1.help    = {'Dimensions in mm of the volume simulated.'}; % help text displayed

%% Input Items for display mask
vsize1         = cfg_entry; % This is the generic data entry item
vsize1.name    = 'Voxel size'; % The displayed name
vsize1.tag     = 'vox_size';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
vsize1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
vsize1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
vsize1.val     = {[1]};
vsize1.help    = {'Dimensions in mm of the voxels (isotropic).'}; % help text displayed

%% Input Items for display mask
param1         = cfg_entry; % This is the generic data entry item
param1.name    = 'Scattering Model Parameters'; % The displayed name
param1.tag     = 'scat_params';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
param1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
param1.num     = [1 2];     % Number of inputs required (2D-array with exactly one row and two column)
param1.val     = {[1.1 1.2]};
param1.help    = {'Exponential Law Parameters [a b] for reduced scattering.'}; % help text displayed

% Executable Branch
mc1      = cfg_exbranch;       % This is the branch that has information about how to run this module
mc1.name = 'Monte Carlo Simulation';             % The display name
mc1.tag  = 'mc1'; %Very important: tag is used when calling for execution
mc1.val  = {PATmat redo1 wave1 dims1 vsize1 param1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
mc1.prog = @pat_simu_montecarlo_run;  % A function handle that will be called with the harvested job to run the computation
mc1.vout = @pat_cfg_vout_simu_montecarlo; % A function handle that will be called with the harvested job to determine virtual outputs
mc1.help = {'Monte-Carlo simulation over wavelengths.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_simu_montecarlo(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
