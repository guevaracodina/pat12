function out = pat_correlation_map_run(job)
% A functional connectivity (fcPAT) map is made by correlating the seed/ROI with
% all other brain (non-masked) pixels
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------
% Get ROI info
[all_ROIs selected_ROIs] = pat_get_rois(job);

%Big loop over subjects
for scanIdx = 1:length(job.PATmat)
    try
        eTime = tic;
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        if ~isfield(PAT.jobsdone, 'GLMOK') % GLM OK
            fprintf('No GLM regression available for %s. Scan %d of %d ... skipping correlation map\n',scanName, scanIdx, length(job.PATmat));
        else
            if ~isfield(PAT.jobsdone,'corrOK') || job.force_redo
                % Get colors to include information
                IC = job.IC;
                colorNames = fieldnames(PAT.color);
                % File name where correlation data is saved
                PAT.fcPAT.corr(1).fname = fullfile(dir_patmat,'seed_based_fcPAT_map.mat');
                % Loop over sessions
                s1 = 1;
                % Loop over available colors
                for c1 = 1:length(PAT.nifti_files)
                    doColor = pat_doColor(PAT,c1,IC);
                    if doColor
                        % skip B-mode only extract PA
                        if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                            %% Main processing loop
                            nROI = 1:length(PAT.res.ROI); % All the ROIs
                            % Load regressed ROI data in cell ROIregress
                            load(PAT.fcPAT.SPM.fnameROIregress)
                            % Loop over ROI/seeds
                            for r1 = nROI,
                                if all_ROIs || sum(r1==selected_ROIs)
                                    % Checking if regression was succesful for both the seeds and the brain pixels time-courses
                                    if PAT.fcPAT.SPM.wholeImageRegressOK{s1, c1} && PAT.fcPAT.SPM.ROIregressOK{r1}{s1, c1}
                                        fprintf('Loading data, seed %d (%s) C%d (%s)...\n',r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1});
                                        % Load brain pixels time-course already filtered/downsampled & regressed
                                        vol = spm_vol(PAT.fcPAT.SPM.fname{s1, c1});
                                        y = spm_read_vols(vol);
                                        % Load ROI time-course already filtered/downsampled & regressed (column vector)
                                        % From PAT.fcPAT.SPM.fnameROIregress
                                        ROI = ROIregress{r1}{s1, c1}';
                                        % Load brain mask
                                        brainMaskVol = spm_vol(PAT.fcPAT.mask.fname);
                                        brainMask = logical(spm_read_vols(brainMaskVol));
                                        if size(brainMask,1)~= size(y,1)|| size(brainMask,2)~= size(y,2)
                                            brainMask = pat_imresize(brainMask, [size(y,1) size(y,2)]);
                                        end
                                        % Preallocate
                                        tempCorrMap = zeros([size(y,1) size(y,2)]);
                                        pValuesMap =  zeros([size(y,1) size(y,2)]);
                                        if job.derivative
                                            tempCorrMapDiff = zeros([size(y,1) size(y,2)]);
                                            pValuesMapDiff =  zeros([size(y,1) size(y,2)]);
                                        end
                                        % Find Pearson's correlation coefficient
                                        fprintf('Computing Pearson''s correlation map...\n');
                                        % Initialize progress bar
                                        spm_progress_bar('Init', size(y,1), sprintf('Computing Pearson''s correlation map Seed %d (%s) C%d (%s)\n',r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1}), 'Samples');
                                        pat_text_waitbar(0, sprintf('Computing Pearson''s correlation map Seed %d (%s) C%d (%s)\n',r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1}));
                                        % Loop over samples
                                        for iX = 1:size(y,1),
                                            % Loop over A-lines
                                            for iY = 1:size(y,2),
                                                if brainMask(iX, iY)
                                                    [tempCorrMap(iX, iY) pValuesMap(iX, iY)]= corr(squeeze(ROI), squeeze(y(iX, iY, 1, :)));
                                                    if job.derivative
                                                        [tempCorrMapDiff(iX, iY) pValuesMapDiff(iX, iY)]= corr(diff(squeeze(ROI)), diff(squeeze(y(iX, iY, 1, :))));
                                                    end
                                                end
                                            end
                                            % Update progress bar
                                            spm_progress_bar('Set', iX);
                                            pat_text_waitbar(iX/size(y,1), sprintf('Processing sample %d from %d', iX, size(y,1)));
                                        end
                                        % Clear progress bar
                                        spm_progress_bar('Clear');
                                        pat_text_waitbar('Clear');
                                        % Assign data to be saved to  .mat file
                                        seed_based_fcPAT_map{r1}{s1,c1}.pearson = tempCorrMap;
                                        seed_based_fcPAT_map{r1}{s1,c1}.pValue = pValuesMap;
                                        
                                        % Here save as nifti
                                        if ~isempty(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1})
                                            [~, oldName, oldExt] = fileparts(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
                                        else
                                            oldName = sprintf('ROI%02d_C%d', r1, c1);
                                            oldExt = '.nii';
                                        end
                                        newName = [oldName '_fcPAT_map'];
                                        if isfield(job.PATmatCopyChoice,'PATmatCopy')
                                            dir_corrfig = fullfile(dir_patmat,strcat('fig_',job.PATmatCopyChoice.PATmatCopy.NewPATdir));
                                        else
                                            dir_corrfig = fullfile(dir_patmat,'fig_corrMap');
                                        end
                                        if ~exist(dir_corrfig,'dir'), mkdir(dir_corrfig); end
                                        % Create and write a 1-slice NIFTI file
                                        pat_create_vol(fullfile(dir_corrfig,[newName oldExt]), brainMaskVol(1).dim, brainMaskVol(1).dt,...
                                            brainMaskVol(1).pinfo, brainMaskVol(1).mat, 1, tempCorrMap);
                                        PAT.fcPAT.corr(1).corrMapName{r1}{s1, c1} = fullfile(dir_corrfig,[newName oldExt]);
                                        
                                        if job.derivative
                                            internal_derivative_corrMap
                                        end
                                        
                                        if job.generate_figures
                                            fcPAT_display_corrMap(PAT, job, scanIdx, r1, s1, c1, dir_corrfig, newName, brainMask, pValuesMap);
                                        end
                                                                                
                                        % Convert Pearson's correlation coeff. r to Fisher's z value.
                                        if job.fisherZ
                                            internal_Fisher;
                                        end
                                        
                                        % correlation map succesful!
                                        fprintf('Pearson''s correlation coefficient computed. Seed %d (%s) C%d (%s)\n',r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1});
                                        PAT.fcPAT.corr(1).corrMapOK{r1}{s1, c1} = true;
                                    else
                                        % correlation map failed!
                                        PAT.fcPAT.corr(1).corrMapOK{r1}{s1, c1} = false;
                                        fprintf('Pearson''s correlation coefficient failed! Seed %d (%s) C%d (%s)\n',r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1});
                                    end
                                end % if all ROIs
                            end % ROI/seeds loop
                        end
                    end
                end % colors loop
                
                % correlation succesful!
                PAT.jobsdone.corrOK = true;
                % Compute seed to seed correlation matrix
                if job.seed2seedCorrMat
                    [seed2seedCorrMat seed2seedCorrMatDiff PAT.fcPAT.corr(1).corrMatrixFname PAT.fcPAT.corr(1).corrMatrixDiffFname] = ioi_roi_corr(job, scanIdx);
                    % seed-to-seed correlation succesful!
                    PAT.fcPAT.corr(1).corrMatrixOK = true;
                    % Save seed-to-seed correlation data
                    save(PAT.fcPAT.corr(1).corrMatrixFname,'seed2seedCorrMat')
                    % Save seed-to-seed derivatives correlation data
                    save(PAT.fcPAT.corr(1).corrMatrixDiffFname,'seed2seedCorrMatDiff')
                end
                
                % Compute correlation data from raw time courses
                if job.rawData
                    % Compute the seed-to-seed correlation of raw data
                    [seed2seedCorrMatRaw PAT.fcPAT.corr(1).corrMatrixRawFname] = pat_roi_corr_raw(job,SubjIdx);
                    % Save seed-to-seed correlation data
                    save(PAT.fcPAT.corr(1).corrMatrixRawFname, 'seed2seedCorrMatRaw')
                end
                
                % Save fcPAT data
                save(PAT.fcPAT.corr(1).fname,'seed_based_fcPAT_map')
                % Save PAT matrix
                save(PATmat,'PAT');
            end % correlation OK or redo job
        end % GLM OK
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        fprintf('Scan %s, %d of %d complete %30s\n', splitStr{end-1}, scanIdx, length(job.PATmat), spm('time'));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % loop over scans
end % pat_correlation_map_run

