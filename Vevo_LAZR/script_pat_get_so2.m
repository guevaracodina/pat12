%% script_pat_get_so2
clear; close all; clc;

% baseDir = 'D:\Edgar\PAT_test_data';
% baseFilename{1, 1} = 'Air-750nm'; % Filename at 750nm
% baseFilename{1, 2} = 'Air-850nm'; % Filename at 850nm

baseDir = 'D:\Edgar\PAT_Data';
baseFilename{1, 1} = 'CD-4 pre PA750_2015-10-21-19-55-09'; % Filename at 750nm
baseFilename{1, 2} = 'CD-4 pre PA850_2015-10-21-19-50-45'; % Filename at 850nm
baseFilename{2, 1} = 'CD-4 post PA750_2015-11-26-08-48-37'; % Filename at 750nm
baseFilename{2, 2} = 'CD-4 post PA850_2015-11-26-08-50-56'; % Filename at 850nm

% baseFilename{1, 1} = 'CD-4 pre PA850_2015-10-21-19-50-45'; % Filename at 750nm
% baseFilename{1, 2} = 'CD-4 pre PA850_2015-10-21-19-50-45'; % Filename at 850nm
% baseFilename{2, 1} = 'CD-4 post PA750_2015-11-26-08-48-37'; % Filename at 750nm
% baseFilename{2, 2} = 'CD-4 post PA850_2015-11-26-08-50-56'; % Filename at 850nm

nSubjects = size(baseFilename, 1);


%% Subjects loop
for iSubjects = 1:nSubjects
    %% Run function
    Combined(iSubjects) = pat_get_SO2(baseDir, baseFilename(iSubjects,:));
    
    %% Create ROI
    clc; close all
    img = mean(Combined(iSubjects).Data, 3);
    % h_im = imshow(img);
    h = figure; h_im = imagesc(Combined(iSubjects).Width, Combined(iSubjects).Depth, img, [0 1]);
    axis image
    % pat_get_colormap('so2')
    set(h, 'color', 'w'); colormap(Combined(iSubjects).cmap); colorbar
    title(baseFilename{iSubjects, 2})
    xlabel('Width [mm]'); ylabel('Depth [mm]');
    % [XMIN YMIN WIDTH HEIGHT]
    nX = numel(Combined(iSubjects).Width);
    nY = numel(Combined(iSubjects).Depth);
    nFrames = size(Combined(iSubjects).SO2,3);
    maxX = max(Combined(iSubjects).Width);
    maxY = max(Combined(iSubjects).Depth);
    % 2 x 2 mm at (-2,10)mm
    myEllipse = imellipse(gca, round([-3.5 8.5 1 1]));
    pause;
    roi(iSubjects).Mask = createMask(myEllipse, h_im);
    roi(iSubjects).Mask3D = repmat(roi(iSubjects).Mask, [1 1 nFrames]);
    
    %% Extract ROI
    roi(iSubjects).avg = mean(Combined(iSubjects).SO2(roi(iSubjects).Mask3D));
    roi(iSubjects).sdev = std(Combined(iSubjects).SO2(roi(iSubjects).Mask3D));
    for iFrames = 1:nFrames,
        tmpImg = Combined(iSubjects).SO2(:, :, iFrames);
        roi(iSubjects).avgT(iFrames) = mean(tmpImg(roi(iSubjects).Mask));
        roi(iSubjects).sdevT(iFrames) = std(tmpImg(roi(iSubjects).Mask));
    end
end

%% Plot ROI
figure; hold on
plot(100*roi(1).avgT, 'k-')
plot(100*roi(2).avgT, 'r-')
legend({'Pre' 'Post'})
xlabel('Frames')
ylabel('SO_2 (%)')