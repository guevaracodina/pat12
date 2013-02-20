function [corrMatrix corrMatrixDiff corrMatrixFname corrMatrixDiffFname] = pat_roi_corr(job,SubjIdx)
% Gets the correlation matrix for every seed/ROI time trace.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Get sessions info
[all_sessions selected_sessions] = ioi_get_sessions(job);
%Load IOI.mat information
[IOI IOImat dir_ioimat]= ioi_get_IOI(job,SubjIdx);

if ~isfield(IOI.fcIOS.SPM, 'GLMOK') % GLM OK
    disp(['No GLM regression available for subject ' int2str(SubjIdx) ' ... skipping seed to seed correlation matrix']);
else
    % Get colors to include information
    IC = job.IC;
    colorNames = fieldnames(IOI.color);
    [all_ROIs selected_ROIs] = ioi_get_ROIs(job);
    nROI = 1:length(IOI.res.ROI); % All the ROIs
    
    % Load regressed ROI data in cell ROIregress
    load(IOI.fcIOS.SPM.fnameROIregress)
    
    % Loop over sessions
    for s1=1:length(IOI.sess_res)
        if all_sessions || sum(s1==selected_sessions)
            % Loop over available colors
            for c1=1:length(IOI.sess_res{s1}.fname)
                doColor = ioi_doColor(IOI,c1,IC);
                if doColor
                    % Loop over ROI/seeds
                    for r1 = nROI,
                        if IOI.fcIOS.SPM.ROIregressOK{r1}{s1,c1}
                            % Preallocate map for the seed-to-seed correlation matrix
                            tVector = numel(ROIregress{r1}{s1,c1});
                            if isfield (job,'derivative')
                                tVectorDiff = numel(ROIregress{r1}{s1,c1})-1;
                            end
                            % fprintf('time vector size found for seed
                            % %d\n',r1);
                            roiOK = true;
                            break; % end loop for as soon as a good ROI is found
                        else
                            roiOK = false;
                            fprintf('time vector size NOT found for seed %d, session %d, (%s)!\n',r1,s1,colorNames{1+c1});
                        end
                    end
                    if roiOK
                        % Preallocate
                        roiMatrix = zeros([tVector numel(nROI)]);
                        if isfield (job,'derivative')
                            roiMatrixDiff = zeros([tVectorDiff numel(nROI)]);
                        end
                        % Loop over ROI/seeds
                        for r1 = nROI,
                            if all_ROIs || sum(r1==selected_ROIs)
                                if IOI.fcIOS.SPM.ROIregressOK{r1}{s1,c1}
                                    roiMatrix(:, r1) = ROIregress{r1}{s1,c1};
                                    if isfield (job,'derivative')
                                        roiMatrixDiff(:, r1) = diff(ROIregress{r1}{s1,c1});
                                    end
                                else
                                    roiMatrix = [];
                                    roiMatrixDiff = [];
                                end
                            end
                        end % loop over sessions
                        % Compute seed-to-seed correlation matrix
                        corrMatrix{1}{s1,c1} = corrcoef(roiMatrix);
                        if isfield (job,'derivative')
                            corrMatrixDiff{1}{s1,c1} = corrcoef(roiMatrixDiff);
                        end
                        if IOI.fcIOS.SPM.ROIregressOK{r1}{s1,c1}
                            if job.generate_figures
                                h = figure; set(gcf,'color','w')
                                imagesc(corrMatrix{1}{s1,c1},[-1 1]); axis image; colorbar
                                colormap(get_colormaps('rwbdoppler'));
                                set(gca,'yTick',1:numel(IOI.res.ROI))
                                set(gca,'yTickLabel',IOI.ROIname)
                                set(gca,'xTickLabel',[])
                                newName = sprintf('%s_S%d_C%d(%s)_s2sCorrMat',IOI.subj_name,s1,c1,colorNames{1+c1});
                                title(newName,'interpreter','none')
                                if job.save_figures
                                    % Save as EPS
                                    spm_figure('Print', 'Graphics', fullfile(dir_ioimat,newName));
                                    % Save as PNG
                                    print(h, '-dpng', fullfile(dir_ioimat,newName), '-r300');
                                end
                                close(h)
                                if isfield (job,'derivative')
                                    h = figure; set(gcf,'color','w')
                                    imagesc(corrMatrixDiff{1}{s1,c1},[-1 1]); axis image; colorbar
                                    colormap(get_colormaps('rwbdoppler'));
                                    set(gca,'yTick',1:numel(IOI.res.ROI))
                                    set(gca,'yTickLabel',IOI.ROIname)
                                    set(gca,'xTickLabel',[])
                                    newName = sprintf('%s_S%d_C%d(%s)_s2sCorrMatDiff',IOI.subj_name,s1,c1,colorNames{1+c1});
                                    title(newName,'interpreter','none')
                                    if job.save_figures
                                        % Save as EPS
                                        spm_figure('Print', 'Graphics', fullfile(dir_ioimat,newName));
                                        % Save as PNG
                                        print(h, '-dpng', fullfile(dir_ioimat,newName), '-r300');
                                    end
                                    close(h)
                                end
                            end
                        else
                            % Do not plot (empty matrix)
                        end
                    else
                        % No ROIs are correctly regressed
                        corrMatrix{1}{s1,c1} = [];
                        corrMatrixDiff{1}{s1,c1} = [];
                    end
                end
            end % loop over colors
        end
    end % loop over sessions
    corrMatrixFname = fullfile(dir_ioimat,'s2sCorrMat.mat');
    corrMatrixDiffFname = fullfile(dir_ioimat,'s2sCorrMatDiff.mat');
end % GLM regression ok

% EOF
