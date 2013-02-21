function [corrMatrixRaw corrMatrixRawFname] = pat_roi_corr_raw(job,SubjIdx)
% Gets the correlation matrix for every seed/ROI raw time trace. (Before
% filtering/downsampling and GLM regression).
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Get sessions info
% [all_sessions selected_sessions] = ioi_get_sessions(job);
all_sessions = 1;
selected_sessions = [];
%Load IOI.mat information
[IOI IOImat dir_ioimat]= ioi_get_IOI(job,SubjIdx);

if ~isfield(IOI.res, 'ROIOK') % ROI OK
    disp(['No ROIs available for subject ' int2str(SubjIdx) ' ... skipping raw seed to seed correlation matrix']);
else
    % Get colors to include information
    IC = job.IC;
    colorNames = fieldnames(IOI.color);
%     [all_ROIs selected_ROIs] = ioi_get_ROIs(job);
    all_ROIs = 1;
    selected_ROIs = [];
    nROI = 1:length(IOI.res.ROI); % All the ROIs
    
    % Load raw ROI data in cell ROI
    load(IOI.ROI.ROIfname)
    
    % Loop over sessions
    for s1=1:length(IOI.sess_res)
        if all_sessions || sum(s1==selected_sessions)
            % Loop over available colors
            for c1=1:length(IOI.sess_res{s1}.fname)
                doColor = ioi_doColor(IOI,c1,IC);
                if doColor && IOI.res.ROIOK
                    % Loop over ROI/seeds
                    for r1 = nROI,
                        if ~isempty(ROI{r1}{s1,c1})
                            % Preallocate map for the seed-to-seed correlation matrix
                            tVector = numel(ROI{r1}{s1,c1});
                            roiOK = true;
                            break; % end loop for as soon as a good ROI is found
                        else
                            roiOK = false;
                            fprintf('time vector size NOT found for seed %d, session %d, (%s)!\n',r1,s1,colorNames{1+c1});
                        end
                    end
                    if roiOK
                        % Preallocate
                        roiMatrixRaw = zeros([tVector numel(nROI)]);
                        % Loop over ROI/seeds
                        for r1 = nROI,
                            if all_ROIs || sum(r1==selected_ROIs)
                                if ~isempty(ROI{r1}{s1,c1})
                                    roiMatrixRaw(:, r1) = ROI{r1}{s1,c1};
                                else
                                    roiMatrixRaw = [];
                                end
                            end
                        end % loop over sessions
                        % Compute seed-to-seed correlation matrix
                        corrMatrixRaw{1}{s1,c1} = corrcoef(roiMatrixRaw);
                        
                        if ~isempty(ROI{r1}{s1,c1})
                            if job.generate_figures
                                h = figure; set(gcf,'color','w')
                                imagesc(corrMatrixRaw{1}{s1,c1},[-1 1]); axis image; colorbar
                                colormap(get_colormaps('rwbdoppler'));
                                set(gca,'yTick',1:numel(IOI.res.ROI))
                                set(gca,'yTickLabel',IOI.ROIname)
                                set(gca,'xTickLabel',[])
                                newName = sprintf('%s_S%d_C%d(%s)_s2sCorrMatRaw',IOI.subj_name,s1,c1,colorNames{1+c1});
                                title(newName,'interpreter','none')
                                if isfield(job, 'figSize')
                                    % Specify window units
                                    set(h, 'units', 'inches')
                                    % Change figure and paper size
                                    set(h, 'Position', [0.1 0.1 job.figSize(1) job.figSize(2)])
                                    set(h, 'PaperPosition', [0.1 0.1 job.figSize(1) job.figSize(2)])
                                end
                                if job.save_figures
                                    % Save as EPS
                                    spm_figure('Print', 'Graphics', fullfile(dir_ioimat,newName));
                                    if isfield(job, 'figSize') && isfield(job, 'figRes')
                                        % Save as PNG
                                        print(h, '-dpng', fullfile(dir_ioimat,newName), '-r300');
                                    else
                                        % Save as PNG
                                        print(h, '-dpng', fullfile(dir_ioimat,newName), sprintf('-r%d',job.figRes));
                                    end
                                end
                                if isfield(job, 'figSize') && isfield(job, 'figRes')
                                    % Return the property to its default
                                    set(h, 'units', 'pixels')
                                end
                                close(h)
                            end
                        else
                            % Do not plot (empty matrix)
                        end
                    else
                        % No ROIs are correctly regressed
                        corrMatrixRaw{1}{s1,c1} = [];
                    end
                end
            end % loop over colors
        end
    end % loop over sessions
    corrMatrixRawFname = fullfile(dir_ioimat,'s2sCorrMatRaw.mat');
end % ROIs ok

% EOF
