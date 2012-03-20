function kwave1 = pat_kwave_cfg
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

%% Input Items
segvolmat         = cfg_files; %Select NIRS.mat for this subject
segvolmat.name    = 'Segmented Volume'; % The displayed name
segvolmat.tag     = 'seg_volume';       %file names
segvolmat.filter  = 'mat';
segvolmat.ufilter = '*.';    
segvolmat.num     = [0 Inf];     % Number of inputs required 
segvolmat.help    = {'Select the Segmented Volume.'}; % help text displayed

%% Input Items for display mask
kwave_vsize1         = cfg_entry; % This is the generic data entry item
kwave_vsize1.name    = 'Ultrasound Voxel size'; % The displayed name
kwave_vsize1.tag     = 'kwave_vox_size';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
kwave_vsize1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
kwave_vsize1.num     = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
kwave_vsize1.val     = {[0.3906]};
kwave_vsize1.help    = {'Dimensions in mm of the voxels for ultrasound propagation(isotropic).'}; % help text displayed

% Executable Branch
kwave1      = cfg_exbranch;       % This is the branch that has information about how to run this module
kwave1.name = 'Ultrasound simulation';             % The display name
kwave1.tag  = 'kwave1'; %Very important: tag is used when calling for execution
kwave1.val  = {PATmat redo1 segvolmat kwave_vsize1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
kwave1.prog = @pat_kwave_run;  % A function handle that will be called with the harvested job to run the computation
kwave1.vout = @pat_cfg_vout_kwave; % A function handle that will be called with the harvested job to determine virtual outputs
kwave1.help = {'Multiplication of fluence by photoacoustique yield and ultrasound simulation (direct model)'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_kwave(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
