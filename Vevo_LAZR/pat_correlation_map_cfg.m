function correlation_map1 = pat_correlation_map_cfg
% Graphical interface configuration function for pat_correlation_map_run
% A functional connectivity (fcIOS) map is made by correlating the seed/ROI with
% all other brain (non-masked) pixels
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Anonymous functions used later. They can be evaluated in transM
rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
translate = @(a,b) [1 0 a 0; 0 1 b 0; 0 0 1 0; 0 0 0 1];

% Default choice to draw a circle to indicate seed position and size
draw_circle_def_on      = true;

% Choose PAT matrix
PATmat                  = pat_PATmat_cfg(1);
% Force re-do
redo1                   = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice        = pat_PATmatCopyChoice_cfg('corrMap');
% Choose ROI selection method (all/selected)
ROI_choice              = pat_roi_choice_cfg;
% Colors to include (HbT, SO2, Bmode)
IC                      = pat_include_colors_cfg(true, true);

% Use scrubbing
scrubbing              = cfg_menu;
scrubbing.tag          = 'scrubbing';
scrubbing.name         = 'Scrubbing';
scrubbing.labels       = {'No','Yes'};
scrubbing.values       = {false, true};
scrubbing.val          = {true};
scrubbing.help         = {'Use scrubbing to remove artifacts before correlation computation'}';

% p-Values
pValue                  = cfg_entry;
pValue.tag              = 'pValue';                 % file names
pValue.name             = 'p-value';                % The displayed name
pValue.strtype          = 'r';                      % Real numbers
pValue.num              = [1 1];                    % Number of inputs required
pValue.val              = {0.05};                   % Default value
pValue.help             = {'p-value for testing the hypothesis of no correlation against the alternative that there is a nonzero correlation. If p-value is small, say less than 0.05, then the correlation r is significantly different from zero.'};


% Multiple comparisons correction
multComp                = cfg_menu;
multComp.tag            = 'multComp';
multComp.name           = 'Multiple comparisons';
multComp.labels         = {'None', 'Bonferroni', 'FDR'};
multComp.values         = {0, 1, 2};
multComp.val            = {2};                      % Default value
multComp.help           = { 'Choose whether to perform multiple testing correction:'
                            'None'
                            'Bonferroni'
                            'False Discovery Rate (FDR)'}';
                        
% Fisher's z transform
fisherZ                 = cfg_menu;
fisherZ.tag             = 'fisherZ';
fisherZ.name            = 'Fisher''s z transform';
fisherZ.labels          = {'No', 'Yes'};
fisherZ.values          = {false, true};
fisherZ.val             = {false};                      % Default value
fisherZ.help            = {'Choose whether to perform a Fisher''s z transform of correlation coefficients. The correlation coefficient need to be transformed to the normal distribution by Fisher''s z transform before performing the random effect t-tests'}';

% Seeds correlation matrix
seed2seedCorrMat        = cfg_menu;
seed2seedCorrMat.tag    = 'seed2seedCorrMat';
seed2seedCorrMat.name   = 'seed2seedCorrMat';
seed2seedCorrMat.labels = {'No', 'Yes'};
seed2seedCorrMat.values = {false, true};
seed2seedCorrMat.val    = {true};                      % Default value
seed2seedCorrMat.help   = {'Choose whether to compute a seed-to-seed correlation matrix'}';

% Correlation on 1st derivative
derivative              = cfg_menu;
derivative.tag          = 'derivative';
derivative.name         = '1st derivative';
derivative.labels       = {'No', 'Yes'};
derivative.values       = {false, true};
derivative.val          = {false};                      % Default value
derivative.help         = {'Choose whether to perform correlation analysis on 1st derivative of seeds/pixels time-course'}';

% Correlation on raw data time course (before filtering, downsampling and GLM regression)
rawData                 = cfg_menu;
rawData.tag             = 'rawData';
rawData.name            = 'raw time course';
rawData.labels          = {'No', 'Yes'};
rawData.values          = {false, true};
rawData.val             = {false};                      % Default value
rawData.help            = {'Choose whether to perform correlation analysis on seeds raw time course'}';

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% Figure size
figSize                 = cfg_entry;
figSize.tag             = 'figSize';
figSize.name            = 'Figure size';
figSize.strtype         = 'r';
figSize.num             = [1 2];
figSize.val{1}          = [1 1];
figSize.help            = {'Enter figure size in inches.'};

% Figure resolution
figRes                  = cfg_entry;
figRes.tag              = 'figRes';
figRes.name             = 'Figure resolution';
figRes.strtype          = 'r';
figRes.num              = [1 1];
figRes.val{1}           = 300;
figRes.help             = {'Enter figure resolution in dpi [300-1200]'};

% Colormap range
figRange                = cfg_entry;
figRange.tag            = 'figRange';
figRange.name           = 'Colormap range';
figRange.strtype        = 'r';
figRange.num            = [1 2];
figRange.val{1}         = [-1 1];
figRange.help           = {'Enter colormap range to display. For correlation maps default is [-1 1]'};

