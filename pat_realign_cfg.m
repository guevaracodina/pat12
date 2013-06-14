function realign1 = pat_realign_cfg
% Graphical interface configuration function for pat_realign_run.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
        
%% Input Items
% Choose PAT matrix
PATmat          = pat_PATmat_cfg(1);
% Force re-do
redo1           = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice= pat_PATmatCopyChoice_cfg('realign');

%% Input Items for display mask
quality1        = cfg_entry; % This is the generic data entry item
quality1.name   = 'Quality'; % The displayed name
quality1.tag    = 'quality';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
quality1.strtype= 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
quality1.num    = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
quality1.val    = {0.5};
quality1.help   = {'Quality versus speed trade-off.  Highest quality (1) gives most precise results, whereas lower qualities gives faster realignment. The idea is that some voxels contribute little to the estimation of the realignment parameters. This parameter is involved in selecting the number of voxels that are used.'}; % help text displayed

%% Input Items for display mask
fwhm1           = cfg_entry; % This is the generic data entry item
fwhm1.name      = 'Kernel FWHM'; % The displayed name
fwhm1.tag       = 'fwhm';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
fwhm1.strtype   = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
fwhm1.num       = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
fwhm1.val       = {0.05};
fwhm1.help      = {'The FWHM of the Gaussian smoothing kernel (mm) applied to the images before estimating the realignment parameters.'}; % help text displayed

%% Input Items for display mask
sep1            = cfg_entry; % This is the generic data entry item
sep1.name       = 'Sample point separation'; % The displayed name
sep1.tag        = 'sep';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
sep1.strtype    = 'e';       % No restriction on what type of data is entered. This could be used to restrict input to real numbers, integers ...
sep1.num        = [1 1];     % Number of inputs required (2D-array with exactly one row and two column)
sep1.val        = {0.02};
sep1.help       = {'The default separation (mm) to sample the images for registration.'}; % help text displayed

rtm1            = cfg_menu; % This is the generic data entry item
rtm1.name       = 'Register to mean?'; % The displayed name
rtm1.tag        = 'rtm';       % The name appearing in the harvested job structure. This name must be unique among all items in the val field of the superior node
rtm1.labels     = {'No', 'Yes'};     % Number of inputs required (2D-array with exactly one row and two column)
rtm1.values     = {0,1};
rtm1.val        = {1};
rtm1.help       = {'This option will force recomputation in a second pass to register to mean. Default is yes.'}; % help text displayed

% Executable Branch
realign1        = cfg_exbranch;       % This is the branch that has information about how to run this module
realign1.name   = 'Image realignement';             % The display name
realign1.tag    = 'realign1'; %Very important: tag is used when calling for execution
realign1.val    = {PATmat redo1 PATmatCopyChoice quality1 fwhm1 sep1 rtm1};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
realign1.prog   = @pat_realign_run;  % A function handle that will be called with the harvested job to run the computation
realign1.vout   = @pat_cfg_vout_realign; % A function handle that will be called with the harvested job to determine virtual outputs
realign1.help   = {'Realign images in the stack to remove movement effects.'};

return

%make PAT.mat available as a dependency
function vout   = pat_cfg_vout_realign(job)
vout            = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
