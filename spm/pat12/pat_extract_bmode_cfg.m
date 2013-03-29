function extract_bmode1 = pat_extract_bmode_cfg
% Graphical interface configuration function for pat_extract_bmode_run.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('Bmode');

% Extract .BMP (lossless compression to .PNG files to save disk space)
extractBMP              = cfg_menu;
extractBMP.tag          = 'extractBMP';
extractBMP.name         = 'Extract B-Mode RAW data as .PNG';
extractBMP.labels       = {'No', 'Yes'};
extractBMP.values       = {false, true};
extractBMP.val          = {true};
extractBMP.help         = {'Extract B-Mode RAW data as a series of .PNG images'};

% Executable Branch
extract_bmode1          = cfg_exbranch;                 % This is the branch that has information about how to run this module
extract_bmode1.name     = 'B-mode image extraction';    % The display name
extract_bmode1.tag      = 'extract_bmode1';             % Very important: tag is used when calling for execution
extract_bmode1.val      = {PATmat redo1 ...
                        PATmatCopyChoice extractBMP};   % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
extract_bmode1.prog     = @pat_extract_bmode_run;       % A function handle that will be called with the harvested job to run the computation
extract_bmode1.vout     = @pat_cfg_vout_extract_bmode;  % A function handle that will be called with the harvested job to determine virtual outputs
extract_bmode1.help     = {'B-mode image extraction to NIfTI.'};

return

% make PAT.mat available as a dependency
function vout           = pat_cfg_vout_extract_bmode(job)
vout                    = cfg_dep;                     % The dependency object
vout.sname              = 'PAT.mat';       % Displayed dependency name
vout.src_output         = substruct('.','PATmat'); %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