% Show Colorbar
showColorbar            = cfg_menu;
showColorbar.tag        = 'showColorbar';
showColorbar.name       = 'Show Colorbar';
showColorbar.labels     = {'No', 'Yes'};
showColorbar.values     = {false, true};
showColorbar.val        = {false};                      % Default value
showColorbar.help       = {'Show colorbar'}';

% Alpha transparency values
figAlpha                = cfg_entry;
figAlpha.tag            = 'figAlpha';
figAlpha.name           = 'Transparency';
figAlpha.strtype        = 'r';
figAlpha.num            = [1 1];
figAlpha.val{1}         = 0.8;
figAlpha.help           = {'Enter colormap transparency, between 0 and 1'};

% Intensity for the anatomical background
figIntensity            = cfg_entry;
figIntensity.tag        = 'figIntensity';
figIntensity.name       = 'Intensity';
figIntensity.strtype    = 'r';
figIntensity.num        = [1 1];
figIntensity.val{1}     = 0.5;
figIntensity.help       = {'Enter background (anatomical) intensity, between 0 and 1'};

% Colormap to use
figCmap                 = cfg_entry;
figCmap.tag             = 'figCmap';
figCmap.name            = 'Colormap';
figCmap.strtype         = 'e';
figCmap.num             = [Inf 3];
figCmap.val{1}          = jet(256);
figCmap.help            = {'Enter colormap to use. e.g. type jet(256), Input is evaluated'};

% ------------------------------------------------------------------------------
% Seed positions and sizes will be shown with black circles.
% ------------------------------------------------------------------------------
circleLW                = cfg_entry;
circleLW.tag            = 'circleLW';
circleLW.name           = 'Circle LineWidth';
circleLW.val            = {0.8};
circleLW.strtype        = 'r';
circleLW.num            = [1 1];
circleLW.help           = {'Circle Line Width'};

circleLS                = cfg_entry;
circleLS.tag            = 'circleLS';
circleLS.name           = 'Circle LineStyle';
circleLS.val            = {'-'};
circleLS.strtype        = 's';
circleLS.num            = [1 2];
circleLS.help           = {'Circle Line Style'};

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
circleEC.val            = {'w'};
circleEC.strtype        = 'e';
circleEC.num            = [1 Inf];
circleEC.help           = {'Seed Edge Color'};

drawCircle_On           = cfg_branch;
drawCircle_On.tag       = 'drawCircle_On';
drawCircle_On.name      = 'Draw circle';
drawCircle_On.val       = {circleLW circleLS circleFC circleEC};
drawCircle_On.help      = {'Draw a circle in seed position'};

drawCircle_Off          = cfg_branch;
drawCircle_Off.tag      = 'drawCircle_Off';
drawCircle_Off.name     = 'Draw nothing';
drawCircle_Off.val      = {};
drawCircle_Off.help     = {'Draw nothing'};

drawCircle              = cfg_choice;
drawCircle.tag          = 'drawCircle';
drawCircle.name         = 'Draw circle in seed';
drawCircle.values       = {drawCircle_On drawCircle_Off};
if draw_circle_def_on
    drawCircle.val      = {drawCircle_On};
else
    drawCircle.val      = {drawCircle_Off};
end
drawCircle.help         = {'Seed positions and sizes will be shown with black circles.'};
% ------------------------------------------------------------------------------

% transM Reorientation Matrix
transM                  = cfg_entry;
transM.tag              = 'transM';
transM.name             = 'Reorientation Matrix';
transM.strtype          = 'e';
transM.val{1}           = translate(0,0);
transM.num              = [4 4];
transM.help             = {
                        'Enter a valid 4x4 matrix for reorientation.'
                        ''
                        'Example:'
                        'This will rotate the images to have rostral orientation up.'
                        ''
                        'rotz(pi)'
                        ''
                        'rotx(theta), roty(theta) and translate(a,b) can also be evaluated'
                        }';

% Executable Branch
correlation_map1        = cfg_exbranch; % This is the branch that has information about how to run this module
correlation_map1.name   = 'Functional connectivity (fcPAT) map'; % The display name
correlation_map1.tag    = 'correlation_map1'; %Very important: tag is used when calling for execution
correlation_map1.val	= { PATmat redo1 PATmatCopyChoice ROI_choice IC scrubbing...
                            pValue multComp fisherZ seed2seedCorrMat derivative ...
                            rawData generate_figures save_figures figSize figRes ...
                            figRange showColorbar figAlpha figIntensity figCmap ...
                            drawCircle transM};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
correlation_map1.prog	= @pat_correlation_map_run; % A function handle that will be called with the harvested job to run the computation
correlation_map1.vout	= @pat_cfg_vout_correlation_map; % A function handle that will be called with the harvested job to determine virtual outputs
correlation_map1.help	= {'A functional connectivity (fcIOS) map is made by correlating the seed/ROI with all other brain (non-masked) pixels'}';
return

% Make IOI.mat available as a dependency
function vout           = pat_cfg_vout_correlation_map(job)
vout                    = cfg_dep;                  % The dependency object
vout.sname              = 'PAT.mat';                % Displayed dependency name
vout.src_output         = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec           = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
