function network1 = pat_network_analyses_cfg
% Graphical interface configuration function for pat_network_analyses_run
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Select PAT.mat list of control group
PATmat1                 = pat_PATmat_cfg(2,'Select PAT.mat list of controls');
% Select PAT.mat list of LPS group
PATmat2                 = pat_PATmat_cfg(2,'Select PAT.mat list of LPS');
% Select PAT.mat list of LPS group
PATmat3                 = pat_PATmat_cfg(2,'Select PAT.mat list of LPS + IL-1Ra');

% Force processing
redo1                   = pat_redo_cfg(0);
% IOI copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('network');
% Choose ROI selection method (all/selected)
ROI_choice              = pat_roi_choice_cfg;
% Colors to include (OD,HbO,HbR,HbT,Flow)
IC                      = pat_include_colors_cfg(1,1);

% Select directory to save global results
results_dir             = cfg_files;
results_dir.tag         = 'results_dir';
results_dir.name        = 'Top directory to save group results';
results_dir.filter      = 'dir';
results_dir.ufilter     = '.*';
results_dir.num         = [1 1];
results_dir.help        = {'Select the directory where figures will be saved.'}';

% ------------------------------------------------------------------------------
% 1st-level analysis Options
% ------------------------------------------------------------------------------
% Measures Type
measures                = cfg_menu;
measures.tag            = 'measures';
measures.name           = 'Measures';
measures.labels         = {'Efficiency/cost', 'PathDistance/Clustering'};
measures.values         = {1, 2};
measures.val            = {1};
measures.help           = {'Choose whether to perform'
                            '   1: Efficiency/cost measures.'
                            '   2: PathDistance/Clustering measures.'}';

% Normalization Type
normalType           	= cfg_menu;
normalType.tag          = 'normalType';
normalType.name         = 'Normalization';
normalType.labels       = {'Raw', 'Z-scores', 'Cost'};
normalType.values       = {0, 1, 2};
normalType.val          = {2};                  % Default value
normalType.help         = { 'Choose normalization type: '
                            '0: Uses raw (Fisher-transformed) correlation coefficients;'
                            '1: Normalizes across subjects (transform to z-scores)'
                            '2: Uses Cost'}';
% Threshold
threshold              	= cfg_entry;
threshold.tag           = 'threshold';         	% file names
threshold.name          = 'Threshold';          % The displayed name
threshold.strtype       = 'r';                  % Real numbers
threshold.num           = [0 1];                % Number of inputs required
threshold.val           = {0.3};                % Default value
threshold.help          = {'Threshold value to compute adjacency matrix. If zero, small-world properties are plotted and user is asked to enter a value for each color.'};

