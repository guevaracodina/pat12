%% script_pat_get_so2
clear; close all; clc;

% baseDir = 'D:\Edgar\PAT_test_data';
% baseFilename{1, 1} = 'Air-750nm'; % Filename at 750nm
% baseFilename{1, 2} = 'Air-850nm'; % Filename at 850nm

baseDir = 'C:\Edgar\Dropbox\CIACYT\PAT_cardio\PAT_Data';
baseFilename{1, 1} = 'CD-4 pre PA750_2015-10-21-19-55-09'; % Pre Filename at 750nm
baseFilename{1, 2} = 'CD-4 pre PA850_2015-10-21-19-50-45'; %  Pre Filename at 850nm
baseFilename{2, 1} = 'CD-4 post PA750_2015-11-26-08-48-37'; % Post Filename at 750nm
baseFilename{2, 2} = 'CD-4 post PA850_2015-11-26-08-50-56'; % Post Filename at 850nm

baseFilename{3, 1} = 'CD-5 pre PA750_2015-10-22-13-12-26'; % Pre Filename at 750nm
baseFilename{3, 2} = 'CD-5 pre PA850_2015-10-22-13-15-09'; % Pre Filename at 850nm
baseFilename{4, 1} = 'CD-5 post PA750_2015-11-26-16-37-38'; % Post Filename at 750nm
baseFilename{4, 2} = 'CD-5 post PA850_2015-11-26-16-35-19'; % Post Filename at 850nm

baseFilename{5, 1} = 'CD-7 pre PA750_2015-11-04-10-54-24'; % Pre Filename at 750nm
baseFilename{5, 2} = 'CD-7 pre PA850_2015-11-04-10-51-53'; % Pre Filename at 850nm
baseFilename{6, 1} = 'CD-7 post PA750_2015-11-27-19-11-01'; % Post Filename at 750nm
baseFilename{6, 2} = 'CD-7 post PA850_2015-11-27-19-13-21'; % Post Filename at 850nm

% baseFilename{1, 1} = 'CD-4 pre PA850_2015-10-21-19-50-45'; % Filename at 750nm
% baseFilename{1, 2} = 'CD-4 pre PA850_2015-10-21-19-50-45'; % Filename at 850nm
% baseFilename{2, 1} = 'CD-4 post PA750_2015-11-26-08-48-37'; % Filename at 750nm
% baseFilename{2, 2} = 'CD-4 post PA850_2015-11-26-08-50-56'; % Filename at 850nm

nSubjects = size(baseFilename, 1);


%% Subjects loop
for iSubjects = 1:nSubjects
    disp(['Processing' baseFilename(iSubjects,:)])
    % Run function
    Combined(iSubjects) = pat_get_SO2(baseDir, baseFilename(iSubjects,:));
    % [XMIN YMIN WIDTH HEIGHT]
    roi(iSubjects).nX = numel(Combined(iSubjects).Width);
    roi(iSubjects).nY = numel(Combined(iSubjects).Depth);
    roi(iSubjects).nFrames = size(Combined(iSubjects).SO2,3);
    roi(iSubjects).maxX = max(Combined(iSubjects).Width);
    roi(iSubjects).maxY = max(Combined(iSubjects).Depth);
    
    close all
    % Create ROI loop
%     if mod(iSubjects,2), % odd image
%         img = mean(Combined(iSubjects).Data, 3);      % Combinada
        img = mean(Combined(iSubjects).Bmode, 3);
        h = figure; cla;
        h_im = imagesc(Combined(iSubjects).Width, Combined(iSubjects).Depth, img);
        axis image
        set(h, 'color', 'w'); 
%         colormap(Combined(iSubjects).cmap); 
        % colormap(pat_get_colormap('so2'));
        colormap(pat_get_colormap('wob'));
        colorbar
        title(baseFilename{iSubjects, 2})
        xlabel('Width [mm]'); ylabel('Depth [mm]');
        % 2 x 2 mm at (-2,10)mm
        clear myEllipse
        myEllipse = imellipse(gca, round([-3.5 8.5 1 1]));
        position = wait(myEllipse);
        roi(iSubjects).Mask = createMask(myEllipse, h_im);
%     else % even image
%         roi(iSubjects).Mask = roi(iSubjects-1).Mask;
%     end
    roi(iSubjects).Mask3D = repmat(roi(iSubjects).Mask, [1 1 roi(iSubjects).nFrames]);
    
    % Extract ROI
    roi(iSubjects).avg = mean(Combined(iSubjects).SO2(roi(iSubjects).Mask3D));
    roi(iSubjects).sdev = std(Combined(iSubjects).SO2(roi(iSubjects).Mask3D));
    for iFrames = 1:roi(iSubjects).nFrames,
        tmpImg = Combined(iSubjects).SO2(:, :, iFrames);
        roi(iSubjects).avgT(iFrames) = mean(tmpImg(roi(iSubjects).Mask));
        roi(iSubjects).sdevT(iFrames) = std(tmpImg(roi(iSubjects).Mask));
    end
end

%% Plot ROI
figure; 
subplot(221)
hold on
plot(100*roi(1).avgT, 'k-')
plot(100*roi(2).avgT, 'r-')
legend({'Pre' 'Post'})
xlabel('Frames')
ylabel('SO_2(%)')
title('CD-4 mouse')

subplot(222)
hold on
plot(100*roi(3).avgT, 'k-')
plot(100*roi(4).avgT, 'r-')
legend({'Pre' 'Post'})
xlabel('Frames')
ylabel('SO_2(%)')
title('CD-5 mouse')

subplot(223)
hold on
plot(100*roi(5).avgT, 'k-')
plot(100*roi(6).avgT, 'r-')
legend({'Pre' 'Post'})
xlabel('Frames')
ylabel('SO_2(%)')
title('CD-7 mouse')
