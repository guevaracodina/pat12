%% Overlay average functional map over a template
clear; close all; clc
% PAT structure belonging to the image in which the template was based
load('F:\Edgar\Data\PAT_PLoS_ONE\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\PAT.mat')
% Figures folder
figFolder = 'F:\Edgar\Data\PAT_PLoS_ONE\PAT_Results_20130517\alignment\';
% Average image
fName = fullfile(figFolder,'ROI05_SO2_pMap_alpha.nii');
% ROI
r1 = 5;
% Contrast
c1 = 2;
DRAWCIRCLE = false;
% Range of values to map to the full range of colormap: [minVal maxVal]
fcMapRange = [-0.05 0.05];
% Range of values to map to display non-transparent pixels: [minVal maxVal]
alphaRange = [0 .05];
% ------------------------------------------------------------------------------
% Define anonymous functions for affine transformations
% ------------------------------------------------------------------------------
rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
translate = @(a,b) [1 0 a 0; 0 1 b 0; 0 0 1 0; 0 0 0 1];
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Define matlab batch job with the required fields
% ------------------------------------------------------------------------------
job(1).figCmap                                  = jet(256);     % colormap
job(1).figIntensity                             = 0.7;          % [0 - 1]
job(1).transM                                   = rotz(pi);     % affine transform
job(1).figSize                                  = [1.5 1.5];    % inches
job(1).figRes                                   = 300;          % in dpi.
if DRAWCIRCLE
    job(1).drawCircle(1).drawCircle_On(1).circleLW  = 0.8;          % line width
    job(1).drawCircle(1).drawCircle_On(1).circleLS  = '-';          % line style
    job(1).drawCircle(1).drawCircle_On(1).circleEC  = 'w';          % line color
else
    job.drawCircle                              = [];
end
job.parent_results_dir{1}                       = fullfile(figFolder,'overlay');
job.generate_figures                            = true;         % display figure
job.save_figures                                = false;        % save figure
% ------------------------------------------------------------------------------

%% Get directory & Filename
fcColorMap      = job.figCmap;
if ~exist(job.parent_results_dir{1},'dir'),
    mkdir(job.parent_results_dir{1})
end
[pathName, fileName, ext] = fileparts(fName);
currentName = regexp(fileName, '.*(?=(_Mean))', 'match');
if isempty(currentName)
    currentName = {fileName};
end
figName = fullfile(job.parent_results_dir{1} ,[currentName{1} '_avg_overlay']);

%% Seed positions
% Seed annotation dimensions the lower left corner of the bounding rectangle
% at the point seedX, seedY (the + sign here is due to image rotation)
seedX = PAT.res.ROI{r1}.center(2) + PAT.res.ROI{r1}.radius./PAT.PAparam.pixWidth;
seedY = PAT.res.ROI{r1}.center(1) - PAT.res.ROI{r1}.radius./PAT.PAparam.pixDepth;
% Seed width
seedW = 2*PAT.res.ROI{r1}.radius./PAT.PAparam.pixWidth;
% Seed height
seedH = 2*PAT.res.ROI{r1}.radius./PAT.PAparam.pixDepth;
% Seed dimensions
seedDims = [seedX seedY  seedW seedH];
%% Read image files
% Get anatomical image
anatVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_PLoS_ONE\PAT_Results_20130517\alignment\',...
    'normalization_AVG_scale.nii'));
anatomical          = spm_read_vols(anatVol);

% Read brain mask
maskVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_PLoS_ONE\PAT_Results_20130517\alignment','brain_mask.nii'));
brainMask           = logical(spm_read_vols(maskVol));

% Get functional image
fcMapVol            = spm_vol(fName);

if all(fcMapVol.dt == [64 0])
    fcMap               = spm_read_vols(fcMapVol);
else
    % Sum +1 only if data are not float64
    fcMap               = 1 + spm_read_vols(fcMapVol);
end

%% Overlay blend
% [fcMapBlend hFig] = pat_overlay_blend(anatomical, fcMap, brainMask, fcMapRange, ...
%     alphaRange, fcColorMap, job.figIntensity);
[fcMapBlend hFig] = pat_overlay_blend(anatomical, fcMap);

%% Generate/Print figures
if job.generate_figures
    set(gca,'DataAspectRatio',[1 PAT.PAparam.pixWidth/PAT.PAparam.pixDepth 1])
   
    % Specify window units
    set(hFig, 'units', 'inches')
    % Change figure and paper size
    set(hFig, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
    set(hFig, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
    
    % Seed positions and sizes will be shown with black circles
    if isfield(job.drawCircle,'drawCircle_On')
        figure(hFig);
        % Display ROI
        rectangle('Position',seedDims,...
            'Curvature',[1,1],...
            'LineWidth',job.drawCircle.drawCircle_On.circleLW,...
            'LineStyle',job.drawCircle.drawCircle_On.circleLS,...
            'EdgeColor',job.drawCircle.drawCircle_On.circleEC);
    end
    
    if job.save_figures
        % Save as PNG at the user-defined resolution
        print(hFig, '-dpng', ...
            figName,...
            sprintf('-r%d',job.figRes));
        % Return the property to its default
        set(hFig, 'units', 'pixels')
        close(hFig)
    end
    colorNames = fieldnames(PAT.color);
    % Spatial extension % defined as displayed to brain pixels ratio.
    % spatial_extension = nnz(pixelMask) / nnz(brainMask);
    % displayed_pixels = fcMap(pixelMask);
    % total_pixels = nnz(brainMask);
    % fprintf('Overlay blend done! File: %s, R%02d, (%s) %0.2f%% brain pixels displayed.\n',...
    %     fName, r1, colorNames{c1},100*spatial_extension);
end

% EOF
