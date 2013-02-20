function plot_roi1          = pat_plot_roi_cfg
% Graphical interface configuration function for pat_plot_roi_run
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Choose PAT matrix
PATmat                      = pat_PATmat_cfg(1);
% Force re-do
redo1                       = pat_redo_cfg(false);
% PAT copy/overwrite method
PATmatCopyChoice            = pat_PATmatCopyChoice_cfg('plotROI');
% Choose ROI selection method (all/selected)
ROI_choice                  = pat_roi_choice_cfg;
% Colors to include (HbT, SO2, Bmode)
IC                          = pat_include_colors_cfg(true, true);


% Plot mean signal (from the brain mask pixels)
extractBrainMask            = cfg_menu;
extractBrainMask.tag        = 'extractBrainMask';
extractBrainMask.name       = 'Plot brain mask signal';
extractBrainMask.labels     = {'Yes','No'};
extractBrainMask.values     = {true, false};
extractBrainMask.val        = {true};   % Default value = 0
extractBrainMask.help       = {'Plot signal from the brain pixels'};

% Plot filtered data
plotfiltNdown               = cfg_menu;
plotfiltNdown.tag           = 'plotfiltNdown';
plotfiltNdown.name          = 'Plot Filtered ROIs';
plotfiltNdown.labels        = {'No','Yes'};
plotfiltNdown.values        = {false,true};
plotfiltNdown.val           = {true};
plotfiltNdown.help          = {'Plot filtered signal from the ROIs'}';

% Plot regressed data
plotGLM                     = cfg_menu;
plotGLM.tag                 = 'plotGLM';
plotGLM.name                = 'Plot GLM-regressed ROIs';
plotGLM.labels              = {'No','Yes'};
plotGLM.values              = {false,true};
plotGLM.val                 = {true};
plotGLM.help                = {'Plot GLM-regressed signal from the ROIs'}';

% Generate / save figures
[generate_figures ...
    save_figures]       = pat_generate_figures_cfg;

% ------------------------------------------------------------------------------
% Choose axis limits
% ------------------------------------------------------------------------------
yLimValue                   = cfg_entry;
yLimValue.tag               = 'yLimValue';
yLimValue.name              = 'Y axis limits';
yLimValue.strtype           = 'r';
yLimValue.num               = [1 2];
yLimValue.val               = {[-2000 5000]};
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

% Show standard error bar
stderror                    = cfg_menu;
stderror.tag                = 'stderror';
stderror.name               = 'Std. error bars';
stderror.labels             = {'No','Yes'};
stderror.values             = {false, true};
stderror.val                = {true};
stderror.help               = {'Show standard error bars: sigma/sqrt(N), else show standard deviation: sigma'}';

% Plot colors
figColors                   = cfg_entry;
figColors.tag               = 'figColors';
figColors.name              = 'Plot colors';
figColors.strtype           = 'e';
figColors.num               = [1 Inf];
figColors.val               = {{'r' 'b' 'g' 'k' 'm' 'c' 'y' 'r' 'b' 'g' 'k' 'm' 'c' 'y'}};
figColors.help              = {'Colors used to plot'};

% Line style
figLS                       = cfg_entry;
figLS.tag                   = 'figLS';
figLS.name                  = 'Line Style';
figLS.strtype               = 'e';
figLS.num                   = [1 Inf];
figLS.val                   = {{'-' '-' '-' '-' '-' '-' '-' ':' ':' ':' ':' ':' ':' ':'}};
figLS.help                  = {'Line Style'};

% Figure size
figSize                     = cfg_entry;
figSize.tag                 = 'figSize';
figSize.name                = 'Figure size';
figSize.strtype             = 'r';
figSize.num                 = [1 2];
figSize.val{1}              = [3 1.5];
figSize.help                = {'Enter figure size in inches.'};

% Figure resolution
figRes                      = cfg_entry;
figRes.tag                  = 'figRes';
figRes.name                 = 'Figure resolution';
figRes.strtype              = 'r';
figRes.num                  = [1 1];
figRes.val{1}               = 300;
figRes.help                 = {'Enter figure resolution in dpi [300-1200]'};

% Figure line width
figLW                       = cfg_entry;
figLW.tag                   = 'figLW';
figLW.name                  = 'Line Width';
figLW.strtype               = 'r';
figLW.num                   = [1 1];
figLW.val{1}                = 1.5;
figLW.help                  = {'Enter line width'};

% Figure title font size
titleFontSize               = cfg_entry;
titleFontSize.tag           = 'titleFontSize';
titleFontSize.name          = 'Title Font Size';
titleFontSize.strtype       = 'r';
titleFontSize.num           = [1 1];
titleFontSize.val{1}        = 12;
titleFontSize.help          = {'Enter title font size'};

% Figure axis label font size
axisLabelFontSize           = cfg_entry;
axisLabelFontSize.tag       = 'axisLabelFontSize';
axisLabelFontSize.name      = 'Axis label Font Size';
axisLabelFontSize.strtype   = 'r';
axisLabelFontSize.num       = [1 1];
axisLabelFontSize.val{1}    = 12;
axisLabelFontSize.help      = {'Enter axis labels font size'};

% Figure axis font size
axisFontSize                = cfg_entry;
axisFontSize.tag            = 'axisFontSize';
axisFontSize.name           = 'Axis Font Size';
axisFontSize.strtype        = 'r';
axisFontSize.num            = [1 1];
axisFontSize.val{1}         = 10;
axisFontSize.help           = {'Enter axis font size'};

% ------------------------------------------------------------------------------
% Legends options
% ------------------------------------------------------------------------------
legendLocation              = cfg_entry;
legendLocation.tag          = 'legendLocation';
legendLocation.name         = 'Legend location';
legendLocation.strtype      = 's';
legendLocation.num          = [1 Inf];
legendLocation.val          = {'NorthEastOutside'};
legendLocation.help         = {'Enter legend location'};

legendFontSize              = cfg_entry;
legendFontSize.tag          = 'legendFontSize';
legendFontSize.name         = 'Legend Font Size';
legendFontSize.strtype      = 'r';
legendFontSize.num          = [1 1];
legendFontSize.val          = {12};
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

% Executable Branch
plot_roi1                   = cfg_exbranch;       % This is the branch that has information about how to run this module
plot_roi1.name              = 'Plot ROI/seed';             % The display name
plot_roi1.tag               = 'plot_roi1'; %Very important: tag is used when calling for execution
plot_roi1.val               = {PATmat redo1 PATmatCopyChoice ...
                            ROI_choice IC extractBrainMask  plotfiltNdown...
                            plotGLM generate_figures save_figures yLimits ...
                            stderror  figColors figLS figSize figRes figLW ...
                            titleFontSize axisLabelFontSize axisFontSize legends};    % The items that belong to this branch. All items must be filled before this branch can run or produce virtual outputs
plot_roi1.prog              = @pat_plot_roi_run;  % A function handle that will be called with the harvested job to run the computation
plot_roi1.vout              = @pat_cfg_vout_plot_roi; % A function handle that will be called with the harvested job to determine virtual outputs
plot_roi1.help              = {'Plot the time trace of regions of interest.'};

return

%make PAT.mat available as a dependency
function vout               = pat_cfg_vout_plot_roi(job)
vout                        = cfg_dep;                  % The dependency object
vout.sname                  = 'PAT.mat';                % Displayed dependency name
vout.src_output             = substruct('.','PATmat');  %{1}); %,'PATmat');
vout.tgt_spec               = cfg_findspec({{'filter','mat','strtype','e'}});

% EOF
