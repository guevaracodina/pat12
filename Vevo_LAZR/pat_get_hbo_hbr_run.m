function out = pat_get_hbo_hbr_run(job)
% Get HbO & HbR from HbT & SO2. For the time being, process only seed-to-seed
% correlation matrix, not the whole 4-D data.
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
% scans loop
for scanIdx = 1: numel(job.PATmat);
    try
        eTime = tic;
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        % Force all colors except B-mode
        IC = job.IC;
        if ~isfield(PAT.jobsdone, 'corrOK') % GLM OK
            fprintf('No correlation matrix available for %s. Scan %d of %d ... skipping HbO&HbR extraction\n',scanName, scanIdx, length(job.PATmat));
        else
            if ~isfield(PAT.jobsdone,'HbOHbROK') || job.force_redo
                
                % Check if PA is raw.pamode
                if pat_isVEVOraw(job)
                    % Update colors
                    PAT.color.eng = strcat(PAT.color.eng,'O','R');
                    PAT.color.HbO = 'O';
                    PAT.color.HbR = 'R';
                    colorNames = fieldnames(PAT.color);
                    % Update nifti_files
                    PAT.nifti_files(4:5) = {'NonExistentHbOFile' 'NonExistentHbRFile'};
                    % Update affine matrix
                    PAT.nifti_files_affine_matrix(4:5) = {'NonExistentHbOMatrix' 'NonExistentHbRMatrix'};
                    % Get regressed ROIs
                    load(PAT.fcPAT.SPM.fnameROIregress);
                    nROI = 1:length(PAT.res.ROI); % All the ROIs
                    % Load regressed ROI data in cell ROIregress
                    load(PAT.fcPAT.SPM.fnameROIregress)
                    % Loop over ROI/seeds
                    for r1 = nROI,
                        if (all_ROIs || sum(r1==selected_ROIs)) && ~isempty(ROIregress{r1})
                            % Compute HbO(4) & HbR(5) regressed ROIs
                            [ROIregress{r1}{4} ROIregress{r1}{5}] = pat_get_hbo_hbr(ROIregress{r1}{1}, ROIregress{r1}{2});
                            % Fill out SEM and standard deviation
                            ROIregressStd{r1}{4} = zeros(size(ROIregress{r1}{4}));
                            ROIregressStd{r1}{5} = zeros(size(ROIregress{r1}{5}));
                            ROIregressSem{r1}{4} = zeros(size(ROIregress{r1}{4}));
                            ROIregressSem{r1}{5} = zeros(size(ROIregress{r1}{5}));
                            PAT.fcPAT.SPM.ROIregressOK{r1}{4} = true;
                            PAT.fcPAT.SPM.ROIregressOK{r1}{5} = true;
                        end
                    end
                    % Update scrubbing data
                    load(PAT.motion_parameters.scrub.fname)
                    DVARSmask{4} = DVARSmask{1} | DVARSmask{2};
                    DVARSmask{5} = DVARSmask{1} | DVARSmask{2};
                    FDmask{4} = FDmask{1} | FDmask{2};
                    FDmask{5} = FDmask{1} | FDmask{2};
                    scrubMask{4} = scrubMask{1} & scrubMask{2};
                    scrubMask{5} = scrubMask{1} & scrubMask{2};
                    frames2keep(4) = numel(find(~scrubMask{4}));
                    frames2keep(5) = numel(find(~scrubMask{5}));
                    totalFrames(4) = numel(scrubMask{4});
                    totalFrames(5) = numel(scrubMask{5});
                    scrubFlag(4:5) = true;
                    scrubPercent(4:5) = 100 * frames2keep(4:5) ./ totalFrames(4:5);
                    % Update scrubbing file
                    PAT.motion_parameters(1).scrub(1).fname = fullfile(dir_patmat,'scrubbing.mat');
                    save(PAT.motion_parameters(1).scrub(1).fname, 'scrubFlag', 'scrubPercent',...
                    'frames2keep', 'totalFrames', 'scrubMask', 'DVARSmask', 'FDmask');
                    % Update regressed ROI filename
                    fnameROIregress = fullfile(dir_patmat,'ROIregress.mat');
                    % Save updated regressed ROIs
                    save(fnameROIregress,'ROIregress', 'ROIregressStd', 'ROIregressSem');
                    % Identify in PAT the file name of the time series
                    PAT.fcPAT.SPM(1).fnameROIregress = fnameROIregress;
                    % Need to save PAT matrix before calling pat_roi_corr
                    save(PATmat,'PAT');
                    % Compute seed to seed correlation matrix
                    [seed2seedCorrMat seed2seedCorrMatDiff PAT.fcPAT.corr(1).corrMatrixFname PAT.fcPAT.corr(1).corrMatrixDiffFname] = pat_roi_corr(job, scanIdx);
                    % seed-to-seed correlation succesful!
                    PAT.fcPAT.corr(1).corrMatrixOK = true;
                    % Save seed-to-seed correlation data
                    save(PAT.fcPAT.corr(1).corrMatrixFname,'seed2seedCorrMat')
                    % Save seed-to-seed derivatives correlation data
                    save(PAT.fcPAT.corr(1).corrMatrixDiffFname,'seed2seedCorrMatDiff')
                end % is raw?
                % HbO & HbR extraction succesful!
                PAT.jobsdone(1).HbOHbROK = true;
                % Save PAT matrix
                save(PATmat,'PAT');
            end % GLM OK
        end % redo job
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        fprintf('Subject %d of %d complete\n', scanIdx, length(job.PATmat));
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end % End try
end % Scans loop
end % pat_get_hbo_hbr_run

% EOF
