function scrubbing1 = pat_scrubbing_cfg
% Graphical interface configuration function for pat_scrubbing_run
% We create a temporal mask, which specifies frames to ignore when performing
% calculations upon the data
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________


% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('scrub');
% Colors to include (HbT, SO2, Bmode)
IC                      = pat_include_colors_cfg(true, true);

% Select directory to save global results
parent_results_dir      = cfg_files;
parent_results_dir.tag  = 'parent_results_dir';
parent_results_dir.name = 'Top directory to save group results';
parent_results_dir.filter= 'dir';
parent_results_dir.num  = [1 1];
parent_results_dir.help = {'Select the directory where consolidated results will be saved.'}';

CSVfname                = cfg_entry;
CSVfname.name           = 'CSV filename';
CSVfname.tag            = 'CSVfname';
CSVfname.strtype        = 's';
CSVfname.num            = [1 Inf];
CSVfname.val            = {'scrubbing.csv'};
CSVfname.help           = {'.CSV file name'}';

% Frames augmented backwards in mask
frameAugmBack           = cfg_entry;
frameAugmBack.name      = 'BW frames';
frameAugmBack.tag       = 'frameAugmBack';
frameAugmBack.strtype   = 'r';
frameAugmBack.num       = [1 1];
frameAugmBack.val       = {1};
frameAugmBack.help      = {'Augmented backward frames'}';

% Frames augmented forwards in mask
frameAugmFwd            = cfg_entry;
frameAugmFwd.name       = 'FW frames';
frameAugmFwd.tag        = 'frameAugmFwd';
frameAugmFwd.strtype    = 'r';
frameAugmFwd.num        = [1 1];
frameAugmFwd.val        = {2};
frameAugmFwd.help       = {'Augmented forward frames'}';

% FD threshold
FDthreshold             = cfg_entry;
FDthreshold.name        = 'FD threshold';
FDthreshold.tag         = 'FDthreshold';
FDthreshold.strtype     = 'r';
FDthreshold.num         = [1 1];
FDthreshold.val         = {0.0008};
FDthreshold.help        = { 'Framewise displacement (FD) threshold.'
                            ' FD is a scalar quantity expressing instantaneous head motion'}';

% DVARS threshold
DVARSthreshold          = cfg_entry;
DVARSthreshold.name     = 'DVARS threshold';
DVARSthreshold.tag      = 'DVARSthreshold';
DVARSthreshold.strtype  = 'r';
DVARSthreshold.num      = [1 Inf];
DVARSthreshold.val      = {[1200 3000 0]}; % [HbT SO2 Bmode]
DVARSthreshold.help     = { 'DVARS threshold'
                        	'(D referring to temporal derivative of timecourses, VARS referring to RMS variance over voxels) is a measure of how much the intensity of a brain image changes in comparison to the previous timepoint.'}';

% Intersection of both masks is a more conservative approach
intersection            = cfg_menu;
intersection.tag        = 'intersection';
intersection.name       = 'FD & DVARS';
intersection.labels     = {'No','Yes'};
intersection.values     = {false,true};
intersection.val        = {true};
intersection.help       = {'Choose conservatively to use an intersection of the two temporal masks to generate a final temporalmask. If false, the disjunction of both masks is performed'}';

% Average P3 rat pup head radius (mm)
skulltop2base           = 6.425; % mm
biparietalDiameter      = 9.785; % mm

radius                  = cfg_entry;
radius.name             = 'radius';
radius.tag              = 'radius';
radius.strtype          = 'r';
radius.num              = [1 1];
radius.val              = {mean([skulltop2base biparietalDiameter])/2};
radius.help             = { 'Average P3 rat pup head radius (mm)'
                            'Rotational displacements are converted from degrees to millimeters by calculating displacement on the surface of a sphere of radius 4 mm, which is approximately the mean distance from the cerebral cortex to the center of the head in P3 rat pups'}';

percentKeep            	= cfg_entry;
percentKeep.name        = 'Min. percentage';
percentKeep.tag         = 'percentKeep';
percentKeep.strtype     = 'r';
percentKeep.num         = [1 1];
percentKeep.val         = {80};
percentKeep.help        = {'Minimum percentage (1%-100%) of data that must remain after scrubbing'}';

scrub_options           = cfg_branch;
scrub_options.tag       = 'scrub_options';
scrub_options.name      = 'Scrubbing options';
scrub_options.val       = { frameAugmBack frameAugmFwd FDthreshold ...
                            DVARSthreshold intersection radius percentKeep};
scrub_options.help      = {'Scrubbing prameters'};
% ------------------------------------------------------------------------------                        

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [4 6];
figSize.help            = {'Enter figure size in inches.'};

% Figure resolution
figRes                  = cfg_entry;
figRes.tag              = 'figRes';
figRes.name             = 'Figure resolution';
figRes.strtype          = 'r';
figRes.num              = [1 1];
figRes.val{1}           = 300;
figRes.help             = {'Enter figure resolution in dpi [300-1200]'};

% Colormap to use
figCmap                 = cfg_entry;
figCmap.tag             = 'figCmap';
figCmap.name            = 'Colormap';
figCmap.strtype         = 'e';
figCmap.num             = [Inf 3];
figCmap.val{1}          = flipud(gray(2));
figCmap.help            = {'Enter colormap to use. e.g. type jet(256), Input is evaluated'};
% ------------------------------------------------------------------------------

% Executable Branch
scrubbing1              = cfg_exbranch; % This is the branch that has information about how to run this module
scrubbing1.name         = 'Scrubbing'; % The display name
scrubbing1.tag          = 'scrubbing1'; %Very important: tag is used when calling for execution
scrubbing1.val          = { PATmat redo1 PATmatCopyChoice  IC  parent_results_dir ...
                            CSVfname scrub_options...
                            generate_figures save_figures figSize figRes figCmap ...
                            };    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
scrubbing1.prog         = @pat_scrubbing_run; % A function handle that will be called with the harvested job to run the computation
scrubbing1.vout         = @pat_cfg_vout_scrubbing; % A function handle that will be called with the harvested job to determine virtual outputs
scrubbing1.help         = {'Scrubbing is defined as the creation of a temporal mask, which specifies frames to ignore when performing calculations upon the data'}';
return

% Make IOI.mat available as a dependency
function vout           = pat_cfg_vout_scrubbing(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
