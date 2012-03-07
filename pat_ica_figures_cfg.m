function icafig1 = pat_ica_figures_cfg
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


mode1         = cfg_menu; % This is the generic data entry item
mode1.name    = 'Mode'; % The displayed name
mode1.tag     = 'mode';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
mode1.labels  = {'Series', 'Contour'};     % Number of inputs required (2D-array with exactly one row and two column)
mode1.values  = {'series','contour'};
mode1.val     = {'series'};
mode1.help    = {'This option will plot ICAs as series or contour plot in the same image.'}; % help text displayed

range1         = cfg_entry; % This is the generic data entry item
range1.name    = 'Spectral range'; % The displayed name
range1.tag     = 'spectral_range';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
range1.strtype = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
range1.num     = [1 2];     % Number of inputs required (2D-array with exactly one row and two column)
range1.val     = {[680 970]};
range1.help    = {'First and last wavelength of the scan.'}; % help text displayed

% Executable Branch
icafig1      = cfg_exbranch;       % This is the branch that has information about how to run this module
icafig1.name = 'ICA Figures';             % The display name
icafig1.tag  = 'icafig1'; %Very important: tag is used when calling for execution
icafig1.val  = {PATmat redo1 mode1 range1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
icafig1.prog = @pat_ica_figures_run;  % A function handle that will be called with the harvested job to run the computation
icafig1.vout = @pat_cfg_vout_ica_figures; % A function handle that will be called with the harvested job to determine virtual outputs
icafig1.help = {'Build figures for Multispectral Independent Component Analysis.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_ica_figures(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
