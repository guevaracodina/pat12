%% script_so2_map - Now computes grand average of both sO2 and HbT
clear all; clc
% color to plot (1=HbT, 2=SO2)
c1 = 1;
% Sham or LPS
isSham = true;
%% PAT matrices
% Control group
job.PATmatCtrl = {  
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };

% LPS group
job.PATmatLPS = {
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\ROIcc\PAT.mat'
                };
%% Read nifti files
for iSubject = 1:numel(job.PATmatCtrl)
    if isSham
        load(job.PATmatCtrl{iSubject})
    else
        load(job.PATmatLPS{iSubject})
    end
    % load('F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\PAT.mat');
    input_dir = PAT.input_dir;
    % c1= 2 for SO2
    nifti_filename = PAT.nifti_files{c1};
    if c1 == 2
        output_dir = fullfile(PAT.output_dir,'so2_map');
    else
        output_dir = fullfile(PAT.output_dir,'hbt_map');
    end
    if ~exist(output_dir,'dir'),mkdir(output_dir); end
    % Functional map
    v = spm_vol(nifti_filename);
    I = spm_read_vols(v);
    % Brain mask
    v = spm_vol(PAT.fcPAT.mask.fname);
    brainMask = spm_read_vols(v);
    % Anatomical brainMask
    v = spm_vol(PAT.res.file_anat);
    anatomical = spm_read_vols(v);
    % Convert to SO2 data
    if c1 == 2
        I = pat_raw2so2(I);
    end
    % load scrubbing info
    % load scrubbing parameters
    load(PAT.motion_parameters.scrub.fname)
    % Scrub images
    Iscrub = I(:,:,1,scrubMask{c1});
    % Average images
    Imean = mean(Iscrub,4);
    % Needs realignment!!! // EGC
    fcMapAll(:,:,iSubject) = Imean;
end
fcMap = mean(fcMapAll,3);

%% Display options
if c1 == 2
    % Range of values to map to the full range of colormap: [minVal maxVal]
    fcMapRange      = [20 60];
    % Range of values to map to display non-transparent pixels: [minVal maxVal]
    alphaRange      = [0 60];
else
    % Range of values to map to the full range of colormap: [minVal maxVal]
    fcMapRange      = [2000 45000];
    % Range of values to map to display non-transparent pixels: [minVal maxVal]
    alphaRange      = [0 45000];   
end
% ------------------------------------------------------------------------------
% Define anonymous functions for affine transformations
% ------------------------------------------------------------------------------
rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
translate = @(a,b) [1 0 a 0; 0 1 b 0; 0 0 1 0; 0 0 0 1];
% ------------------------------------------------------------------------------

figFolder = output_dir;
% ------------------------------------------------------------------------------
% Define matlab batch job with the required fields
% ------------------------------------------------------------------------------
job(1).figCmap                                  = pat_get_colormap('flow');     % colormap
job(1).figIntensity                             = 0.7;          % [0 - 1] anatomical
job(1).transM                                   = rotz(pi);     % affine transform
job(1).figSize                                  = [3 3];    % inches
job(1).figRes                                   = 300;          % in dpi.
job.parent_results_dir{1}                       = fullfile(figFolder,'overlay');
job.generate_figures                            = true;         % display figure
job.save_figures                                = false;        % save figure
% ------------------------------------------------------------------------------
fcColorMap                                      = job(1).figCmap;
nColorLevels                                    = 256;
if ~exist(job.parent_results_dir{1},'dir'),mkdir(job.parent_results_dir{1}); end
if isSham && c1 == 2
    figName = fullfile(job.parent_results_dir{1} ,'sham_sO2_avg_overlay');
elseif isSham && c1 == 1
    figName = fullfile(job.parent_results_dir{1} ,'sham_hbt_avg_overlay');
elseif ~isSham && c1 == 2
    figName = fullfile(job.parent_results_dir{1} ,'lps_sO2_avg_overlay');
else
    figName = fullfile(job.parent_results_dir{1} ,'lps_hbt_avg_overlay');
