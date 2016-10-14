function Combined = pat_get_SO2(baseDir, baseFilename)
% close all; clear all; clc;
%#ok<*UNRCH> Unreachable code

% baseDir = 'D:\Edgar\PAT_test_data';
% baseFilename{1} = 'Air-750nm';
% baseFilename{2} = 'Air-850nm';

bBMode = false;
bPAMode = false;
bCombined = true;
writeGIF = false;

%% Read data
% Wavelengths used
lambda = [750; 850];

% Create cells to store BMode data
numFiles = length(baseFilename);
if (bBMode)
    BMode = cell(1, numFiles);
    FrameOrder_BMode = cell(1, numFiles);
    FrameEcgPer_BMode = cell(1, numFiles);
end

% Create cells to store PAMode data
if (bPAMode)
    PAMode = cell(1, numFiles);
    FrameOrder_PAMode = cell(1, numFiles);
    FrameEcgPer_PAMode = cell(1, numFiles);
end

for fileIdx = 1:numFiles
    % Get Physio and Event Data
    Physio = VsiReadPhysio(baseDir, baseFilename{fileIdx});
    Event  = VsiReadEvent(baseDir, baseFilename{fileIdx});
    
    % Get timestamps of B-Mode Data
    if (bBMode || bCombined)
        BMode{fileIdx} = VsiReadBModeRaw(baseDir, baseFilename{fileIdx}, -1, ...
            '.bmode', 'TimestampOnly', true);
        if (isempty(BMode))
            error('Failed to load B-Mode data');
        end
    end
    
    % Get timestamps of PA-Mode Data
    if (bPAMode || bCombined)
        PAMode{fileIdx} = VsiReadPAModeRaw(baseDir, baseFilename{fileIdx}, -1, ...
            '.pamode', 'TimestampOnly', true);
        if (isempty(PAMode))
            error('Failed to load PA-Mode data');
        end
    end
    
    % Get clock frequency
    xDoc = xmlread([baseDir '/' baseFilename{fileIdx} '.raw.xml']);
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
        ImageTime.BMode = BMode{fileIdx}.Timestamp(:) / 1000;
    end
    
    if (bPAMode || bCombined)
        ImageTime.PAMode = PAMode{fileIdx}.Timestamp(:) / 1000;
    end
    
    ECG_Peak = Event.ECG / 1000;
    Resp_Peak = Event.Resp / 1000;
    
    clear yLim i j physioClock timeStampClock h_Physio amplitude
    
    % For each frame figure out the position in the cardiac cycle
    if (bBMode || bCombined)
        [FrameOrder_BMode{fileIdx}, FrameEcgPer_BMode{fileIdx}] = ...
            VsiEkvOrderFrames(ImageTime.BMode, ECG_Peak, Resp_Peak, Resp, PhysioTime);
    end
    
    if (bPAMode || bCombined)
        [FrameOrder_PAMode{fileIdx}, FrameEcgPer_PAMode{fileIdx}] = ...
            VsiEkvOrderFrames(ImageTime.PAMode, ECG_Peak, Resp_Peak, Resp, PhysioTime);
    end
end

% Match PA datasets (wavelength 1 and 2)
if (bCombined)
    [FrameOrder_PAMode{1}, FrameEcgPer_PAMode{1}, ...
        FrameOrder_PAMode{2}, FrameEcgPer_PAMode{2}] = ...
        VsiEkvMatchFrames(FrameOrder_PAMode{1}, FrameEcgPer_PAMode{1}, ...
        FrameOrder_PAMode{2}, FrameEcgPer_PAMode{2});
end

% Load required PA-Mode Data
for fileIdx = 1:numFiles
    if (bPAMode || bCombined)
        PAMode{fileIdx} = VsiReadPAModeRaw(baseDir, baseFilename{fileIdx}, ...
            unique(FrameOrder_PAMode{fileIdx}), ...
            '.pamode', 'TimestampOnly', false);
        if (isempty(PAMode{fileIdx}))
            error('Failed to load PA-Mode data');
        end
        
        % Remap PAMode frames
        for i = 1:numel(PAMode{fileIdx}.FrameNum)
            FrameOrder_PAMode{fileIdx}(FrameOrder_PAMode{fileIdx} == PAMode{fileIdx}.FrameNum(i)) = i;
        end
    end
