function extract_rawB1 = pat_raw_bmode_read_cfg
% Graphical interface configuration function for pat_raw_bmode_read_run.
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
% IOI copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('Bmode');

% Extract .BMP
extractBMP              = cfg_menu;
extractBMP.tag          = 'extractBMP';
extractBMP.name         = 'Extract B-Mode RAW data as .BMP';
extractBMP.labels       = {'No', 'Yes'};
extractBMP.values       = {false, true};
extractBMP.val          = {true};
extractBMP.help         = {'Extract B-Mode RAW data as a series of .BMP images'};

% Executable Branch
extract_rawB1           = cfg_exbranch;       % This is the branch that has information about how to run this module
extract_rawB1.name      = 'raw.bmode extraction';             % The display name
extract_rawB1.tag       = 'extract_rawB1'; %Very important: tag is used when calling for execution
extract_rawB1.val       = {PATmat redo1 PATmatCopyChoice extractBMP};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
extract_rawB1.prog      = @pat_raw_bmode_read_run;  % A function handle that will be called with the harvested job to run the computation
extract_rawB1.vout      = @pat_cfg_vout_raw_bmode_read; % A function handle that will be called with the harvested job to determine virtual outputs
extract_rawB1.help      = {'raw.bmode extraction.'};

return

%make PAT.mat available as a dependency
function vout           = pat_cfg_vout_raw_bmode_read(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
