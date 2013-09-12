%% script_oxysurge_video
clear all; clc
load('F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\PAT.mat')
input_dir = PAT.input_dir;
output_dir = PAT.output_dir;
fileNameTXT = fullfile(PAT.output_dir, 'bModeframeData.txt');
% SO2
nifti_filename = PAT.nifti_files{2};

%% Extract frame rate
fid = fopen(fileNameTXT);
data = textscan(fid, '%s %d: %s %d, %s = %f, %s %d', 'HeaderLines', 8, 'CollectOutput', true);
TR = median(diff(data{1,6})) / 1000;    % TR in seconds, data{1,6} in ms
fprintf('Frame rate = %0.2f fps\n', 1/TR);
fclose(fid);

%% read nifti files
v = spm_vol(nifti_filename);
I = spm_read_vols(v);
% ROI to plot
r1 = 11;
% color to plot (1=HbT, 2=SO2)
c1 = 2;
% Convert to SO2 data
I = pat_raw2so2(I);
% Load ROI info
load('F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\ROI\PAT.mat')
load(PAT.ROI.ROIfname)
% Convert ROI to SO2 %
ROI{r1}{c1} = pat_raw2so2(ROI{r1}{c1});
% Oxygen surge limits (in seconds)
oxyLimits = [60 240];
% Load ROI NIfTI file
v = spm_vol(PAT.res.ROI{r1}.fname);
imROI = spm_read_vols(v);

%% Display images
output_dir = fullfile(PAT.output_dir,'OS_video');
if ~exist(output_dir,'dir'),mkdir(output_dir); end
close all
h = figure;
% Black background
set(h,'color','k')
% whitebg('k')
colormap(pat_get_colormap('rwbdoppler'))
% Allow printing of black background
set(h, 'InvertHardcopy', 'off');
nFrames = size(I,4);
timeVector = 0:TR:TR*(nFrames-1);
% Prepare the new video file.
fName = fullfile(output_dir,'Oxygen_Surge.avi');
aviobj = avifile(fName, 'compression', 'None');
aviobj.KeyFramePerSec = round(1/TR);
% Accelerate video
timesFaster = 30;
aviobj.fps = timesFaster*round(1/TR);
aviobj.videoname = 'Oxygen_Surge';
set(gcf,'Renderer','zbuffer');
% Axis limits (mm)
% xLimits = PAT.PAparam.WidthAxis([1,end]);
xLimits = [2.3 10.8];
yLimits = PAT.PAparam.DepthAxis([1,end]);
% display limits (in SO2 %)
dispLimits = [0 100];


%% Cine-loop
for iFrames = 1:nFrames,
    subplot(211)
    % Need to flip L-R?
    imagesc(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, squeeze(I(:,:,1,iFrames)),...
        dispLimits);
    hold all
    contour(PAT.PAparam.WidthAxis, PAT.PAparam.DepthAxis, imROI, [1 1], 'w-', 'LineWidth', 2)
    if iFrames == 1
        hbar = colorbar;
        set(hbar,'YTick',dispLimits,'YColor','w','FontSize',12,'FontWeight','bold')
        set(hbar,'nextplot','replacechildren');
    end
    axis image
    xlim(xLimits);
    ylim(yLimits);
    set(gca,'YColor','w','XColor','w','FontSize',12,'TickDir','out',...
        'FontWeight','bold','XTick',xLimits,'YTick',yLimits)
    xlabel('Width (mm)','FontSize',12,'Color','w','FontWeight','bold')
    ylabel('Depth (mm)','FontSize',12,'Color','w','FontWeight','bold')
    title(sprintf('Time:%0.2f s',timeVector(iFrames)),'FontSize',12,'Color','w','FontWeight','bold')
    set(gca,'nextplot','replacechildren');
    % pause(TR)
    
    subplot(212)
    plot(timeVector(1:iFrames), ROI{r1}{c1}(1:iFrames), 'r-', 'LineWidth', 2)
    hold on
    plot([oxyLimits(1) oxyLimits(1)], dispLimits, 'b--', 'LineWidth', 2);
    plot([oxyLimits(2) oxyLimits(2)], dispLimits, 'b--', 'LineWidth', 2);
    set(gca,'color','k','YColor','w','XColor','w','FontSize',12,'FontWeight','bold',...
        'YTick',[dispLimits(1) (dispLimits(1)+dispLimits(2))/2 dispLimits(end)]);
    xlim(timeVector([1 end]))
    ylim(dispLimits);
    xlabel('time (s)','FontSize',12,'Color','w','FontWeight','bold')
    ylabel('SO_2 (%)','FontSize',12,'Color','w','FontWeight','bold')
    set(gca,'nextplot','replacechildren');
    % write each frame to the file.
    frame = getframe(h);
    aviobj = addframe(aviobj, frame);
end
aviobj = close(aviobj);
fprintf('Video (@%.1f fps) saved as %s\n', aviobj.fps, fName);

% EOF