end

% Find minimum number of frames
numFrames = min([length(FrameOrder_PAMode{1}), length(FrameOrder_PAMode{2})...
    length(FrameOrder_BMode{1}), length(FrameOrder_BMode{2}) ]);

% Calculate SO2 data
[SO2] = GenerateSO2(lambda, PAMode, FrameOrder_PAMode, numFrames);

% Match BMode to PAMode
if (bCombined)
    [FrameOrder_PAMode{1}, FrameEcgPer_PAMode{1}, ...
        FrameOrder_BMode{1}, FrameEcgPer_BMode{1}] = ...
        VsiEkvMatchFrames(FrameOrder_PAMode{1}, FrameEcgPer_PAMode{1}, ...
        FrameOrder_BMode{1}, FrameEcgPer_BMode{1});
end

% Load required BMode data
if (bBMode || bCombined)
    BMode{1} = VsiReadBModeRaw(baseDir, baseFilename{1}, unique(FrameOrder_BMode{1}), ...
        '.bmode', 'TimestampOnly', false);
    if (isempty(BMode{1}))
        error('Failed to load B-Mode data');
    end
    
    % Remap BMode frames
    for i = 1:numel(BMode{1}.FrameNum)
        FrameOrder_BMode{1}(FrameOrder_BMode{1} == BMode{1}.FrameNum(i)) = i;
    end
end

if (bCombined)
    % Combine B-Mode and PA-Mode
    clear Combined
    Combined.Width = BMode{1}.Width;
    Combined.Depth = BMode{1}.Depth;
    
    SO2Img = zeros(size(BMode{1}.Data{1}));
    
    so2Map = [zeros(1,64) linspace(0, 1, 192); ...
        zeros(1,256); ...
        linspace(1, 0, 256)]';
    
    [X_b, Y_b] = meshgrid(BMode{1}.Width, BMode{1}.Depth);
    [X_pa, Y_pa] = meshgrid(SO2.Width, SO2.Depth);
    for i = 1:numFrames
        F = TriScatteredInterp(X_pa(:), Y_pa(:), SO2.Data{i}(:));
        
        SO2ImgTmp = F(X_b,Y_b);
        SO2ImgTmp(SO2ImgTmp < 0) = 0;
        SO2ImgTmp(SO2ImgTmp > 1) = 1;
        %         SO2ImgTmp = SO2ImgTmp + 1;
        SO2Img = SO2ImgTmp;
        
        threshold = 1.0;
        Combined.Data{i} = BMode{1}.Data{FrameOrder_BMode{1}(i)} / ...
            max(BMode{1}.Data{FrameOrder_BMode{1}(i)}(:));
        
        Combined.Data{i}(SO2Img > threshold) = SO2Img(SO2Img > threshold);
        
        % Include full data //EGC
        Combined.Bmode{i} = BMode{1}.Data{FrameOrder_BMode{1}(i)};
        Combined.SO2{i} = SO2Img;
        
        Combined.cmap = [gray(128) ; so2Map(1:2:end,:)];
        
        if writeGIF
            % Create gif
            imagesc(Combined.Width, Combined.Depth, Combined.Data{i}, [0 2]);
            colormap(Combined.cmap)
            drawnow;
            
            frame = getframe;
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
            if i == 1;
                imwrite(imind, cm, fullfile(baseDir, [baseFilename{1} '_so2' '.gif']), 'gif', ...
                    'DelayTime', 0.03, 'Loopcount', inf);
            else
                imwrite(imind, cm, fullfile(baseDir, [baseFilename{1} '_so2' '.gif']), 'gif', ...
                    'DelayTime', 0.03, 'WriteMode', 'append');
            end
        end
    end
end

%% reshape cells into arrays [nX nY nT]
Combined.Bmode = reshape(cell2mat(Combined.Bmode), [numel(Combined.Depth) numel(Combined.Width) numFrames]);
Combined.SO2 = reshape(cell2mat(Combined.SO2), [numel(Combined.Depth) numel(Combined.Width) numFrames]);
Combined.Data = reshape(cell2mat(Combined.Data), [numel(Combined.Depth) numel(Combined.Width) numFrames]);

% EOF