function internal_derivative_corrMap
    fprintf ('internal_derivative_corrMap not implemented yet\n')
    return
    seed_based_fcPAT_map{r1}{s1,c1}.pearsonDiff = tempCorrMapDiff;
    seed_based_fcPAT_map{r1}{s1,c1}.pValueDiff = pValuesMapDiff;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if job.generate_figures
        % Improve display
        tempCorrMapDiff(~brainMask) = median(tempCorrMapDiff(:));
        % Seed annotation dimensions
        % the lower left corner of
        % the bounding rectangle at
        % the point seedX, seedY
        seedX = PAT.res.ROI{r1}.center(2) - PAT.res.ROI{r1}.radius;
        seedY = PAT.res.ROI{r1}.center(1) - PAT.res.ROI{r1}.radius;
        % Seed width
        seedW = 2*PAT.res.ROI{r1}.radius;
        % Seed height
        seedH = 2*PAT.res.ROI{r1}.radius;
        if isfield(PAT.res,'shrinkageOn')
            if PAT.res.shrinkageOn == 1
                seedX = seedX / PAT.res.shrink_x;
                seedY = seedY / PAT.res.shrink_y;
                seedW = seedW / PAT.res.shrink_x;
                seedH = seedH / PAT.res.shrink_y;
            end
        end
        
        % Display plots on SPM graphics window
        h = spm_figure('GetWin', 'Graphics');
        spm_figure('Clear', 'Graphics');
        spm_figure('ColorMap','jet')
        
        % Correlation map
        subplot(211)
        imagesc(tempCorrMapDiff); colorbar; axis image;
        % Display ROI
        rectangle('Position',[seedX seedY seedW seedH],...
            'Curvature',[1,1],...
            'LineWidth',2,'LineStyle','-');
        set(gca,'Xtick',[]); set(gca,'Ytick',[]);
        xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
        title(sprintf('%s fcPAT map Seed %d (%s) S%d C%d (%s) Diff\n',scanName,r1,PAT.ROI.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
        
        % Show only significant
        % pixels
        subplot(212)
        imagesc(tempCorrMapDiff .* (pValuesMapDiff <= job.pValue), [-1 1]); colorbar; axis image;
        % Display ROI
        rectangle('Position',[seedX seedY seedW seedH],...
            'Curvature',[1,1],...
            'LineWidth',2,'LineStyle','-');
        set(gca,'Xtick',[]); set(gca,'Ytick',[]);
        xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
        title(sprintf('%s significant pixels (p<%.2f) Seed %d (%s) S%d C%d (%s) Diff\n',scanName,job.pValue,r1,PAT.ROI.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
        
        if job.save_figures
            [~, oldName, oldExt] = fileparts(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
            % newName = [oldName '_fcPAT_map'];
            newName = [sprintf('%s_R%02d_S%02d_C%d',scanName,r1,s1,c1) '_fcPAT_map_diff'];
            dir_corrfigDiff = fullfile(dir_patmat,'fig_corrMapDiff');
            if ~exist(dir_corrfigDiff,'dir'), mkdir(dir_corrfigDiff); end
            % Save as PNG
            print(h, '-dpng', fullfile(dir_corrfigDiff,newName), '-r300');
            % Save as a figure
            saveas(h, fullfile(dir_corrfigDiff,newName), 'fig');
            % Save as EPS
            spm_figure('Print', 'Graphics', fullfile(dir_corrfigDiff,newName));
            % Save as nifti
            ioi_save_nifti(tempCorrMap, fullfile(dir_corrfigDiff,[newName oldExt]), vx);
            PAT.fcPAT.corr(1).corrMapNameDiff{r1}{s1, c1} = fullfile(dir_corrfigDiff,[newName oldExt]);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Derivative processing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  % internal_derivative_corrMap

function internal_Fisher
fprintf ('internal_Fisher not implemented yet\n')
    return
%     % Find Pearson's correlation coefficient
%     fprintf('Computing Fisher''s Z statistic...\n');
%     [~, oldName, oldExt] = fileparts(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
%     % newName = [oldName '_fcPAT_Zmap'];
%     newName = [sprintf('%s_R%02d_S%02d_C%d',scanName,r1,s1,c1) '_fcPAT_Zmap'];
%     dir_fisherZfig = fullfile(dir_patmat,'fig_fisherZ');
%     if ~exist(dir_fisherZfig,'dir'), mkdir(dir_fisherZfig); end
%     % Convert r to z, masking
%     % out non-brain voxels
%     seed_based_fcPAT_map{r1}{s1,c1}.fisher = fisherz(tempCorrMap) .* brainMask;
%     if job.generate_figures
%         % Save as nifti
%         ioi_save_nifti(seed_based_fcPAT_map{r1}{s1,c1}.fisher, fullfile(dir_fisherZfig,[newName oldExt]), vx);
%         % Save masked file as nifti
%         ioi_save_nifti(seed_based_fcPAT_map{r1}{s1,c1}.fisher .* (pValuesMap < job.pValue), fullfile(dir_fisherZfig,[newName '_Masked' oldExt]), vx);
%         PAT.fcPAT.corr(1).zMapName{r1}{s1, c1} = fullfile(dir_fisherZfig,[newName oldExt]);
%         PAT.fcPAT.corr(1).zMapNameMask{r1}{s1, c1} = fullfile(dir_fisherZfig,[newName '_Masked' oldExt]);
%         % Find 1st positive value
%         z1 = sort(seed_based_fcPAT_map{r1}{s1,c1}.fisher(:),1,'ascend');
%         idx1  = find(z1>0, 1, 'first');
%         minPosVal = z1(idx1);
%         
%         % Find 1st negative value
%         z2 = sort(seed_based_fcPAT_map{r1}{s1,c1}.fisher(:),1,'descend');
%         idx2  = find(z2<0, 1, 'first');
%         minNegVal = z2(idx2);
%         
%         % Get parameters for overlay
%         anatomical      = PAT.res.file_anat;
%         % positiveMap     = PAT.fcPAT.corr.zMapName{r1}{s1, c1};
%         positiveMap     = PAT.fcPAT.corr.zMapNameMask{r1}{s1, c1};
%         % negativeMap     = PAT.fcPAT.corr.zMapName{r1}{s1, c1};
%         negativeMap     = PAT.fcPAT.corr.zMapNameMask{r1}{s1, c1};
%         colorNames      = fieldnames(PAT.color);
%         mapRange        = {[minPosVal max(z1)], [minNegVal min(z2)]};
%         titleString     = sprintf('%s seed%d S%d(%s)Z-map',scanName,r1,s1,colorNames{1+c1});
%         % Display plots on SPM graphics window
%         h = spm_figure('GetWin', 'Graphics');
%         spm_figure('Clear', 'Graphics');
%         h = ioi_overlay_map(anatomical, positiveMap, negativeMap, mapRange, titleString);
%         if job.save_figures
%             % Save as PNG
%             print(h, '-dpng', fullfile(dir_fisherZfig,newName), '-r150');
%             % Save as a figure
%             saveas(h, fullfile(dir_fisherZfig,newName), 'fig');
%             % Save as EPS
%             spm_figure('Print', 'Graphics', fullfile(dir_fisherZfig,newName));
%         end
%     end
end % internal_Fisher

function fcPAT_display_corrMap(PAT, job, scanIdx, r1, s1, c1, dir_corrfig, newName, brainMask, pValuesMap)
    %% Load correlation data
    tempCorrMapVol = spm_vol(PAT.fcPAT.corr.corrMapName{r1}{s1, c1});
    tempCorrMap = spm_read_vols(tempCorrMapVol);
    newName = [newName '_masked'];
    dir_corrMapMaskedfig = dir_corrfig;
    oldExt = '.nii';
    %% Mask out non-brain voxels
    if size(brainMask,1)~= size(tempCorrMap,1)|| size(brainMask,2)~= size(tempCorrMap,2)
        brainMask = pat_imresize(brainMask, [size(tempCorrMap,1) size(tempCorrMap,2)]);
    end
    
    if job.bonferroni
        nComparisons = sum(brainMask(:) == true);
        % Make NaN all the transparent or non-significant pixels
        tempCorrMap(~brainMask | (pValuesMap>(job.pValue / nComparisons))) = NaN;
    else
        % Make NaN all the transparent or non-significant pixels
        tempCorrMap(~brainMask | (pValuesMap>job.pValue)) = NaN;
    end
    y = tempCorrMap;
    PAT.fcPAT.corr.corrMapNameMask{r1}{s1, c1} = fullfile(dir_corrMapMaskedfig,[newName oldExt]);
    % Save NIfTI to use slover
    pat_create_vol(PAT.fcPAT.corr.corrMapNameMask{r1}{s1, c1}, ...
        tempCorrMapVol(1).dim, tempCorrMapVol(1).dt, tempCorrMapVol(1).pinfo, ...
        tempCorrMapVol(1).mat, 1, y);

    %% Display overlay data and print to png and fig
    % Get parameters for overlay
    anatomical      = PAT.res.file_anat;
    corrMap         = PAT.fcPAT.corr.corrMapNameMask{r1}{s1, c1};
    
    % NEED TO CORRECT THE COORDINATES FOR SEEDX AND SEEDY, ALSO THE ASPECT RATIO OF THE CIRCLE//EGC
    
    % Seed annotation dimensions the lower left corner of the bounding rectangle
    % at the point seedX, seedY (the + sign here is due to image rotation)
    seedX = PAT.res.ROI{r1}.center(1) + PAT.res.ROI{r1}.radius;
    seedY = (tempCorrMapVol(1).dim(2) -  PAT.res.ROI{r1}.center(2) - PAT.res.ROI{r1}.radius - PAT.PAparam.PaDepthOffset)*(PAT.PAparam.pixDepth / PAT.PAparam.pixWidth);
    % (PAT.PAparam.pixDepth / PAT.PAparam.pixWidth)
    % Seed width
    seedW = 2*PAT.res.ROI{r1}.radius;
    % Seed height
    seedH = 2*PAT.res.ROI{r1}.radius;
    % Scale seeds to mm dimensions
%     seedX = seedX * PAT.PAparam.pixWidth;
%     seedY = seedY * PAT.PAparam.pixDepth;
%     seedW = seedW * PAT.PAparam.pixWidth;
%     seedH = seedH * PAT.PAparam.pixDepth;
    internal_overlay_map(anatomical, corrMap,  job, newName, [seedX seedY seedW seedH], scanIdx, c1, r1, dir_corrMapMaskedfig);
end

function [h, varargout] = internal_overlay_map(anatomical, positiveMap, job, titleString, seedDims, scanIdx, c1, r1, dir_corrMapMaskedfig)
% Creates an overlay image composed of positive & negative functional maps (any
% contrast, correlation, z, p-value, etc.) onto an anatomical image.
% The images must be saved as NIfTI (.nii) files and they can have different
% sizes. This function makes use of slover and paint functions of SPM8.
% The positive map is plotted in hot colormap, the negative map is cold and the
% anatomical is grayscale by default. The image has the following orientation:
% 
%         Rostral
%       |________
%       |
%       |
%  Left | 
%       |        
% 
% SYNTAX
% h = internal_overlay_map( anatomical,positiveMap, job, titleString, seedDims,
%                           scanIdx, c1, r1, dir_corrMapMaskedfig)
% INPUTS
% anatomical    NIfTI (.nii) filename with anatomical image for background.
% positiveMap   NIfTI (.nii) filename with positive functional map on the
%               foreground.
% job           Matlab batch job
% titleString   String with the title to be displayed.
% seedDims      Seed dimensions [seedX seedY seedW seedH]
% OUTPUT
% h             Handle to the figure
% slObj         [OPTIONAL] slover object
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________


% Necessary to get rid of old overlay objects
clear imagesOverlay
% Make cell with file names
imagesOverlay{1,1}  = anatomical;           % Anatomical image
imagesOverlay{2,1}  = positiveMap;          % Pos. correlation
% imagesOverlay{3,1}  = negativeMap;          % Neg. correlation

% Handle of current figure;
h = figure(999);
set(h,'color','k')

% Get range
mapRange        = {job.figRange};

% Make mapRange a column vector
if size(mapRange, 1) == 1
    mapRange = mapRange';
    mapRange = cellfun(@(x) x', mapRange, 'UniformOutput', false);
end

% ------------------------------------------------------------------------------
% Define anonymous functions for affine transformations
% ------------------------------------------------------------------------------
rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
translate = @(a,b) [1 0 a 0; 0 1 b 0; 0 0 1 0; 0 0 0 1];
% ------------------------------------------------------------------------------

% Create overlay object
slObj = slover(char(imagesOverlay));

slObj.slices = 1;                           % For PAT images only 1 slice (2D)
                                            % Automatic range for image 1 (anatomy)
slObj.img(2).range = mapRange{1};           % Range for positive map

slObj.img(1).type = 'truecolour';           % Anatomical image
slObj.img(2).type = 'truecolour';           % Functional map

slObj.img(1).cmap = gray(256);              % Colormap for anatomy
slObj.img(2).cmap = job.figCmap;            % Colormap for functional map

% slObj.cbar = [2 3];                         % Plot colorbars for images 2 & 3
slObj.area.valign = 'middle';               % Vertical alignment
slObj.area.halign = 'center';               % Horizontal alignment

slObj.img(1).prop = job.figIntensity;       % Proportion of intensity for anatomy
slObj.img(2).prop = job.figAlpha;           % Proportion of intensity for positive map

slObj.img(1).outofrange =  {0 255};         % Behavior for image values out of range 
slObj.img(2).outofrange =  {0 255};

slObj.labels = 'none';                      % No labels on this slice

% Apply affine transformation
%slObj.transform = job.transM*translate(-slObj.img(1).vol.dim(1),-slObj.img(1).vol.dim(2));               % Apply affine transformation
% volTmp = spm_vol(anatomical);
% slObj.transform = job.transM*volTmp.mat*translate(slObj.img(1).vol.dim(1),slObj.img(1).vol.dim(2));

% Change figure name
set(slObj.figure,'Name',titleString);

% Specify window units
set(h, 'units', 'inches')
% Change figure and paper size
set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
% Refresh figure
slObj = paint(slObj);

% Seed positions and sizes will be shown with black circles
if isfield(job.drawCircle,'drawCircle_On')
    figure(h);
    % New seeds coordinates (after affine transformation)
%     newSeedCoord = job.transM*[seedDims(1) seedDims(2) 0 1]' + [slObj.img(1).vol.dim(2) slObj.img(1).vol.dim(1) 0 0]';
%     seedDims(1:2) = newSeedCoord(2:-1:1)';

%      seedDims(2) = slObj.img(1).vol.dim(2) - seedDims(2);
%      seedDims(1:2) = seedDims(2:-1:1);
    % Display ROI
    rectangle('Position',seedDims,...
        'Curvature',[1,1],...
        'LineWidth',job.drawCircle.drawCircle_On.circleLW,...
        'LineStyle',job.drawCircle.drawCircle_On.circleLS,...
        'EdgeColor','k');
end
figSuffix = 'fcPAT_map_masked';
% Save figure
pat_save_figs(job, h, figSuffix, scanIdx, c1, r1, dir_corrMapMaskedfig);

% Pass the slover object as output
if nargout >= 1
    varargout{1} = slObj;
end
end % internal_overlay_map

% EOF
