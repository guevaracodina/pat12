clear all; close all; clc;

baseDir = 'C:\Users\cwarre\Desktop\code to send\test data';
baseFilename = 'Air-750nm';

bBMode = false;
bPAMode = false;
bCombined = true;

% Get Physio and Event Data
Physio = VsiReadPhysio(baseDir, baseFilename);
Event  = VsiReadEvent(baseDir, baseFilename);

% Get timestamps of B-Mode Data
if (bBMode || bCombined)
    BMode = VsiReadBModeRaw(baseDir, baseFilename, -1, ...
        '.bmode', 'TimestampOnly', true);
    if (isempty(BMode))
        error('Failed to load B-Mode data');
    end
end

% Get timestamps of PA-Mode Data
if (bPAMode || bCombined)
    PAMode = VsiReadPAModeRaw(baseDir, baseFilename, -1, ...
        '.pamode', 'TimestampOnly', true);
    if (isempty(PAMode))
        error('Failed to load PA-Mode data');
    end
end

% Get clock frequency
xDoc = xmlread([baseDir '/' baseFilename '.raw.xml']);
AllParameters = xDoc.getElementsByTagName('parameter');
for k = 0:AllParameters.getLength-1
    node = AllParameters.item(k);
    if (strcmp(char(node.getAttribute('name')), 'Physio-Clock'))
        javaNsamples = node.getAttribute('value');
        physioClock = str2double(char(javaNsamples));
        break;
    end
end
clear AllParameters javaNsamples node xDoc k

if (~exist('physioClock', 'var'))
    error('Failed to get the parameter: Physio-Clock');
end

% Combine ECG and Respiration signals and get time axis
numFrame = length(Physio.ECG);
numFrameEl = length(Physio.ECG{1});
numEl = numFrame * numFrameEl; % Use first frame as representative size

iStartIdx = 1;
physioFactor = 1000 / physioClock;

ECG = zeros(1, numEl);
Resp = zeros(1, numEl);
PhysioTime = zeros(1, numEl);
for i = 1:numFrame
    iRange = iStartIdx:(iStartIdx + numFrameEl - 1);
    
    ECG(iRange) = Physio.ECG{i};
    Resp(iRange) = Physio.Resp{i};
    PhysioTime(iRange) = ...
        (Physio.Timestamp(i):physioFactor:(Physio.Timestamp(i) + (numFrameEl - 1)*physioFactor))/1000;
    
    iStartIdx = iStartIdx + numFrameEl;
end

clear iRange iStartIdx numEl numFrame numFrameEl i physioFactor

if (bBMode || bCombined)
    ImageTime.BMode = BMode.Timestamp(:) / 1000;
end

if (bPAMode || bCombined)
    ImageTime.PAMode = PAMode.Timestamp(:) / 1000;
end

ECG_Peak = Event.ECG / 1000;
Resp_Peak = Event.Resp / 1000;

clear yLim i j physioClock timeStampClock h_Physio amplitude

% For each frame figure out the position in the cardiac cycle
if (bBMode || bCombined)
    [FrameOrder_BMode, FrameEcgPer_BMode] = ...
        VsiEkvOrderFrames(ImageTime.BMode, ECG_Peak, Resp_Peak, Resp, PhysioTime);
end

if (bPAMode || bCombined)
    [FrameOrder_PAMode, FrameEcgPer_PAMode] = ...
        VsiEkvOrderFrames(ImageTime.PAMode, ECG_Peak, Resp_Peak, Resp, PhysioTime);
end

% Match BMode to PAMode
if (bCombined)
    [FrameOrder_BMode, FrameEcgPer_BMode, ...
        FrameOrder_PAMode, FrameEcgPer_PAMode] = ...
        VsiEkvMatchFrames(FrameOrder_BMode, FrameEcgPer_BMode, ...
        FrameOrder_PAMode, FrameEcgPer_PAMode);
end

% Load required B data
if (bBMode || bCombined)
    BMode = VsiReadBModeRaw(baseDir, baseFilename, unique(FrameOrder_BMode), ...
        '.bmode', 'TimestampOnly', false);
    if (isempty(BMode))
        error('Failed to load B-Mode data');
    end
    
    % Remap BMode frames
    for i = 1:numel(BMode.FrameNum)
        FrameOrder_BMode(FrameOrder_BMode == BMode.FrameNum(i)) = i;
    end
end

% Get PA-Mode Data
if (bPAMode || bCombined)
    PAMode = VsiReadPAModeRaw(baseDir, baseFilename, unique(FrameOrder_PAMode), ...
        '.pamode', 'TimestampOnly', false);
    if (isempty(PAMode))
        error('Failed to load PA-Mode data');
    end
    
    % Remap PAMode frames
    for i = 1:numel(PAMode.FrameNum)
        FrameOrder_PAMode(FrameOrder_PAMode == PAMode.FrameNum(i)) = i;
    end
end

% Create Gif
if (bBMode)
    minDb = 0;
    maxDb = 255;
    VsiCreateEkvGif(BMode, FrameOrder_BMode, [baseFilename '_bmode'], ...
        gray(128), [minDb maxDb], false, true);
end

if (bPAMode)
    minDb = 44;
    maxDb = 70;
    VsiCreateEkvGif(PAMode, FrameOrder_PAMode, [baseFilename '_pamode'], ...
        hot(128), [minDb maxDb], true, true);
end

% Combine B-Mode and PA-Mode
% Start with naive approach (assume frames are already temporally aligned)

Combined.Width = BMode.Width;
Combined.Depth = BMode.Depth;

PAImg = zeros(size(BMode.Data{1}));
minDb = 44;
maxDb = 70;

[X_b, Y_b] = meshgrid(BMode.Width, BMode.Depth);
[X_pa, Y_pa] = meshgrid(PAMode.Width, PAMode.Depth);
numFrames = min([length(FrameOrder_BMode), length(FrameOrder_PAMode)]);
for i = 1:numFrames
    F = TriScatteredInterp(X_pa(:), Y_pa(:), PAMode.Data{FrameOrder_PAMode(i)}(:));
    
    PAImgTmp = 20*log10(F(X_b,Y_b));
    PAImgTmp = (PAImgTmp - minDb) / (maxDb - minDb);
    PAImgTmp(PAImgTmp < 0) = 0;
    PAImgTmp(PAImgTmp > 1) = 1;
    PAImgTmp = PAImgTmp + 1;
    PAImg = PAImgTmp;
    
    threshold = 1.01;
    Combined.Data{i} = BMode.Data{FrameOrder_BMode(i)} / ...
        max(BMode.Data{FrameOrder_BMode(i)}(:));
    Combined.Data{i}(PAImg > threshold) = PAImg(PAImg > threshold);
    
    imagesc(Combined.Width, Combined.Depth, Combined.Data{i}, [0 2]);
    colormap([gray(128) ; hot(128)])
    
    drawnow;
    
    frame = getframe;
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if i == 1;
        imwrite(imind, cm, [baseFilename '_co' '.gif'], 'gif', ...
            'DelayTime', 0.03, 'Loopcount', inf);
    else
        imwrite(imind, cm, [baseFilename '_co' '.gif'], 'gif', ...
            'DelayTime', 0.03, 'WriteMode', 'append');
    end
end

