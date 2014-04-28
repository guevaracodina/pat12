%% script_so2_map - Now computes grand average sO2
clear all; clc
% Only sO2 (c1=2)
c1 = 2;
% Choose control (true) or LPS (false)
isSham = false;
% Folder with figures
figFolder = 'F:\Edgar\Dropbox\PhD\PAT\PLoS ONE\Average_Maps';
% Read average maps
v = spm_vol(fullfile(figFolder, 'SO2_LPS.img'));
fcMapLPS_All = spm_read_vols(v);
v = spm_vol(fullfile(figFolder, 'SO2_NaCl.img'));
fcMapCtrl_All = spm_read_vols(v);
% Brain mask
v = spm_vol(fullfile(figFolder, 'brain_mask.nii'));
brainMask = spm_read_vols(v);
% Anatomical image
anatVol = spm_vol(fullfile(figFolder, 'normalization_AVG_scale.nii'));
anatomical = spm_read_vols(anatVol);

%% Compute average
fcMapLPS = median(fcMapLPS_All,3);
fcMapCtrl = median(fcMapCtrl_All,3);
% Convert to %
% fcMapLPS = 1000*pat_raw2so2(fcMapLPS);
% fcMapCtrl = 1000*pat_raw2so2(fcMapCtrl);

%% Display options
if isSham
    fcMap = fcMapLPS;
else
    fcMap = fcMapCtrl;
end
% Range of values to map to the full range of colormap: [minVal maxVal]
fcMapRange      = [30 60];
% Range of values to map to display non-transparent pixels: [minVal maxVal]
alphaRange      = [30 60];
% ------------------------------------------------------------------------------
% Define anonymous functions for affine transformations
% ------------------------------------------------------------------------------
rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
translate = @(a,b) [1 0 a 0; 0 1 b 0; 0 0 1 0; 0 0 0 1];
% ------------------------------------------------------------------------------
% Define matlab batch job with the required fields
% ------------------------------------------------------------------------------
job(1).figCmap                                  = pat_get_colormap('linlhot');     % colormap
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
%     load('F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\PAT.mat');
    load(fullfile(figFolder, 'PAT.mat'));
    h = figure;
    set(h,'Name',figName)
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
        % Save as a figure
        saveas(hFig, figName, 'fig');
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
Ithreshold = fcMap;
Ithreshold(~logical(brainMask) | (Ithreshold<so2threshold)) = nan;

if job.generate_figures
    h = figure;
    % Black background
    set(h,'color','k')
    set(h,'Name',figName)
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
            fullfile([figName '_colorbar']),...
            sprintf('-r%d',job.figRes));
        % Save as a figure
        saveas(h, fullfile([figName '_colorbar']), 'fig');
        % Return the property to its default
        set(hFig, 'units', 'pixels')
        close(hFig)
    end
end

%% Statistical test
%% Mask out non-brain elements
fcMapCtrl_All(~repmat(brainMask,[1 1 size(fcMapCtrl_All,3)])) =  nan;
fcMapLPS_All(~repmat(brainMask,[1 1 size(fcMapLPS_All,3)])) =  nan;

%% Fisher's transform
% zctrl = pat_fisherz(fcMapCtrl_All);
% zLPS = pat_fisherz(fcMapCtrl_All);
zctrl = (fcMapCtrl_All);
zLPS = (fcMapLPS_All);


%% standardization by mean & std
meanctrl = nanmean(zctrl(:));
stdctrl = nanstd(zctrl(:));

meanLPS = nanmean(zLPS(:));
stdLPS = nanstd(zLPS(:));

zctrl = (zctrl - meanctrl) ./ stdctrl;
zLPS = (zLPS - meanLPS) ./ stdLPS;

%% t-test statistics across the scans
hMap = zeros([size(zLPS,1) size(zLPS,2)]);
pMap = zeros([size(zLPS,1) size(zLPS,2)]);
alphaVal = 0.05;
pat_text_waitbar(0, 'Please wait...');
for iRows = 1:size(zLPS,1)
    for iCols = 1:size(zLPS,2)
        [hMap(iRows, iCols) pMap(iRows, iCols)] = ttest2(squeeze(zctrl(iRows, iCols, :)), squeeze(zLPS(iRows, iCols, :)), alphaVal, 'both', 'unequal');
    end
    pat_text_waitbar(iRows/size(zLPS,1), sprintf('Processing t-test %d from %d', iRows, size(zLPS,1)));
end
pat_text_waitbar('Clear');

%% FDR-correction
pMapFDR = pat_fdr(pMap(:));
pMapFDR = reshape(pMapFDR, size(pMap));

%% Apply threshold
pMapAlpha = nan(size(pMap));
pMapFDRalpha = pMapAlpha;
pMapAlpha(pMap <= alphaVal) = pMap(pMap <= alphaVal);
pMapFDRalpha(pMapFDR <= alphaVal) = pMapFDR(pMapFDR <= alphaVal);

%% Display p-maps
if job.generate_figures
    figure; imagesc(-log(pMapAlpha)); title('uncorrected p-values'); colorbar
    figure; imagesc(-log(pMapFDRalpha)); title('FDR adjusted p-values'); colorbar
    if job.save_figures
        hdr = pat_create_vol(fullfile(figFolder,...
            'SO2_pMap_alpha.nii'), anatVol.dim, [64 0], anatVol.pinfo, anatVol.mat, 1, pMapAlpha);
        hdr = pat_create_vol(fullfile(figFolder,...
            'SO2_pMap_alpha_FDR.nii'), anatVol.dim, [64 0], anatVol.pinfo, anatVol.mat, 1, pMapFDRalpha);
    end
end
% EOF
