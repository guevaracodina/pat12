function out = pat_network_analyses_run(job)
% Network analysis. Performs graph theoretical measures.
% Needs CONN – fMRI functional connectivity toolbox (v.13)
% Gabrieli Lab. McGovern Institute for Brain Research
% Massachusetts Institute of Technology
% http://www.nitrc.org/projects/conn
% Susan Whitfield-Gabrieli
% Alfonso Nieto-Castanon
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

tic
% CONN toolbox v.13
addpath(genpath('D:\Edgar\conn'))
% current folder
currFolder = pwd;
% Load first PAT matrix
[PAT PATmat dir_patmat] = pat_get_PATmat(job, 1);
% Get colors to include information
IC = job.IC;
colorNames = fieldnames(PAT.color);
% Flag to indicate replacement of seeds names
REPLACE_ROI_NAME = false;
% Seeds names
newROIname = {  'Cg_L'      % Cingulate cortex
                'Cg_R'
                'M_L'       % Motor cortex
                'M_R'
                'S1HL_L'    % hindlimb primary somatosensory cortex
                'S1HL_R'
                'S1FL_L'    % forelimb primary somatosensory cortex
                'S1FL_R'
                'S1BF_L'    % barrel field primary somatosensory cortex
                'S1BF_R'
                'S2_L'      % secondary somatosensory cortex
                'S2_R'
                'cc_L'      % corpus callosum
                'cc_R'
                'LV_L'      % Lateral ventricle
                'LV_R'
                'CPu_L'     % Caudate putamen
                'CPu_R' };
% Get ROIs
[all_ROIs selected_ROIs] = pat_get_rois(job);
if all_ROIs
    % All the ROIs
    nROI = numel(PAT.ROI.ROIname);
    % Index vector of ROIs
    roiIndex = 1:nROI;
else
    nROI = numel(selected_ROIs);
    roiIndex = selected_ROIs;
end
if REPLACE_ROI_NAME
    % Variable with the source rois names {1 x nROI}
    names = newROIname';
    % Variable with the target rois names {1 x nROI}
    names2 = names;
else
    % Variable with the source rois names {1 x nROI}
    names = PAT.ROI.ROIname';
    % Variable with the target rois names {1 x nROI}
    names2 = names;
