function extract_tiff1 = pat_extract_tiff_cfg
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
        
inputdir         = cfg_files;
inputdir.name    = 'Directory containing raw tiff files';
inputdir.tag     = 'input_dir';       
inputdir.filter = 'dir';
inputdir.ufilter    = '.*';
inputdir.num     = [1 Inf];     
inputdir.help    = {'Directory containing raw tiff files.'}'; 

inputdatatopdir         = cfg_files;
inputdatatopdir.name    = 'Top directory where input files are located';
inputdatatopdir.tag     = 'input_data_topdir';       
inputdatatopdir.filter = 'dir';
inputdatatopdir.num     = [1 1];     
inputdatatopdir.help    = {'Directory under which all tiff files are located.'}'; 

outputdir         = cfg_files;
outputdir.name    = 'Top directory where results (and PAT.mat) will be saved';
outputdir.tag     = 'output_dir';       
outputdir.filter = 'dir';
outputdir.num     = [1 1];     
outputdir.help    = {'Directory where all results will be kept'}'; 

% Executable Branch
extract_tiff1      = cfg_exbranch;       % This is the branch that has information about how to run this module
extract_tiff1.name = 'Tiff image extraction';             % The display name
extract_tiff1.tag  = 'extract_tiff1'; %Very important: tag is used when calling for execution
extract_tiff1.val  = {inputdir inputdatatopdir outputdir};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
extract_tiff1.prog = @pat_extract_tiff_run;  % A function handle that will be called with the harvested job to run the computation
extract_tiff1.vout = @pat_cfg_vout_extract_tiff; % A function handle that will be called with the harvested job to determine virtual outputs
extract_tiff1.help = {'Tiff image extraction.'};

return

%make PAT.mat available as a dependency
function vout = pat_cfg_vout_extract_tiff(job)
vout = cfg_dep;                     % The dependency object
vout.sname      = 'PAT.mat';       % Displayed dependency name
vout.src_output = substruct('.','PATmat'); %{1}); %,'PATmat');
%substruct('()',{1}); % The output subscript reference. This could be any reference into the output variable created during computation
vout.tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