end
    

%% Convert anatomical image to grayscale (weighted by job.figIntensity)
anatomicalGray      = job.figIntensity .* mat2gray(anatomical);
anatomicalGray      = repmat(anatomicalGray,[1 1 3]);
% Convert functional image to RGB
fcMapGray           = mat2gray(fcMap, fcMapRange); % Fix range for correlation maps
fcMapIdx            = gray2ind(fcMapGray, nColorLevels);
fcMapRGB            = ind2rgb(fcMapIdx, fcColorMap);
% Set transparency according to mask and pixels range
pixelMask = false(size(brainMask));
if numel(alphaRange) == 2,
    pixelMask(fcMap > alphaRange(1) & fcMap < alphaRange(2)) = true;
elseif numel(alphaRange) == 4,
    pixelMask(fcMap > alphaRange(1) & fcMap < alphaRange(2)) = true;
    pixelMask(fcMap > alphaRange(3) & fcMap < alphaRange(4)) = true;
end
fcMapRGB(repmat(~brainMask | ~pixelMask,[1 1 3])) = 0.5;
% Apply overlay blend algorithm
fcMapBlend = 1 - 2.*(1 - anatomicalGray).*(1 - fcMapRGB);
fcMapBlend(anatomicalGray<0.5) = 2.*anatomicalGray(anatomicalGray<0.5).*fcMapRGB(anatomicalGray<0.5);

%% Generate/Print figures
if job.generate_figures
    close all
    h = figure;
    h = imshow(fcMapBlend, 'InitialMagnification', 'fit', 'border', 'tight');
    set(gca,'DataAspectRatio',[1 PAT.PAparam.pixWidth/PAT.PAparam.pixDepth 1])
    hFig = gcf;
    set(hFig, 'color', 'k')
    % Allow printing of black background
    set(hFig, 'InvertHardcopy', 'off');
    % Specify window units
    set(hFig, 'units', 'inches')
    % Change figure and paper size
    set(hFig, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
    set(hFig, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
    if job.save_figures
        % Save as PNG at the user-defined resolution
        print(hFig, '-dpng', ...
            figName,...
            sprintf('-r%d',job.figRes));
        % Return the property to its default
        set(hFig, 'units', 'pixels')
        close(hFig)
    end
end

%% Figure for colorbar
% display limits (in SO2 %) 
dispLimits = fcMapRange;
% SO2 threshold
so2threshold = 0;
% Brain brainMask
Ithreshold = Imean;
Ithreshold(~logical(brainMask) | (Ithreshold<so2threshold)) = nan;

if job.generate_figures
    h = figure;
    % Black background
    set(h,'color','k')
    % whitebg('k')
    colormap(fcColorMap)
    % Allow printing of black background
    set(h, 'InvertHardcopy', 'off');
    % Axis limits (mm)
    xLimits = PAT.PAparam.WidthAxis([1,end]);
    % xLimits = [2.3 10.8];
    yLimits = PAT.PAparam.DepthAxis([1,end]);
    
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, Ithreshold,dispLimits);
    axis image
    hbar = colorbar;
    set(hbar,'YTick',dispLimits,'YColor','w','FontSize',12,'FontWeight','bold')
    set(hbar,'nextplot','replacechildren');
    set(gca,'YColor','w','XColor','w','FontSize',12,'TickDir','out',...
        'FontWeight','bold','XTick',xLimits,'YTick',yLimits)
    xlabel('Width (mm)','FontSize',12,'Color','w','FontWeight','bold')
    ylabel('Depth (mm)','FontSize',12,'Color','w','FontWeight','bold')
    if job.save_figures
        % Save as PNG at the user-defined resolution
        print(h, '-dpng', ...
            fullfile(job.parent_results_dir{1} ,'sO2_avg_colorbar'),...
            sprintf('-r%d',job.figRes));
        % Return the property to its default
        set(hFig, 'units', 'pixels')
        close(hFig)
    end
end
% EOF