end
% Preallocate connectivity (Fisher's Z) values [nROI x nROI x length(job.PATmat)]
Z = zeros([nROI nROI length(job.PATmat)]);
% Preallocate connectivity (correlation) values [nROI x nROI x length(job.PATmat)]
r = zeros([nROI nROI length(job.PATmat)]);
% Go to network results folder
cd(job.results_dir{1});
% Loop over sessions
s1 = 1;
% Initialize progress bar
spm_progress_bar('Init', length(PAT.nifti_files), sprintf('Network analysis'), 'Contrasts');
pat_text_waitbar(0, 'Network analysis, please wait...');
% Loop over available colors
for c1 = 1:length(PAT.nifti_files)
    doColor = pat_doColor(PAT,c1,IC);
    if doColor
        % skip B-mode
        if ~(PAT.color.eng(c1)==PAT.color.Bmode)
            %% Main processing loop
            % Create filename coherent with conn_network.m
            currentFname = fullfile(job.results_dir{1}, sprintf('resultsROI_Condition%02d_%s', s1, colorNames{1+c1}));
            % loop over scans
            for scanIdx = 1:numel(job.PATmat)
                try
                    %Load PAT.mat information
                    [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
                    if REPLACE_ROI_NAME
                        PAT.ROIname = newROIname;
                    end
                    if ~isfield(PAT.jobsdone, 'corrOK') % correlation analysis OK
                        fprintf('No correlation analysis available for subject %d of %d... skipping network analysis\n', scanIdx, length(job.PATmat));
                    else
                        if ~isfield(PAT.jobsdone,'networkOK') || job.force_redo
                            % Check if seed to seed correlation matrix was computed
                            if ~PAT.fcPAT.corr.corrMatrixOK
                                [seed2seedCorrMat seed2seedCorrMatDiff PAT.fcPAT.corr(1).corrMatrixFname PAT.fcPAT.corr(1).corrMatrixDiffFname] = pat_roi_corr(job, scanIdx);
                                % Save seed-to-seed correlation data
                                save(PAT.fcPAT.corr(1).corrMatrixFname,'seed2seedCorrMat')
                                % Save seed-to-seed derivatives correlation data
                                save(PAT.fcPAT.corr(1).corrMatrixDiffFname,'seed2seedCorrMatDiff')
                            end
                            % Check if mouse is tratment (1) or control (0)
                            % isTreatment(scanIdx,1) = ~isempty(regexp(PAT.subj_name, [job.treatmentString '[0-9]+'], 'once'));
                            % Load seed to seed correlation matrix
                            load(PAT.fcPAT.corr(1).corrMatrixFname,'seed2seedCorrMat')
                            % Update data in r
                            r(:,:,scanIdx) = seed2seedCorrMat{1}{s1, c1};
                            % Fisher transform
                            seed2seedCorrMat{1}{s1, c1} = fisherz(seed2seedCorrMat{1}{s1, c1});
                            % Replace Inf by NaN
                            seed2seedCorrMat{1}{s1, c1}(~isfinite(seed2seedCorrMat{1}{s1, c1})) = NaN;
                            % Update data in Z
                            Z(:,:,scanIdx) = seed2seedCorrMat{1}{s1, c1};
                            % Create filename coherent with conn_network.m
                            PAT.fcPAT.corr.networkDataFname{s1, c1} = currentFname;
                            % Network analysis succesful!
                            PAT.jobsdone.networkOK = true;
                            % Save PAT matrix
                            save(PATmat,'PAT');
                        end % network OK or redo job
                    end % correlation maps OK
                    out.PATmat{scanIdx} = PATmat;
                catch exception
                    out.PATmat{scanIdx} = PATmat;
                    disp(exception.identifier)
                    disp(exception.stack(1))
                end
            end % loop over scans
            % Sort by groups
            [job, Z, r] = sort_PATmat(job, Z, r);
            orderedPATlist = job.PATmat;
            % Save resultsROI_Condition*_Color
            save(PAT.fcPAT.corr.networkDataFname{s1, c1}, ...
                'Z', 'r', 'names', 'names2', 'orderedPATlist');
            
            % First level analysis (within subject)
            results = first_level_analysis(job, PAT, s1, c1, roiIndex);
            
            % Second level analysis (between subjects)
            ss = second_level_analysis(job, PAT, s1, c1, results);
            
            % Functional connectivity diagram
            % fc_diagram(job, PAT, s1, c1, results, ss);
            
            % Update progress bar
            spm_progress_bar('Set', c1);
            % Update progress bar
            pat_text_waitbar(c1/length(PAT.nifti_files), sprintf('Processing contrast %d from %d', c1, length(PAT.nifti_files)));
        end
    end
end % colors loop
% Return to working folder
cd(currFolder);
% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear');
fprintf('Elapsed time: %s', datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS\n') );
end % pat_network_analyses_run

function [job, newZ, newr] = sort_PATmat(job, Z, r)
% Sorts PAT matrix according to groups (Ctrl, LPS, and LPS+IL-1Ra)
if numel([job.PATmatIdxCtrl job.PATmatIdxLPS job.PATmatIdxIL1Ra]) == numel(job.PATmat)
    newPATmat = cell(size(job.PATmat));
    newZ = zeros(size(Z));
    newr = zeros(size(r));
    % Update indices
    job.PATmatIdxCtrlSorted = 1:numel(job.PATmatIdxCtrl);
    job.PATmatIdxLPSSorted = numel(job.PATmatIdxCtrl)+1:numel(job.PATmatIdxCtrl)+numel(job.PATmatIdxLPS);
    job.PATmatIdxIL1RaSorted = numel(job.PATmatIdxCtrl)+numel(job.PATmatIdxLPS)+1:numel(job.PATmatIdxCtrl)+numel(job.PATmatIdxLPS)+numel(job.PATmatIdxIL1Ra);
    % Control
    newPATmat(job.PATmatIdxCtrlSorted) = job.PATmat(job.PATmatIdxCtrl);
    newZ(:,:,job.PATmatIdxCtrlSorted) = Z(:,:,job.PATmatIdxCtrl);
    newr(:,:,job.PATmatIdxCtrlSorted) = r(:,:,job.PATmatIdxCtrl);
    % LPS
    newPATmat(job.PATmatIdxLPSSorted) = job.PATmat(job.PATmatIdxLPS);
    newZ(:,:,job.PATmatIdxLPSSorted) = Z(:,:,job.PATmatIdxLPS);
    newr(:,:,job.PATmatIdxLPSSorted) = r(:,:,job.PATmatIdxLPS);
    % LPS + IL-1Ra
    newPATmat(job.PATmatIdxIL1RaSorted) = job.PATmat(job.PATmatIdxIL1Ra);
    newZ(:,:,job.PATmatIdxIL1RaSorted) = Z(:,:,job.PATmatIdxIL1Ra);
    newr(:,:,job.PATmatIdxIL1RaSorted) = r(:,:,job.PATmatIdxIL1Ra);
    % Update PAT matrix list
    job.PATmat = newPATmat;
else
    error('Wrong number of indexed subjects')
end
end % sort_PATmat

function results = first_level_analysis(job, PAT, s1, c1, roiIndex)
% Process network first-level analysis here (within subject)
colorNames = fieldnames(PAT.color);
varName = sprintf('results_S%02d_%s', s1, colorNames{1+c1});
if job.opt1stLvl.threshold ~= 0,
    results = conn_network(PAT.fcPAT.corr.networkDataFname{s1, c1}, ...
        roiIndex, job.opt1stLvl.measures, job.opt1stLvl.normalType, job.opt1stLvl.threshold);
else
    % Creates figure with small-world properties
    [results, h1] = conn_network(PAT.fcPAT.corr.networkDataFname{s1, c1}, ...
        roiIndex, job.opt1stLvl.measures, job.opt1stLvl.normalType);
    if job.generate_figures
        figName = get(h1, 'Name');
        set(h1, 'Name', [figName ' ' varName]);
        if job.save_figures
            % Specify window units
            set(h1, 'units', 'inches')
            % Change figure and paper size
            set(h1, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
            set(h1, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
            % Save as PNG
            print(h1, '-dpng', fullfile(job.results_dir{1},[varName '_properties.png']), sprintf('-r%d',job.optFig.figRes));
            % Save as a figure
            saveas(h1, fullfile(job.results_dir{1},[varName '_properties.fig']), 'fig');
            % Return the property to its default
            set(h1, 'units', 'pixels')
        end
    else
        close(h1);
    end
end
fclose('all');
end % first_level_analysis

function ss = second_level_analysis(job, PAT, s1, c1, results) %#ok
% Second-level analysis
colorNames = fieldnames(PAT.color);
varName = sprintf('results_S%02d_%s', s1, colorNames{1+c1});
% Group indices
controlGroupIdx     = job.PATmatIdxCtrlSorted;
LPSGroupIdx         = job.PATmatIdxLPSSorted;
IL1RaIdx            = job.PATmatIdxIL1RaSorted;
% current results file name
currentResults = fullfile(job.results_dir{1}, [varName '.mat']);
% Prepare design matrix ss
ss(1).n = numel(job.PATmat);
% Subjects in group 1 (Control), 2 (LPS), 3 (LPS+IL-1Ra) and grand mean.
ss(1).X = zeros(ss.n, 3+1);
ss.X(controlGroupIdx,1) = 1;
ss.X(LPSGroupIdx,2)     = 1;
ss.X(IL1RaIdx,3)        = 1;
% Grand mean
ss.X(:,4)               = 1;
% 1: one-sample t-test, 2: Two-sample t-test, 3: multiple regression
ss(1).model = job.opt2ndLvl.model;
% Regressor names
ss(1).Xname = job.opt2ndLvl.Xname;
% Contrast
ss(1).C = { job.opt2ndLvl.C };
% Contrast name (append color name)
ss(1).Cname = { sprintf('%s_(%s)',job.opt2ndLvl.Cname, colorNames{1+c1}) };
% ask types: none, missing, all
ask = job.opt2ndLvl.ask;
ss(1).ask = ask;

% Save results and design matrix ss in .mat file
save(currentResults, 'results', 'ss',...
    'controlGroupIdx', 'LPSGroupIdx', 'IL1RaIdx');

% Second-level analysis (between subjects) (updates currentResults .mat file)
ss = conn_network_results(currentResults, ask);

h = gcf;
if job.generate_figures
    figName = sprintf('results_%s_%s_2nd_level', colorNames{1+c1}, job.opt2ndLvl.Cname);
    set(h,'Name',figName)
    if job.save_figures
        % Specify window units
        set(h, 'units', 'inches')
        % Change figure and paper size
        set(h, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(h, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Save as PNG
        print(h, '-dpng', fullfile(job.results_dir{1},[figName '.png']), sprintf('-r%d',job.optFig.figRes));
        % Save as a figure
        saveas(h, fullfile(job.results_dir{1},[figName '.fig']), 'fig');
        % Return the property to its default
        set(h, 'units', 'pixels')
        close(h); % close figure anyway
    end
end
end % second_level_analysis

function fc_diagram(job, PAT, s1, c1, results, ss)
% Functional connectivity diagram. Edge thicknesses depend on the average
% correlation coefficients from the 2 groups. Circle sizes are proportional to
% global efficiency of each seed. Positive correlations are depicted in warm
% colors. Negative correlations are depicted in cool colors. The letter in the
% circle indicates name of the seeds.
if job.generate_figures
    % Retrieve correlation values
    load(PAT.fcPAT.corr.networkDataFname{s1, c1});
    colorNames = fieldnames(PAT.color);
    nColors = 256;
    posCmap = hot(nColors);
    negCmap = winter(nColors);
    
    %% NaCl (control) group fc diagram
    varName = sprintf('results_S%02d_%s_%s', s1, colorNames{1+c1}, ss.Xname{1});
    % load control group anatomical template (NC09) idxSubject = 13
    % [PAT PATmat dir_patmat] = pat_get_PATmat(job,10);
    load('D:\Edgar\Data\IOS_Carotid_Res\12_10_18,NC09\PAT.mat')
    % Read anatomical image
    imAnatVol = spm_vol(PAT.res.file_anat);
    NaCl_imAnat = spm_read_vols(imAnatVol)';
    % Read brain mask
    maskVol = spm_vol(PAT.fcPAT.mask.fname);
    NaCl_mask = spm_read_vols(maskVol)';
    % Display anatomical image
    hCtrl = figure; set(hCtrl,'color','k');
    % Allow printing of black background
    set(hCtrl, 'InvertHardcopy', 'off');
    % Change window name
    set(hCtrl,'Name',[varName '_fc_diagram'])
    imagesc(NaCl_imAnat .* NaCl_mask); axis image; colormap(gray(256));
    set(gca, 'XTick', []); set(gca, 'YTick', []);
    % Get group indices
    ctrlIdx = ss.X(:,1);
    % Get correlation values for controls only
    rCtrl = r(:,:,find(ctrlIdx));
    % Get global efficiency values for controls only
    GeCtrl = results.measures.GlobalEfficiency_roi(find(ctrlIdx),:);
    % Get average correlation values (for the edges)
    rMean = nanmean(rCtrl,3);
    globalrMean = nanmean(r,3);
    % Get ROI average global efficiency
    GE_roiMean = nanmean(GeCtrl);
    globalGE = nanmean(results.measures.GlobalEfficiency_roi);
    % Seed coordinates
    seedCoord = {
        [183 86];
        [109 87];
        [191 122];
        [103 124];
        [156 127];
        [137 127];
        [239 189];
        [56 194];
        [167 236];
        [143 239];
        [221 290];
        [83 293]
        };
    
    % Display edges (correlation values)
    for iROIsource = 1:numel(results.rois)
        for iROItarget = 1:numel(results.rois)
            if iROIsource ~= iROItarget
                if abs(rMean(iROIsource, iROItarget)) > job.fc_diagram.rThreshold
                    % Draw edge
                    hEdge = line([seedCoord{iROIsource}(1) seedCoord{iROItarget}(1)],...
                        [seedCoord{iROIsource}(2) seedCoord{iROItarget}(2)],...
                        'LineStyle','-');
                    % Edge width
                    LW = (job.fc_diagram.edgeMaxThick * abs(rMean(iROIsource, iROItarget))) / max(abs(globalrMean(:)));
                    set(hEdge, 'LineWidth', LW);
                    % Edge color
                    if rMean(iROIsource, iROItarget) > 0
                        % Warm colors
                        RGB = ind2rgb(round(nColors*rMean(iROIsource, iROItarget) / max(abs(globalrMean(:)))), posCmap);
                    else
                        % Cool colors
                        RGB = ind2rgb(round(nColors*abs(rMean(iROIsource, iROItarget)) /max(abs(globalrMean(:)))), negCmap);
                    end
                    set(hEdge, 'Color', RGB);
                end
            end
        end
    end
    
    % Display nodes (seeds)
    for iROI = 1:numel(results.rois)
        w = (job.fc_diagram.cirleMaxRad * GE_roiMean(iROI)) / max(globalGE);
        h = w;
        % This will center the circles at the true coordinates
        x = seedCoord{iROI}(1) - w/2;
        y = seedCoord{iROI}(2) - h/2;
        % Display ROI
        hSeed = rectangle('Position',[x y w h],...
            'Curvature',[1,1],...
            'LineWidth',job.fc_diagram.circleLW,...
            'LineStyle',job.fc_diagram.circleLS);
        set (hSeed, 'FaceColor', job.fc_diagram.circleFC);
        set (hSeed, 'EdgeColor', job.fc_diagram.circleEC);
    end
    
    if job.save_figures
        % Specify window units
        set(hCtrl, 'units', 'inches')
        % Change figure and paper size
        set(hCtrl, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(hCtrl, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Save as PNG
        print(hCtrl, '-dpng', fullfile(job.results_dir{1},[varName '_fc_diagram.png']), sprintf('-r%d',job.optFig.figRes));
        % Save as a figure
        saveas(hCtrl, fullfile(job.results_dir{1},[varName '_fc_diagram.fig']), 'fig');
        % Return the property to its default
        set(hCtrl, 'units', 'pixels')
        close(hCtrl);
    end
    
    
    %% CaCl2 (treatment) group fc diagram
    varName = sprintf('results_S%02d_%s_%s', s1, colorNames{1+c1}, ss.Xname{2});
    % load control group anatomical template (CC10) idxSubject = 14
    % [PAT PATmat dir_patmat] = pat_get_PATmat(job,10);
    % Read anatomical image
    imAnatVol = spm_vol(PAT.res.file_anat);
    CaCl2_imAnat = spm_read_vols(imAnatVol)';
    % Display anatomical image
    hTreat = figure; set(hTreat,'color','k');
    % Allow printing of black background
    set(hTreat, 'InvertHardcopy', 'off');
    % Change window name
    set(hTreat,'Name',[varName '_fc_diagram'])
    % Read brain mask
    maskVol = spm_vol(PAT.fcPAT.mask.fname);
    CaCl2_mask = spm_read_vols(maskVol)';
    imagesc(CaCl2_imAnat .* CaCl2_mask); axis image; colormap(gray(256));
    set(gca, 'XTick', []); set(gca, 'YTick', []);
    % Get group indices
    treatIdx = ss.X(:,2);
    % Get correlation values for controls only
    rTreat = r(:,:,find(treatIdx));
    % Get global efficiency values for controls only
    GeTreat = results.measures.GlobalEfficiency_roi(find(treatIdx),:);
    % Get average correlation values (for the edges)
    rMean = nanmean(rTreat,3);
    globalrMean = nanmean(r,3);
    % Get ROI average global efficiency
    GE_roiMean = nanmean(GeTreat);
    globalGE = nanmean(results.measures.GlobalEfficiency_roi);
    % Seed coordinates
    seedCoord = {
        [183 86];
        [109 87];
        [191 122];
        [103 124];
        [156 127];
        [137 127];
        [239 189];
        [56 194];
        [167 236];
        [143 239];
        [221 290];
        [83 293]
        };
    
    % Display edges (correlation values)
    for iROIsource = 1:numel(results.rois)
        for iROItarget = 1:numel(results.rois)
            if iROIsource ~= iROItarget
                % Draw edge
                hEdge = line([seedCoord{iROIsource}(1) seedCoord{iROItarget}(1)],...
                    [seedCoord{iROIsource}(2) seedCoord{iROItarget}(2)],...
                    'LineStyle','-');
                % Edge width
                LW = (job.fc_diagram.edgeMaxThick * abs(rMean(iROIsource, iROItarget))) / max(abs(globalrMean(:)));
                set(hEdge, 'LineWidth', LW);
                % Edge color
                if rMean(iROIsource, iROItarget) > 0
                    % Warm colors
                    RGB = ind2rgb(round(nColors*rMean(iROIsource, iROItarget) / max(abs(globalrMean(:)))), posCmap);
                else
                    % Cool colors
                    RGB = ind2rgb(round(nColors*abs(rMean(iROIsource, iROItarget)) /max(abs(globalrMean(:)))), negCmap);
                end
                set(hEdge, 'Color', RGB);
            end
        end
    end
    
    % Display nodes (seeds)
    for iROI = 1:numel(results.rois)
        w = (job.fc_diagram.cirleMaxRad * GE_roiMean(iROI)) / max(globalGE);
        h = w;
        % This will center the circles at the true coordinates
        x = seedCoord{iROI}(1) - w/2;
        y = seedCoord{iROI}(2) - h/2;
        % Display ROI
        hSeed = rectangle('Position',[x y w h],...
            'Curvature',[1,1],...
            'LineWidth',job.fc_diagram.circleLW,...
            'LineStyle',job.fc_diagram.circleLS);
        set (hSeed, 'FaceColor', job.fc_diagram.circleFC);
        set (hSeed, 'EdgeColor', job.fc_diagram.circleEC);
    end
    
    if job.save_figures
        % Specify window units
        set(hTreat, 'units', 'inches')
        % Change figure and paper size
        set(hTreat, 'Position', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        set(hTreat, 'PaperPosition', [0.1 0.1 job.optFig.figSize(1) job.optFig.figSize(2)])
        % Save as PNG
        print(hTreat, '-dpng', fullfile(job.results_dir{1},[varName '_fc_diagram.png']), sprintf('-r%d',job.optFig.figRes));
        % Save as a figure
        saveas(hTreat, fullfile(job.results_dir{1},[varName '_fc_diagram.fig']), 'fig');
        % Return the property to its default
        set(hTreat, 'units', 'pixels')
        close(hTreat);
    end
    
end % generate figures
end % fc_diagram

% EOF
