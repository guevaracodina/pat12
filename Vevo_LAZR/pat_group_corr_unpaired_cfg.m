function group_corr2        = pat_group_corr_unpaired_cfg
% Graphical interface configuration function for pat_group_corr_unpaired_run
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Select PAT.mat (2 files minimum)
PATmatCtrl                  = pat_PATmat_cfg(2,'PATmatCtrl','Ctrl group','Select PAT.mat list of controls');
PATmatLPS                   = pat_PATmat_cfg(2,'PATmatLPS','LPS group','Select PAT.mat list of LPS');
% Force processing
redo1                       = pat_redo_cfg(0);
% PAT copy/overwrite method
PATmatCopyChoice            = pat_PATmatCopyChoice_cfg('group_corr');
% Colors to include (OD,HbO,HbR,HbT,Flow)
IC                          = pat_include_colors_cfg(1,1);

% ------------------------------------------------------------------------------
% ID groups
% ------------------------------------------------------------------------------
% Regressor names
ID                          = cfg_entry;
ID.tag                      = 'ID';
ID.name                     = 'Group names';
ID.strtype                  = 'e';
ID.num                      = [1 Inf];
ID.val{1}                   = {'Ctrl','LPS'};
ID.help                     = {'Specify the cell string with group names. Default ID is {''Ctrl'',''LPS'';}'}';
% ------------------------------------------------------------------------------

% Paired seeds
paired_seeds                = cfg_entry;
paired_seeds.name           = 'Paired seeds';       % The displayed name
paired_seeds.tag            = 'paired_seeds';       % file names
paired_seeds.strtype        = 'r';                  % Real numbers
paired_seeds.num            = [Inf 2];              % Number of inputs required
paired_seeds.val            = {[(1:2:18)', (2:2:18)']}; % Default value
paired_seeds.help           = { 'Choose the pairs of seeds to compare. Usually:' 
                                ' 1, 2: (Cg)    Cingulate cortex'
                                ' 3, 4: (M)     Motor cortex'
                                ' 5, 6: (S1HL)  hindlimb primary somatosensory cortex'
                                ' 7, 8: (S1FL)  forelimb primary somatosensory cortex'
                                ' 9,10: (S1BF)  barrel field primary somatosensory cortex'
                                '11,12: (S2)    secondary somatosensory cortex'
                                '13,14: (cc)    corpus callosum'
                                '15,16: (LV)    Lateral ventricle'
                                '17,18: (CPu)   Caudate putamen'
                                };
                            
% Select directory to save global results
parent_results_dir          = cfg_files;
parent_results_dir.tag      = 'parent_results_dir';
parent_results_dir.name     = 'Top directory to save group results';
parent_results_dir.filter   = 'dir';
parent_results_dir.num      = [1 1];
parent_results_dir.help     = {'Select the directory where consolidated results will be saved.'}';

% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Statistical test options
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Unpaired t-test
ttest1                      = cfg_menu;
ttest1.tag                  = 'ttest1';
ttest1.name                 = 't-test';
ttest1.labels               = {'No','Yes'};
ttest1.values               = {false, true};
ttest1.val                  = {true};
ttest1.help                 = {'Perform an unpaired (2 sample) t-test'}';

% Wilcoxon rank sum test
wilcoxon1                   = cfg_menu;
wilcoxon1.tag               = 'wilcoxon1';
wilcoxon1.name              = 'Wilcoxon test';
wilcoxon1.labels            = {'No','Yes'};
wilcoxon1.values            = {false, true};
wilcoxon1.val               = {true};
wilcoxon1.help              = {'Perform a Wilcoxon rank sum test'}';

% alpha significance level
alpha                       = cfg_entry;
alpha.name                  = 'alpha';              % The displayed name
alpha.tag                   = 'alpha';              % file names
alpha.strtype               = 'r';                  % Real numbers
alpha.num                   = [1 1];                % Number of inputs required
alpha.val                   = {0.05};               % Default value
alpha.help                  = {'Performs the test at the significance level (100*alpha)%.' 
    'alpha must be a scalar'};

% Multiple comparisons correction None / Bonferroni / FDR
multComp                    = cfg_menu;
multComp.tag                = 'multComp';
multComp.name               = 'Multiple comparisons';
multComp.labels             = {'None', 'Bonferroni', 'FDR'};
multComp.values             = {0, 1, 2};
multComp.val                = {2};                      % Default value
multComp.help               = { 'Choose whether to perform multiple testing correction:'
                                'None'
                                'Bonferroni'
                                'False Discovery Rate (FDR)'}';
% ------------------------------------------------------------------------------
% Remove outliers
% ------------------------------------------------------------------------------
stdDevVal                   = cfg_entry;
stdDevVal.tag               = 'stdDevVal';
stdDevVal.name              = 'Std. Dev.';
stdDevVal.strtype           = 'r';
stdDevVal.num               = [1 1];
stdDevVal.val               = {3};
stdDevVal.help              = {'Enter limits is standard deviations away from the mean.'};

