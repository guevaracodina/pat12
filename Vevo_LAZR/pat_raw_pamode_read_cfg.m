function extract_rawPA1 = pat_raw_pamode_read_cfg
% Graphical interface configuration function for pat_raw_pamode_read_run.
% This code is part of a batch job configuration system for MATLAB. See help
% matlabbatch for a general overview.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

input_dir               = cfg_files;
input_dir.name          = 'Directory with raw files';
input_dir.tag           = 'input_dir';       
input_dir.filter        = 'dir';
input_dir.ufilter       = '.*';
input_dir.num           = [1 Inf];     
input_dir.help          = {'Directory(ies) containing raw files (raw.pamode).'}'; 

% inputDataTopDir         = cfg_files;
% inputDataTopDir.name    = 'Input Top Directory';
% inputDataTopDir.tag     = 'input_data_topdir';       
% inputDataTopDir.filter  = 'dir';
% inputDataTopDir.num     = [1 1];     
% inputDataTopDir.help    = {'Directory under which all raw files are located.'}'; 

output_dir              = cfg_files;
output_dir.name         = 'Results Top directory';
output_dir.tag          = 'output_dir';       
output_dir.filter       = 'dir';
output_dir.num          = [1 1];     
output_dir.help         = {'Directory where all results (and PAT.mat) will be kept will be saved'}'; 

% Executable Branch
extract_rawPA1          = cfg_exbranch;       % This is the branch that has information about how to run this module
extract_rawPA1.name     = 'raw.pamode extraction';             % The display name
extract_rawPA1.tag      = 'extract_rawPA1'; %Very important: tag is used when calling for execution
extract_rawPA1.val      = {input_dir output_dir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
extract_rawPA1.prog     = @pat_raw_pamode_read_run;  % A function handle that will be called with the harvested job to run the computation
extract_rawPA1.vout     = @pat_cfg_vout_raw_pamode_read; % A function handle that will be called with the harvested job to determine virtual outputs
extract_rawPA1.help     = {'raw.pamode extraction.'};

return

%make PAT.mat available as a dependency
function vout           = pat_cfg_vout_raw_pamode_read(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
