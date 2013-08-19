%% Overlay average functional map over a template
clc
% PAT structure belonging to the image in which the template was based
load('F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\corrMap\PAT.mat')
nColorLevels = 256;
% Figures folder
% figFolder = 'F:\Edgar\Data\PAT_Results_20130517\alignment\SO2\Ctrl';
% figFolder = 'F:\Edgar\Data\PAT_Results_20130517\alignment\SO2\LPS';
figFolder = 'F:\Edgar\Data\PAT_Results_20130517\alignment\';
% Average image
% fName = fullfile(figFolder,'ROI05_Mean.img');
fName = fullfile(figFolder,'ROI05_SO2_pMap_alpha_FDR.nii');
% ROI
r1 = 5;
% Contrast
c1 = 2;
DRAWCIRCLE = false;
% Range of values to map to the full range of colormap: [minVal maxVal]
fcMapRange = [0 0.05];
% Range of values to map to display non-transparent pixels: [minVal maxVal]
alphaRange = [0 0.05];
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
job(1).figCmap                                  = hot(256);     % colormap
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
job.save_figures                                = true;        % save figure
% ------------------------------------------------------------------------------

%% Overlay blend
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

%% Read files
% Get anatomical image
anatVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment\',...
    'normalization_AVG_scale.nii'));
anatomical          = spm_read_vols(anatVol);


% Read brain mask
maskVol             = spm_vol(fullfile('F:\Edgar\Data\PAT_Results_20130517\alignment','brain_mask.nii'));
brainMask           = logical(spm_read_vols(maskVol));

% Get functional image
fcMapVol            = spm_vol(fName);

if all(fcMapVol.dt == [64 0])
    fcMap               = spm_read_vols(fcMapVol);
else
    % Sum +1 only if data are not float64
    fcMap               = 1 + spm_read_vols(fcMapVol);
end

% Orient images
% anatomical          = fliplr(anatomical');
% fcMap               = fliplr(fcMap');
% brainMask           = fliplr(brainMask');
% seedDims = [size(fcMap,2) - seedY seedX seedW seedH];
seedDims = [seedX seedY  seedW seedH];

%% If values are empty display min/max
if isempty(fcMapRange)
    fcMapRange = [min(fcMap(:)) max(fcMap(:))];
    fprintf('fcMapRange = [%0.4f %0.4f]\n', fcMapRange(1), fcMapRange(2));
end
if isempty(alphaRange) || (numel(alphaRange) ~= 2 && numel(alphaRange) ~= 4)
    alphaRange = [min(fcMap(:)) max(fcMap(:))];
    fprintf('alphaRange = [%0.4f %0.4f]\n', alphaRange(1), alphaRange(2));
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
% Spatial extension % defined as displayed to brain pixels ratio.
spatial_extension = nnz(pixelMask) / nnz(brainMask);
displayed_pixels = fcMap(pixelMask);
total_pixels = nnz(brainMask);

%% Apply overlay blend algorithm
fcMapBlend = 1 - 2.*(1 - anatomicalGray).*(1 - fcMapRGB);
fcMapBlend(anatomicalGray<0.5) = 2.*anatomicalGray(anatomicalGray<0.5).*fcMapRGB(anatomicalGray<0.5);

%% Generate/Print figures
if job.generate_figures
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
%     if isempty(c1)
%         c1 = str2double(regexp(fcMapFile, '(?<=(C))(\d+)(?=(_))','match'));
%     else
%         c1 = c1-1;
%     end
    fprintf('Overlay blend done! File: %s, R%02d, (%s) %0.2f%% brain pixels displayed.\n',...
        fName, r1, colorNames{c1},100*spatial_extension);
end

% EOF
