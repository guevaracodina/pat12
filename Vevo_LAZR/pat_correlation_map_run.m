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
fprintf('Work in progress...\nEGC\n')
out.PATmat = job.PATmat;
return
% ------------------------------------------------------------------------------

%Big loop over subjects
for scanIdx=1:length(job.PATmat)
    try
        tic
        %Load PAT.mat information
        [PAT PATmat dir_patmat]= ioi_get_IOI(job,scanIdx);  

        if ~isfield(PAT.jobsdone, 'GLMOK') % GLM OK
            disp(['No GLM regression available for subject ' int2str(scanIdx) ' ... skipping correlation map']);
        else
            if ~isfield(PAT.jobsdone,'corrOK') || job.force_redo
                % Get colors to include information
                IC = job.IC;
                colorNames = fieldnames(PAT.color);
               
                % File name where correlation data is saved
                PAT.fcPAT.corr(1).fname = fullfile(dir_patmat,'seed_based_fcIOS_map.mat');
                
                % Loop over sessions
                s1 = 1
                
                % Loop over available colors
                for c1=1:length(PAT.sess_res{s1}.fname)
                    doColor = ioi_doColor(PAT,c1,IC);
                    if doColor
                        colorOK = true;
                        %skip laser - only extract for flow
                        if ~(PAT.color.eng(c1)==PAT.color.laser)
                            %% Main processing loop
                            [all_ROIs selected_ROIs] = ioi_get_ROIs(job);
                            nROI = 1:length(PAT.res.ROI); % All the ROIs
                            
                            % Initialize progress bar
                            spm_progress_bar('Init', numel(nROI), sprintf('fcIOS map S%d C%d (%s)\n',s1,c1,colorNames{1+c1}), 'Seeds');
                            % Load regressed ROI data in cell ROIregress
                            load(PAT.fcPAT.SPM.fnameROIregress)
                            % Loop over ROI/seeds
                            for r1 = nROI,
                                if all_ROIs || sum(r1==selected_ROIs)
                                    
                                    % Checking if regression was
                                    % succesful for both the seeds and
                                    % the brain pixels time-courses
                                    if PAT.fcPAT.SPM.wholeImageRegressOK{s1, c1} && PAT.fcPAT.SPM.ROIregressOK{r1}{s1, c1}
                                        fprintf('Loading data, seed %d (%s) session %d C%d (%s)...\n',r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1});
                                        % Load brain pixels time-course
                                        % already filtered/downsampled &
                                        % regressed
                                        vol = spm_vol(PAT.fcPAT.SPM.fname{s1, c1});
                                        y = spm_read_vols(vol);
                                        % Load ROI time-course already
                                        % filtered/downsampled &
                                        % regressed (column vector)
                                        % ROIvol = spm_vol(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
                                        % ROI = spm_read_vols(ROIvol);
                                        ROI = ROIregress{r1}{s1, c1}';
                                        % Load brain mask
                                        brainMaskVol = spm_vol(PAT.fcPAT.mask.fname);
                                        brainMask = logical(spm_read_vols(brainMaskVol));
                                        if size(brainMask,1)~= size(y,1)|| size(brainMask,2)~= size(y,2)
                                            brainMask = ioi_MYimresize(brainMask, [size(y,1) size(y,2)]);
                                        end
                                        
                                        % Preallocate
                                        tempCorrMap = zeros([size(y,1) size(y,2)]);
                                        pValuesMap =  zeros([size(y,1) size(y,2)]);
                                        if isfield (job,'derivative')
                                            tempCorrMapDiff = zeros([size(y,1) size(y,2)]);
                                            pValuesMapDiff =  zeros([size(y,1) size(y,2)]);
                                        end
                                        % Find Pearson's correlation coefficient
                                        fprintf('Computing Pearson''s correlation map...\n');
                                        for iX = 1:size(y,1),
                                            for iY = 1:size(y,2),
                                                if brainMask(iX, iY)
                                                    [tempCorrMap(iX, iY) pValuesMap(iX, iY)]= corr(squeeze(ROI), squeeze(y(iX, iY, 1, :)));
                                                    if isfield (job,'derivative')
                                                        [tempCorrMapDiff(iX, iY) pValuesMapDiff(iX, iY)]= corr(diff(squeeze(ROI)), diff(squeeze(y(iX, iY, 1, :))));
                                                    end
                                                end
                                            end
                                        end
                                        % Assign data to be saved to
                                        % .mat file
                                        seed_based_fcIOS_map{r1}{s1,c1}.pearson = tempCorrMap;
                                        seed_based_fcIOS_map{r1}{s1,c1}.pValue = pValuesMap;
                                        
                                        % Her save as nifti
                                        
                                        if isfield (job,'derivative')
                                            internal_derivative_corrMap
                                        end
                                        
                                        if job.generate_figures
                                            fcPAT_display_corrMap;
%                                                     % Improve display
%                                                     tempCorrMap(~brainMask) = median(tempCorrMap(:));
%                                                     % Seed annotation dimensions
%                                                     % the lower left corner of
%                                                     % the bounding rectangle at
%                                                     % the point seedX, seedY
%                                                     seedX = PAT.res.ROI{r1}.center(2) - PAT.res.ROI{r1}.radius;
%                                                     seedY = PAT.res.ROI{r1}.center(1) - PAT.res.ROI{r1}.radius;
%                                                     % Seed width
%                                                     seedW = 2*PAT.res.ROI{r1}.radius;
%                                                     % Seed height
%                                                     seedH = 2*PAT.res.ROI{r1}.radius;
%                                                     if isfield(PAT.res,'shrinkageOn')
%                                                         if PAT.res.shrinkageOn == 1
%                                                             seedX = seedX / PAT.res.shrink_x;
%                                                             seedY = seedY / PAT.res.shrink_y;
%                                                             seedW = seedW / PAT.res.shrink_x;
%                                                             seedH = seedH / PAT.res.shrink_y;
%                                                         end
%                                                     end
%
%                                                     % Display plots on SPM graphics window
%                                                     h = spm_figure('GetWin', 'Graphics');
%                                                     spm_figure('Clear', 'Graphics');
%                                                     spm_figure('ColorMap','jet')
%
%                                                     % Correlation map
%                                                     subplot(211)
%                                                     imagesc(tempCorrMap); colorbar; axis image;
%                                                     % Display ROI
%                                                     rectangle('Position',[seedX seedY seedW seedH],...
%                                                         'Curvature',[1,1],...
%                                                         'LineWidth',2,'LineStyle','-');
%                                                     set(gca,'Xtick',[]); set(gca,'Ytick',[]);
%                                                     xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
%                                                     title(sprintf('%s fcIOS map Seed %d (%s) S%d C%d (%s)\n',PAT.subj_name,r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
%
%                                                     % Show only significant
%                                                     % pixels
%                                                     subplot(212)
%                                                     imagesc(tempCorrMap .* (pValuesMap <= job.pValue), [-1 1]); colorbar; axis image;
%                                                     % Display ROI
%                                                     rectangle('Position',[seedX seedY seedW seedH],...
%                                                         'Curvature',[1,1],...
%                                                         'LineWidth',2,'LineStyle','-');
%                                                     set(gca,'Xtick',[]); set(gca,'Ytick',[]);
%                                                     xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
%                                                     title(sprintf('%s significant pixels (p<%.2f) Seed %d (%s) S%d C%d (%s)\n',PAT.subj_name,job.pValue,r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
%
%                                                     if job.save_figures
%                                                         [~, oldName, oldExt] = fileparts(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
%                                                         % newName = [oldName '_fcIOS_map'];
%                                                         newName = [sprintf('%s_R%02d_S%02d_C%d',PAT.subj_name,r1,s1,c1) '_fcIOS_map'];
%                                                         if isfield(job.IOImatCopyChoice,'IOImatCopy')
%                                                             dir_corrfig = fullfile(dir_patmat,strcat('fig_',job.IOImatCopyChoice.IOImatCopy.NewIOIdir));
%                                                         else
%                                                             dir_corrfig = fullfile(dir_patmat,'fig_corrMap');
%                                                         end
%                                                         if ~exist(dir_corrfig,'dir'), mkdir(dir_corrfig); end
%                                                         % Save as PNG
%                                                         print(h, '-dpng', fullfile(dir_corrfig,newName), '-r300');
%                                                         % Save as a figure
%                                                         saveas(h, fullfile(dir_corrfig,newName), 'fig');
%                                                         % Save as EPS
%                                                         spm_figure('Print', 'Graphics', fullfile(dir_corrfig,newName));
%                                                         % Save as nifti
%                                                         ioi_save_nifti(tempCorrMap, fullfile(dir_corrfig,[newName oldExt]), vx);
%                                                         PAT.fcPAT.corr(1).corrMapName{r1}{s1, c1} = fullfile(dir_corrfig,[newName oldExt]);
%                                                     end
                                        end
                                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        
                                        % Convert Pearson's correlation
                                        % coeff. r to Fisher's z value.
                                        if job.fisherZ
                                            internal_Fisher;
                                        end
                                        % correlation map succesful!
                                        fprintf('Pearson''s correlation coefficient computed. Seed %d (%s) session %d C%d (%s)\n',r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1});
                                        PAT.fcPAT.corr(1).corrMapOK{r1}{s1, c1} = true;
                                    else
                                        % correlation map failed!
                                        PAT.fcPAT.corr(1).corrMapOK{r1}{s1, c1} = false;
                                        fprintf('Pearson''s correlation coefficient failed! Seed %d (%s) S%d C%d (%s)\n',r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1});
                                    end
                                end % if all ROIs
                                % Update progress bar
                                spm_progress_bar('Set', r1);
                            end % ROI/seeds loop
                            % Clear progress bar
                            spm_progress_bar('Clear');
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
                % Save fcIOS data
                save(PAT.fcPAT.corr(1).fname,'seed_based_fcIOS_map')
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
    seed_based_fcIOS_map{r1}{s1,c1}.pearsonDiff = tempCorrMapDiff;
    seed_based_fcIOS_map{r1}{s1,c1}.pValueDiff = pValuesMapDiff;
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
        title(sprintf('%s fcIOS map Seed %d (%s) S%d C%d (%s) Diff\n',PAT.subj_name,r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
        
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
        title(sprintf('%s significant pixels (p<%.2f) Seed %d (%s) S%d C%d (%s) Diff\n',PAT.subj_name,job.pValue,r1,PAT.ROIname{r1},s1,c1,colorNames{1+c1}),'interpreter', 'none', 'FontSize', 14)
        
        if job.save_figures
            [~, oldName, oldExt] = fileparts(PAT.fcPAT.SPM.fnameROInifti{r1}{s1, c1});
            % newName = [oldName '_fcIOS_map'];
            newName = [sprintf('%s_R%02d_S%02d_C%d',PAT.subj_name,r1,s1,c1) '_fcIOS_map_diff'];
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
%     % newName = [oldName '_fcIOS_Zmap'];
%     newName = [sprintf('%s_R%02d_S%02d_C%d',PAT.subj_name,r1,s1,c1) '_fcIOS_Zmap'];
%     dir_fisherZfig = fullfile(dir_patmat,'fig_fisherZ');
%     if ~exist(dir_fisherZfig,'dir'), mkdir(dir_fisherZfig); end
%     % Convert r to z, masking
%     % out non-brain voxels
%     seed_based_fcIOS_map{r1}{s1,c1}.fisher = fisherz(tempCorrMap) .* brainMask;
%     if job.generate_figures
%         % Save as nifti
%         ioi_save_nifti(seed_based_fcIOS_map{r1}{s1,c1}.fisher, fullfile(dir_fisherZfig,[newName oldExt]), vx);
%         % Save masked file as nifti
%         ioi_save_nifti(seed_based_fcIOS_map{r1}{s1,c1}.fisher .* (pValuesMap < job.pValue), fullfile(dir_fisherZfig,[newName '_Masked' oldExt]), vx);
%         PAT.fcPAT.corr(1).zMapName{r1}{s1, c1} = fullfile(dir_fisherZfig,[newName oldExt]);
%         PAT.fcPAT.corr(1).zMapNameMask{r1}{s1, c1} = fullfile(dir_fisherZfig,[newName '_Masked' oldExt]);
%         % Find 1st positive value
%         z1 = sort(seed_based_fcIOS_map{r1}{s1,c1}.fisher(:),1,'ascend');
%         idx1  = find(z1>0, 1, 'first');
%         minPosVal = z1(idx1);
%         
%         % Find 1st negative value
%         z2 = sort(seed_based_fcIOS_map{r1}{s1,c1}.fisher(:),1,'descend');
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
%         titleString     = sprintf('%s seed%d S%d(%s)Z-map',PAT.subj_name,r1,s1,colorNames{1+c1});
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

function fcPAT_display_corrMap
    %% Load correlation data
    tempCorrMapVol = spm_vol(IOI.fcIOS.corr.corrMapName{r1}{s1, c1});
    tempCorrMap = spm_read_vols(tempCorrMapVol);
    [~, ~, oldExt] = fileparts(IOI.fcIOS.SPM.fnameROInifti{r1}{s1, c1});
    newName = [sprintf('%s_R%02d_S%02d_C%d',IOI.subj_name,r1,s1,c1) '_fcIOS_corrMapMasked'];
    dir_corrMapMaskedfig = fullfile(dir_ioimat,'fig_corrMapMasked');
    if ~exist(dir_corrMapMaskedfig,'dir'), mkdir(dir_corrMapMaskedfig); end

    %% Mask out non-brain voxels
    if size(brainMask,1)~= size(tempCorrMap,1)|| size(brainMask,2)~= size(tempCorrMap,2)
        brainMask = ioi_MYimresize(brainMask, [size(tempCorrMap,1) size(tempCorrMap,2)]);
    end
    % Make NaN all the transparent pixels
    tempCorrMap(~brainMask) = NaN;
    y = tempCorrMap;
    IOI.fcIOS.corr.corrMapNameMask{r1}{s1, c1} = fullfile(dir_corrMapMaskedfig,[newName oldExt]);
    % Save NIfTI to use slover
    ioi_save_nifti(y, IOI.fcIOS.corr.corrMapNameMask{r1}{s1, c1}, vx);

    %% Display overlay data and print to png
    % Get parameters for overlay
    anatomical      = IOI.res.file_anat;
    corrMap         = IOI.fcIOS.corr.corrMapNameMask{r1}{s1, c1};
    % Seed annotation dimensions the lower left corner of the bounding rectangle
    % at the point seedX, seedY (the + sign here is due to image rotation)
    seedX = IOI.res.ROI{r1}.center(2) + IOI.res.ROI{r1}.radius;
    seedY = IOI.res.ROI{r1}.center(1) + IOI.res.ROI{r1}.radius;
    % Seed width
    seedW = 2*IOI.res.ROI{r1}.radius;
    % Seed height
    seedH = 2*IOI.res.ROI{r1}.radius;
    % Change seed circle size if shrunk
    if isfield(IOI.res,'shrinkageOn')
        if IOI.res.shrinkageOn == 1
            seedW = seedW * IOI.res.shrink_x;
            seedH = seedH * IOI.res.shrink_y;
        end
    end
    internal_overlay_map(anatomical, corrMap,  job, newName, [seedX seedY seedW seedH]);
end



function [h, varargout] = internal_overlay_map(anatomical, positiveMap,  job, titleString, seedDims)
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
% h = ioi_overlay_map(anatomical,positiveMap,negativeMap,mapRange,titleString)
% INPUTS
% anatomical    NIfTI (.nii) filename with anatomical image for background.
% positiveMap   NIfTI (.nii) filename with positive functional map on the
%               foreground.
% job           Matlab batch jobjob 
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
% rotx = @(theta) [1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];
% roty = @(theta) [cos(theta) 0 sin(theta) 0; 0 1 0 0; -sin(theta) 0 cos(theta) 0; 0 0 0 1];
% rotz = @(theta) [cos(theta) -sin(theta) 0 0; sin(theta) cos(theta) 0 0; 0 0 1 0; 0 0 0 1];
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
slObj.transform = job.transM*translate(-slObj.img(1).vol.dim(1),-slObj.img(1).vol.dim(2));               % Apply affine transformation

% Change figure name
set(slObj.figure,'Name',titleString);

% Pass the slover object as output
varargout{1} = slObj;

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
    newSeedCoord = job.transM*[seedDims(1) seedDims(2) 0 1]' + [slObj.img(1).vol.dim(2) slObj.img(1).vol.dim(1) 0 0]';
    seedDims(1:2) = newSeedCoord(2:-1:1)';
    % Display ROI
    rectangle('Position',seedDims,...
        'Curvature',[1,1],...
        'LineWidth',job.drawCircle.drawCircle_On.circleLW,...
        'LineStyle',job.drawCircle.drawCircle_On.circleLS);
end

% Save figure
pat_save_figs(job, h, figSuffix, scanIdx, c1, r1, figsFolder);

% % Save as PNG at the user-defined resolution
% print(h, '-dpng', ...
%     fullfile(job.parent_results_dir{1}, titleString),...
%     sprintf('-r%d',job.figRes));
% 
% % Return the property to its default
% set(h, 'units', 'pixels')
% close(h)

end % internal_overlay_map

% EOF
