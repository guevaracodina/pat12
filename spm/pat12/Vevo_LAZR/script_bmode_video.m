%% script_bmode_video
input_dir = 'F:\Edgar\Data\Injection';
fileName = fullfile(input_dir, 'RatToeD9_2013-05-16-13-05-51.raw.bmode');
output_dir = 'F:\Edgar\Data\Injection\';
bmp_dir = fullfile(output_dir,'Bmode_images');
if ~exist(bmp_dir,'dir'),mkdir(bmp_dir); end

%% File conversion
fileNameTXT = fullfile(input_dir, 'bModeframeData.txt');
% [nifti_filename affine_mat_filename param] = pat_raw2nifti_bmode(fileName, output_dir);
nifti_filename = 'F:\Edgar\Data\Injection\RatToeD9_2013-05-16-13-05-51.raw.bmode.nii';

%% Extract frame rate
fid = fopen(fileNameTXT);
data = textscan(fid, '%s %d: %s %d, %s = %f, %s %d', 'HeaderLines', 8, 'CollectOutput', true);
TR = median(diff(data{1,6})) / 1000;    % TR in seconds, data{1,6} in ms
fprintf('Frame rate = %0.2f fps\n', 1/TR);
fclose(fid);

%% read nifti files
load('F:\Edgar\Data\Injection\PAT.mat')
param = PAT.bModeParam;
v = spm_vol(nifti_filename);
I = spm_read_vols(v);

%% Display images
close all
h = figure;
set(h,'color','k')
colormap(pat_get_colormap('octgold'))
% Allow printing of black background
set(h, 'InvertHardcopy', 'off');
nFrames = size(I,4);
timeVector = 0:TR:TR*(nFrames-1);
% Prepare the new video file.
fName = fullfile(output_dir,'LPS_injection.avi');
aviobj = avifile(fName, 'compression', 'None');
aviobj.KeyFramePerSec = round(1/TR);
aviobj.fps = round(1/TR);
aviobj.videoname = 'LPS injection';
set(gcf,'Renderer','zbuffer');
% Axis limits (mm)
xLimits = [4.2 20];
yLimits = [8.9 18.9];
% display limits
dispLimits = [40 190];
for iFrames = 1:nFrames,
    % Need to flip L-R
    imagesc(param.WidthAxis, param.DepthAxis, fliplr(squeeze(I(:,:,1,iFrames))),...
        dispLimits);
    colorbar
    axis image
    xlim(xLimits);
    ylim(yLimits);
    set(gca,'YColor','w','XColor','w','FontSize',12,'TickDir','out',...
        'FontWeight','bold','XTick',xLimits,'YTick',yLimits)
    xlabel('Width (mm)','FontSize',12,'Color','w','FontWeight','bold')
    ylabel('Depth (mm)','FontSize',12,'Color','w','FontWeight','bold')
    title(sprintf('Time:%0.2f s',timeVector(iFrames)),'FontSize',12,'Color','w','FontWeight','bold')
    if iFrames == 1
        set(gca,'nextplot','replacechildren');
    end
    % pause(TR)
    % write each frame to the file.
    frame = getframe(h);
    aviobj = addframe(aviobj, frame);
end
aviobj = close(aviobj);
fprintf('Video saved as %s\n', fName);

% EOF