% 1st-level analysis options
opt1stLvl               = cfg_branch;
opt1stLvl.tag           = 'opt1stLvl';
opt1stLvl.name          = '1st level options';
opt1stLvl.val           = {measures normalType threshold};
opt1stLvl.help          = {'Various 1st level analysis options. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% 2nd-level analysis Options
% ------------------------------------------------------------------------------
% model
model                   = cfg_menu;
model.tag               = 'model';
model.name              = 'Statistical test';
model.labels            = {'One-sample t-test', 'Two-sample t-test', 'Multiple regression'};
model.values            = {0, 1, 2};
model.val               = {2};                  % Default value: unpaired t-test
model.help              = { 'Select statistical test:'
                            '1: One-sample t-test' 
                            '2: Two-sample t-test' 
                            '3: Multiple regression'}';
                        
% Regressor names
Xname                   = cfg_entry;
Xname.tag               = 'Xname';
Xname.name              = 'Regressor names';
Xname.strtype           = 'e';
Xname.num               = [1 Inf];
Xname.val{1}            = {'Ctrl','LPS','LPS+IL-1Ra';};
Xname.help              = {'Specify the cell string with regressor names. Default Xname is {''NaCl'',''CaCl_2'';}'}';

% Contrast
C                       = cfg_entry;
C.tag                   = 'C';
C.name                  = 'Contrast';
C.strtype               = 'r';
C.num                   = [2 3];
C.val{1}                = [1, -1, 0; 0, 1, -1];
C.help                  = { 'Specify the contrast vector/matrix. Default C is [1, -1, 0; 0, 1, -1],'
                            'invariance test i.e. those areas where the connectivity with a seed differs between some or all of the 3 groups.'}';

% Contrast name
Cname                   = cfg_entry;
Cname.tag               = 'Cname';
Cname.name              = 'Contrast Name';
Cname.strtype           = 's';
Cname.num               = [1 Inf];
Cname.val{1}            = 'Invariance';
Cname.help              = {'Specify the contrast name. Default Cname is {''Control - Treatment'';}'}';

% Ask options
ask                     = cfg_menu;
ask.tag                 = 'ask';
ask.name                = 'Ask for options';
ask.labels              = {'none', 'missing', 'all'};
ask.values              = {'none', 'missing', 'all'};
ask.val                 = {'missing'};                  % Default value
ask.help                = { 'Ask for options. Default setting will ask for any missing options'
                            'none' 
                            'missing' 
                            'all'}';
% 2nd-level analysis options
opt2ndLvl               = cfg_branch;
opt2ndLvl.tag           = 'opt2ndLvl';
opt2ndLvl.name          = '2nd level options';
opt2ndLvl.val           = {model Xname C Cname ask};
opt2ndLvl.help          = {'Various 2nd level analysis options. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% ------------------------------------------------------------------------------
% Print figure Options
% ------------------------------------------------------------------------------
% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [13 7];
figSize.help            = {'Enter figure size in inches [Width Height].'};

% Figure resolution
figRes                  = cfg_entry;
figRes.tag              = 'figRes';
figRes.name             = 'Figure resolution';
figRes.strtype          = 'r';
figRes.num              = [1 1];
figRes.val{1}           = 150;
figRes.help             = {'Enter figure resolution in dpi. Suggested [150-1200]'};

optFig                  = cfg_branch;
optFig.tag              = 'optFig';
optFig.name             = 'Print figure options';
optFig.val              = {figSize figRes};
optFig.help             = {'Print figure options. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Seed positions and sizes will be shown with black circles.
% ------------------------------------------------------------------------------
rThreshold              = cfg_entry;
rThreshold.tag          = 'rThreshold';
rThreshold.name         = '|r| threshold';
rThreshold.val          = {0.3};
rThreshold.strtype      = 'r';
rThreshold.num          = [1 1];
rThreshold.help         = {'Pearson''s coefficient |r| threshold. Only edges with higher absolute connectivity will be displayed.'};

circleLW                = cfg_entry;
circleLW.tag            = 'circleLW';
circleLW.name           = 'Seed LineWidth';
circleLW.val            = {0.8};
circleLW.strtype        = 'r';
circleLW.num            = [1 1];
circleLW.help           = {'Seed Line Width'};

circleLS                = cfg_entry;
circleLS.tag            = 'circleLS';
circleLS.name           = 'Seed LineStyle';
circleLS.val            = {'-'};
circleLS.strtype        = 's';
circleLS.num            = [1 2];
circleLS.help           = {'Seed Line Style'};

circleFC                = cfg_entry;
circleFC.tag            = 'circleFC';
circleFC.name           = 'Seed FaceColor';
circleFC.val            = {'w'};
circleFC.strtype        = 'e';
circleFC.num            = [1 Inf];
circleFC.help           = {'Seed Face Color'};

circleEC                = cfg_entry;
circleEC.tag            = 'circleEC';
circleEC.name           = 'Seed EdgeColor';
circleEC.val            = {'k'};
circleEC.strtype        = 'e';
circleEC.num            = [1 Inf];
circleEC.help           = {'Seed Edge Color'};

cirleMaxRad             = cfg_entry;
cirleMaxRad.tag         = 'cirleMaxRad';
cirleMaxRad.name        = 'Max. Seed Radius';
cirleMaxRad.val         = {18};
cirleMaxRad.strtype     = 'r';
cirleMaxRad.num         = [1 1];
cirleMaxRad.help        = {'Maximum Seed Radius'};

edgeMaxThick            = cfg_entry;
edgeMaxThick.tag        = 'edgeMaxThick';
edgeMaxThick.name       = 'Edge Max. Thickness';
edgeMaxThick.val        = {10};
edgeMaxThick.strtype    = 'r';
edgeMaxThick.num        = [1 1];
edgeMaxThick.help       = {'Maximum edge thickness'};

fc_diagram              = cfg_branch;
fc_diagram.tag          = 'fc_diagram';
fc_diagram.name         = 'fc diagram';
fc_diagram.val          = {rThreshold circleLW circleLS circleFC circleEC cirleMaxRad edgeMaxThick};
fc_diagram.help         = {'Functional connectivity diagram options. Edge thicknesses depend on the average correlation coefficients from the 2 groups. Circle sizes are proportional to global efficiency of each seed. Positive correlations are depicted in warm colors. Negative correlations are depicted in cool colors. The letter in the circle indicates name of the seeds.'};
% ------------------------------------------------------------------------------


% Executable Branch
network1                = cfg_exbranch; % This is the branch that has information about how to run this module
network1.name           = 'Network analyses'; % The display name
network1.tag            = 'network1'; %Very important: tag is used when calling for execution
network1.val            = {PATmat1 PATmat2 PATmat3 redo1 PATmatCopyChoice...
    ROI_choice IC results_dir opt1stLvl opt2ndLvl ...
    generate_figures save_figures fc_diagram  optFig};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
network1.prog           = @pat_network_analyses_run; % A function handle that will be called with the harvested job to run the computation
network1.vout           = @pat_cfg_vout_network_analyses; % A function handle that will be called with the harvested job to determine virtual outputs
network1.help           = { 'Network analyses. Presents several graph theoretical measures.' 
                            'These measures reflect the level of global integration in the network and are generated by averaging seed-level measures across all nodes of the network.' 
                            'These summary network-level measures are then entered in a second-level general linear model to compare functional connectivity patterns between the groups.'
                            'Needs CONN – fMRI functional connectivity toolbox (v.13)'
                            'Gabrieli Lab. McGovern Institute for Brain Research'
                            'Massachusetts Institute of Technology'
                            'http://www.nitrc.org/projects/conn'
                            'Susan Whitfield-Gabrieli'
                            'Alfonso Nieto-Castanon'}';
return

% Make PAT.mat available as a dependency
function vout = pat_cfg_vout_network_analyses(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