remOutOn                    = cfg_branch;
remOutOn.tag                = 'remOutOn';
remOutOn.name               = 'Yes';
remOutOn.val                = {stdDevVal};
remOutOn.help               = {'Remove outliers'};

remOutOff                   = cfg_branch;
remOutOff.tag               = 'remOutOff';
remOutOff.name              = 'No';
remOutOff.val               = {};
remOutOff.help              = {'Do not remove outliers'};

remOutlier                  = cfg_choice;
remOutlier.tag              = 'remOutlier';
remOutlier.name             = 'Remove outliers';
remOutlier.values           = {remOutOn remOutOff};
remOutlier.val              = {remOutOff};
remOutlier.help             = {'Choose whether to remove outliers. An outlier is defined as a value that is more than N standard deviations away from the mean'};
% ------------------------------------------------------------------------------

% Correlation on 1st derivative
derivative                  = cfg_menu;
derivative.tag              = 'derivative';
derivative.name             = '1st derivative';
derivative.labels           = {'No', 'Yes'};
derivative.values           = {false, true};
derivative.val              = {false};                      % Default value
derivative.help             = {'Choose whether to perform correlation analysis on 1st derivative of seeds/pixels time-course'}';

% Correlation on raw data time course (before filtering, downsampling and GLM regression)
rawData                     = cfg_menu;
rawData.tag                 = 'rawData';
rawData.name                = 'Raw time course';
rawData.labels              = {'No', 'Yes'};
rawData.values              = {false, true};
rawData.val                 = {false};                      % Default value
rawData.help                = {'Choose whether to perform correlation analysis on seeds raw time course'}';
% ------------------------------------------------------------------------------
optStat                     = cfg_branch;
optStat.tag                 = 'optStat';
optStat.name                = 'Statistical test options';
optStat.val                 = {ttest1 wilcoxon1  alpha multComp remOutlier derivative rawData};
optStat.help                = {'Options for 2nd-level analysis. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% Generate / save figures
[generate_figures ...
    save_figures]           = pat_generate_figures_cfg;
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Print figure options
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------
% Figure size
figSize                     = cfg_entry;
figSize.tag                 = 'figSize';
figSize.name                = 'Figure size';
figSize.strtype             = 'r';
figSize.num                 = [1 2];
figSize.val                 = {[3.25 3.25]};
figSize.help                = {'Enter figure size in inches [Width Height].'};

% Figure resolution
figRes                      = cfg_entry;
figRes.tag                  = 'figRes';
figRes.name                 = 'Figure resolution';
figRes.strtype              = 'r';
figRes.num                  = [1 1];
figRes.val                  = {300};
figRes.help                 = {'Enter figure resolution in dpi [150-1200]'};

% Show standard error bar
stderror                    = cfg_menu;
stderror.tag                = 'stderror';
stderror.name               = 'Std. error bars';
stderror.labels             = {'No','Yes'};
stderror.values             = {false, true};
stderror.val                = {true};
stderror.help               = {'Choose to show whether standard error bars [sigma/sqrt(N)] or standard deviation bars [sigma]'}';

% ------------------------------------------------------------------------------
% Choose axis limits
% ------------------------------------------------------------------------------
yLimValue                   = cfg_entry;
yLimValue.tag               = 'yLimValue';
yLimValue.name              = 'Y axis limits';
yLimValue.strtype           = 'r';
yLimValue.num               = [1 2];
yLimValue.val               = {[-1 1.5]};
yLimValue.help              = {'Enter limits for Y axis'};

yLimManual                  = cfg_branch;
yLimManual.tag              = 'yLimManual';
yLimManual.name             = 'Manual Ylim';
yLimManual.val              = {yLimValue};
yLimManual.help             = {'Manual limits for Y axis.'};

yLimAuto                    = cfg_branch;
yLimAuto.tag                = 'yLimAuto';
yLimAuto.name               = 'Auto Ylim';
yLimAuto.val                = {};
yLimAuto.help               = {'Auto limits for Y axis.'};

yLimits                     = cfg_choice;
yLimits.tag                 = 'yLimits';
yLimits.name                = 'Y axis limits';
yLimits.values              = {yLimManual yLimAuto};
yLimits.val                 = {yLimAuto};
yLimits.help                = {'Choose whether to set manual limits to Y axis'};
% ------------------------------------------------------------------------------

% X-axis labels
xAxisLabels                 = cfg_entry;
xAxisLabels.tag             = 'xAxisLabels';
xAxisLabels.name            = 'X-Tick labels';
xAxisLabels.strtype         = 'e';
xAxisLabels.num             = [1 Inf];
xAxisLabels.val             = {{'Cg'      % Cingulate cortex
                                'M'       % Motor cortex
                                'S1HL'    % hindlimb primary somatosensory cortex
                                'S1FL'    % forelimb primary somatosensory cortex
                                'S1BF'    % barrel field primary somatosensory cortex
                                'S2'      % secondary somatosensory cortex
                                'cc'      % corpus callosum
                                'LV'      % Lateral ventricle
                                'CPu'}'};  % Caudate putamen
                    
xAxisLabels.help            = {'Enter X-Tick label. Default: {''Cg'', ''M'', ''S1HL'', ''S1FL'', ''S1BF'', ''S2'', ''cc'', ''LV'', ''CPu''}'};

% X-axis font size
xLabelFontSize              = cfg_entry;
xLabelFontSize.tag          = 'xLabelFontSize';
xLabelFontSize.name         = 'X-tick label font size';
xLabelFontSize.strtype      = 'r';
xLabelFontSize.num          = [1 1];
xLabelFontSize.val          = {10};
xLabelFontSize.help         = {'Enter X-tick label font size'};

% Y-axis font size
yLabelFontSize              = cfg_entry;
yLabelFontSize.tag          = 'yLabelFontSize';
yLabelFontSize.name         = 'Y axis label font size';
yLabelFontSize.strtype      = 'r';
yLabelFontSize.num          = [1 1];
yLabelFontSize.val          = {10};
yLabelFontSize.help         = {'Enter Y axis label font size'};

% Title font size
titleFontSize              = cfg_entry;
titleFontSize.tag          = 'titleFontSize';
titleFontSize.name         = 'Title font size';
titleFontSize.strtype      = 'r';
titleFontSize.num          = [1 1];
titleFontSize.val          = {10};
titleFontSize.help         = {'Enter title font size'};

% ------------------------------------------------------------------------------
% Legends options
% ------------------------------------------------------------------------------
% legendStr                   = cfg_entry;
% legendStr.tag               = 'legendStr';
% legendStr.name              = 'Legend string';
% legendStr.strtype           = 'e';
% legendStr.num               = [1 2];
% legendStr.val               = {{'Ctrl' 'LPS'}};
% legendStr.help              = {'Enter legends. Default: {''Ctrl'' ''LPS''}'};

legendLocation              = cfg_entry;
legendLocation.tag          = 'legendLocation';
legendLocation.name         = 'Legend location';
legendLocation.strtype      = 's';
legendLocation.num          = [1 Inf];
legendLocation.val          = {'NorthEast'};
legendLocation.help         = {'Enter legend location'};

legendFontSize              = cfg_entry;
legendFontSize.tag          = 'legendFontSize';
legendFontSize.name         = 'Legend Font Size';
legendFontSize.strtype      = 'r';
legendFontSize.num          = [1 1];
legendFontSize.val          = {10};
legendFontSize.help         = {'Enter legend font size'};

legendShow                  = cfg_branch;
legendShow.tag              = 'legendShow';
legendShow.name             = 'Show legend';
legendShow.val              = {legendLocation legendFontSize};
legendShow.help             = {'Show legends.'};

legendHide                  = cfg_branch;
legendHide.tag              = 'legendHide';
legendHide.name             = 'Hide legend';
legendHide.val              = {};
legendHide.help             = {'Hide legends.'};

legends                     = cfg_choice;
legends.tag                 = 'legends';
legends.name                = 'Legends options';
legends.values              = {legendShow legendHide};
legends.val                 = {legendHide};
legends.help                = {'Choose whether to show legends or not'};
% ------------------------------------------------------------------------------
optFig                      = cfg_branch;
optFig.tag                  = 'optFig';
optFig.name                 = 'Print figure options';
optFig.val                  = {stderror figSize figRes yLimits xAxisLabels xLabelFontSize yLabelFontSize titleFontSize legends};
optFig.help                 = {'Print figure options. If in doubt, simply keep the default values.'}';
% ------------------------------------------------------------------------------
% ------------------------------------------------------------------------------

% Executable Branch
group_corr2                 = cfg_exbranch; % This is the branch that has information about how to run this module
group_corr2.name            = 'Bilateral correlation group comparison (unpaired)'; % The display name
group_corr2.tag             = 'group_corr2'; %Very important: tag is used when calling for execution
group_corr2.val             = {PATmatCtrl PATmatLPS redo1 PATmatCopyChoice IC ID paired_seeds...
    parent_results_dir optStat generate_figures save_figures optFig};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
% bonferroni ttest1 wilcoxon1 alpha derivative rawData remOutlier
% stderror figSize figRes yLimits xAxisLabels xLabelFontSize yLabelFontSize titleFontSize legends
group_corr2.prog            = @pat_group_corr_unpaired_run; % A function handle that will be called with the harvested job to run the computation
group_corr2.vout            = @pat_cfg_vout_group_corr_unpaired; % A function handle that will be called with the harvested job to determine virtual outputs
group_corr2.help            = {'Gets the correlation between each seed and its contralateral homologue. Then performs a non-paired t-test for each seed set, to have a group comparison.'}';

return

% Make PAT.mat available as a dependency
function vout               = pat_cfg_vout_group_corr_unpaired(job)
vout                        = cfg_dep;                  % The dependency object
vout.sname                  = 'PAT.mat';                % Displayed dependency name
vout.src_output             = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec               = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
