function out = pat_fc_GLM_on_ROI_run(job)
% GLM regression of global brain signal in resting-state from ROI/seeds time
% trace in order to remove global source of variance.
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

%Big loop over scans
for scanIdx=1:length(job.PATmat)
    try
        eTime = tic;
        clear ROI SPM
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        
        if ~isfield(PAT.jobsdone,'ROIOK')
            fprintf('No ROI available for (%s) scan %d of %d ... skipping GLM\n', scanName, scanIdx, length(job.PATmat));
        else
            if ~isfield(PAT.jobsdone,'seriesOK') || ~isfield(PAT.jobsdone,'maskSeriesOK')
                fprintf('Extracted series not available for (%s) scan %d of %d ... skipping GLM\n', scanName, scanIdx, length(job.PATmat));
            else
                if ~isfield(PAT.jobsdone,'filtNdownOK')
                    fprintf('Filtered/downsampled time-courses not available for (%s) scan %d of %d ... skipping GLM\n', scanName, scanIdx, length(job.PATmat));
                else
                    if ~isfield(PAT.fcPAT,'SPM')
                        % It is the first time to run SPM
                        PAT.fcPAT.SPM = struct([]);
                    end
                    if ~isfield(PAT.jobsdone,'GLMOK') || job.force_redo
                        % Get colors to include information
                        IC = job.IC;
                        colorNames = fieldnames(PAT.color);
                        % Load filtered downsampled signals (ROIs & Brain signals)
                        filtNdownData = load(PAT.fcPAT.filtNdown.fname);
                        fnameROIregress = fullfile(dir_patmat,'ROIregress.mat');
                        % Loop over sessions
                        s1 = 1; % Only 1 session for PAT
                        % Loop over available colors
                        for c1 = 1:length(PAT.nifti_files)
                            doColor = pat_doColor(PAT,c1,IC);
                            if doColor
                                % skip B-mode only extract PA
                                if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                                    colorDir = [dir_patmat filesep 'C' sprintf('%d',c1)];
                                    if ~exist(colorDir,'dir'),mkdir(colorDir); end
                                    % Get filtered downsampled signals
                                    brainSignal = filtNdownData.filtNdownBrain{1}{s1, c1};
                                    % Initialize single voxel 4-D series
                                    brainSignalRep = zeros([1 1 1 numel(brainSignal)]);
                                    if job.wholeImage
                                        %% GLM on images here!
                                        % Constructing inputs required for
                                        % GLM analysis within the SPM
                                        % framework
                                        clear SPM
                                        SPM.xY.VY = spm_vol(PAT.fcPAT.filtNdown.fnameWholeImage{s1, c1});
                                        y = spm_read_vols(SPM.xY.VY);
                                        % Preallocating output images
                                        yRegress = zeros(size(y));
                                        
                                        % All regressors are identified
                                        % here, lets take the mean global
                                        % signal just to test
                                        SPM.xX.name = cellstr(['Global Brain Signal']);
                                        SPM.xX.X = brainSignal';        % Regression is along first dimension. For one regressor it is a column vector.
                                        
                                        % A revoir
                                        SPM.xX.iG = [];
                                        SPM.xX.iH = [];
                                        SPM.xX.iC = 1:size(SPM.xX,2);   % Indices of regressors of interest
                                        SPM.xX.iB = [];                 % Indices of confound regressors
                                        SPM.xGX.rg = [];                % Raw globals, need to check this //EGC
                                        
                                        SPM.xVi.Vi = {speye(size(SPM.xX.X,1))}; % Time correlation
                                        
                                        % Directory to save SPM and img/hdr
                                        % files
                                        SPM.swd = colorDir;
                                        if ~exist(SPM.swd,'dir'),mkdir(SPM.swd); end
                                        fprintf('\nPerforming GLM on whole images (%s) Color %d (%s)...\n',scanName,c1,colorNames{1+c1})
                                        try
                                            % GLM is performed here
                                            SPM = spm_spm(SPM);
                                            
                                            if isfield(job.regressor_choice,'regressBrainSignal'),
                                                % Subtract global brain signal
                                                % from every pixel time course
                                                betaVol = spm_vol(fullfile(SPM.swd,SPM.Vbeta.fname));
                                                beta = spm_read_vols(betaVol);
                                                % Create a single voxel 4-D
                                                % series
                                                brainSignalRep(1,1,1,:) = brainSignal;
                                                yRegress = y - repmat(beta,[1 1 1 size(y,4)]) .* repmat(brainSignalRep,[size(beta,1) size(beta,2) 1 1]);
                                                filtNdownfnameRegress = fullfile(dir_patmat,[scanName '_' PAT.color.eng(c1) '_regress_' sprintf('%05d',1) 'to' sprintf('%05d', size(yRegress,4)) '.nii']);
                                                % Create 4-D NIFTI file with filtered time trace of each pixel
                                                pat_create_vol_4D(filtNdownfnameRegress, SPM.xY.VY, yRegress);
                                                % Brain signal regression succesful!
                                                PAT.fcPAT.SPM(1).wholeImageRegressOK{s1, c1} = true;
                                                fprintf('\nGlobal brain signal regressed from whole images (%s) Color %d (%s) done!\n',scanName,c1,colorNames{1+c1})
                                            else
                                                %% Another ROI as regressor
                                                % TO DO... //EGC
                                            end
                                            
                                            % Update SPM matrix info
                                            PAT.fcPAT.SPM(1).fnameSPM{s1, c1} = SPM.swd;
                                            PAT.fcPAT.SPM(1).fname{s1, c1} = filtNdownfnameRegress;
                                        catch exception
                                            % Brain signal regression failed!
                                            PAT.fcPAT.SPM(1).wholeImageRegressOK{s1, c1} = false;
                                            fprintf('\nGlobal brain signal regressed from (%s) whole images Color %d (%s) failed!\n',scanName,c1,colorNames{1+c1})
                                            disp(exception.identifier)
                                            disp(exception.stack(1))
                                        end
                                    end % end on GLM on images
                                    
                                    % Loop over ROIs
                                    for r1=1:length(PAT.res.ROI)
                                        if all_ROIs || sum(r1==selected_ROIs)
                                            ROIdir = [colorDir filesep 'ROI' sprintf('%02d',r1)];
                                            if ~exist(ROIdir,'dir'),mkdir(ROIdir); end
                                            % Initialize y tilde (ROIregress)
                                            ROIregress{r1}{s1,c1} = [];
                                            ROIregressStd{r1}{s1,c1} = [];
                                            ROIregressSem{r1}{s1,c1} = [];
                                            
                                            %% GLM on ROI code
                                            y = filtNdownData.filtNdownROI{r1}{s1, c1};
                                            % Initialize single voxel
                                            % 4-D series
                                            y2 = zeros([1 1 1 numel(y)]);
                                            
                                            if job.generate_figures
                                                % Display plots on SPM graphics window
                                                spm_figure('GetWin', 'Graphics');
                                                spm_figure('Clear', 'Graphics');
                                                subplot(311); plot(y);
                                                title(sprintf('Seed %d time-course, C%d (%s)',r1,c1,colorNames{1+c1}),'FontSize',14);
                                                subplot(312); plot(brainSignal);
                                                title(sprintf('Mean global signal time-course, C%d (%s)',c1,colorNames{1+c1}),'FontSize',14);
                                            end
                                            
                                            % Creating nifti files to be able to use SPM later
                                            % --------------------------
                                            fnameNIFTI = fullfile(ROIdir,['ROI' sprintf('%02d',r1) '_C' num2str(c1),'.nii']);
                                            dim = [1 1 1];
                                            % Create a single voxel 4-D
                                            % series
                                            y2(1,1,1,:) = y;
                                            % ioi_save_nifti(y2, fnameNIFTI, dim);
                                            % Create volume header structure
                                            volROI = SPM.xY.VY;
                                            for iPlanes = 1:numel(volROI)
                                                volROI(iPlanes).dim = dim;
                                                volROI(iPlanes).fname = fnameNIFTI;
                                                volROI(iPlanes).mat = [ 1 0 0 0;
                                                                        0 1 0 0;
                                                                        0 0 1 0;
                                                                        0 0 0 1];
                                            end
                                            pat_create_vol_4D(fnameNIFTI, volROI, y2);
                                            % --------------------------
                                            % end of nifti processing
                                            
                                            % Constructing inputs
                                            % required for GLM analysis
                                            % within the SPM framework
                                            clear SPM
                                            SPM.xY.VY = spm_vol(fnameNIFTI);
                                            
                                            % All regressors are
                                            % identified here, lets take
                                            % the mean global signal
                                            % just to test
                                            SPM.xX.name = cellstr(['Global Brain Signal']);
                                            SPM.xX.X = brainSignal';        % Regression is along first dimension. For one regressor it is a column vector.
                                            
                                            % A revoir
                                            SPM.xX.iG = [];
                                            SPM.xX.iH = [];
                                            SPM.xX.iC = 1:size(SPM.xX,2);   % Indices of regressors of interest
                                            SPM.xX.iB = [];                 % Indices of confound regressors
                                            SPM.xGX.rg = [];                % Raw globals, need to check this //EGC
                                            
                                            SPM.xVi.Vi = {speye(size(SPM.xX.X,1))}; % Time correlation
                                            
                                            % Directory to save SPM and NIfTI files
                                            SPM.swd = ROIdir;
                                            if ~exist(SPM.swd,'dir'),mkdir(SPM.swd); end
                                            fprintf('\nPerforming GLM for %s ROI %d Color %d (%s)...\n',scanName,r1,c1,colorNames{1+c1})
                                            try
                                                % GLM is performed here
                                                SPM = spm_spm(SPM);
                                                if isfield(job.regressor_choice,'regressBrainSignal'),
                                                    % Subtract global brain
                                                    % signal from ROI time
                                                    % courses
                                                    betaVol = spm_vol(fullfile(SPM.swd,SPM.Vbeta.fname));
                                                    beta = spm_read_vols(betaVol);
                                                    ROIregress{r1}{s1, c1} = y - beta * brainSignal;
                                                    % Brain signal regression succesful!
                                                    PAT.fcPAT.SPM(1).ROIregressOK{r1}{s1, c1} = true;
                                                    % Identify in PAT the file name of the time series
                                                    PAT.fcPAT.SPM(1).fnameROIregress = fnameROIregress;
                                                    fprintf('\nGlobal brain signal regressed from %s ROI %d (%s) Color %d (%s) done!\n',scanName,r1,PAT.ROI.ROIname{r1},c1,colorNames{1+c1})
                                                    if job.generate_figures
                                                        spm_figure('GetWin', 'Graphics');
                                                        subplot(313); plot(ROIregress{r1}{s1, c1});
                                                        title(sprintf('Global signal regressed from ROI time-course %d, C%d (%s)',r1,c1,colorNames{1+c1}),'FontSize',14);
                                                    end
                                                else
                                                    %% Another ROI as regressor
                                                    % TO DO... //EGC
                                                end
                                                
                                                % Update SPM matrix info
                                                PAT.fcPAT.SPM(1).fnameROISPM{r1}{s1, c1} = SPM.swd;
                                                PAT.fcPAT.SPM(1).fnameROInifti{r1}{s1, c1} = fnameNIFTI;
                                                fprintf('\nGLM for %s ROI %d Color %d (%s) done!\n',scanName,r1,c1,colorNames{1+c1})
                                            catch exception
                                                % Brain signal regression on ROI failed!
                                                PAT.fcPAT.SPM(1).ROIregressOK{r1}{s1, c1} = false;
                                                fprintf('\nGLM for %s ROI %d Color %d (%s) failed!\n',scanName,r1,c1,colorNames{1+c1})
                                                disp(exception.identifier)
                                                disp(exception.stack(1))
                                            end
                                        end
                                    end % ROI loop
                                end
                            end
                        end % colors loop
                        %%
                        % ------------------------------------------------------
                        % If ROI regression failed, then get ROI time course
                        % from the whole image regressed series.
                        % ------------------------------------------------------
                        % Identify in PAT the file name of the time series
                        PAT.fcPAT.SPM(1).fnameROIregress = fnameROIregress;
                        % Get mask for each ROI
                        [PAT mask] = pat_get_roimask(PAT,job);
                        Amask = []; % Initialize activation mask
                        % We are not extracting brain mask here
                        job.extractingBrainMask = false;
                        job.extractBrainMask = false;
                        % Extract ROI from regressed whole image series.
                        [PAT ROIregressTmp ROIregressStd ROIregressSem] = ...
                            pat_extract_core(PAT,job,mask,Amask,'regressData');
                        % Loop over available colors
                        for c1 = 1:length(PAT.nifti_files)
                            doColor = pat_doColor(PAT,c1,IC);
                            if doColor
                                % skip B-mode only extract PA
                                if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                                    % Loop over ROIs
                                    for r1=1:length(PAT.res.ROI)
                                        if all_ROIs || sum(r1==selected_ROIs)
                                            if ~PAT.fcPAT.SPM.ROIregressOK{r1}{s1, c1}
                                                % GLM on ROI not succesful, so
                                                % we write the ROI extracted frm
                                                % the regressed whole image.
                                                ROIregress{r1}{s1, c1} =  ROIregressTmp{r1}{s1, c1};
                                                % Brain signal regression succesful!
                                                PAT.fcPAT.SPM(1).ROIregressOK{r1}{s1, c1} = true;
                                            end
                                        end
                                    end % ROI loop
                                end
                            end
                        end % colors loop
                        % ------------------------------------------------------
                        
                        %% GLM regression succesful!
                        PAT.jobsdone(1).GLMOK = true;
                        if isfield(job.regressor_choice,'regressBrainSignal'),
                            save(fnameROIregress,'ROIregress', 'ROIregressStd', 'ROIregressSem');
                        end
                        if job.cleanupGLM
                            % Keeps only NIfTI files of succesfully regressed ROIs
                            PAT.fcPAT.SPM.cleanupOK = pat_fc_GLM_on_ROI_cleanup(PAT, job);
                        end
                        % Save PAT matrix
                        save(PATmat,'PAT');
                    end % GLM OK or redo job
                end % Filtering&Downsampling OK
            end % Time-series OK
        end % ROI OK
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        fprintf('Scan %s, %d of %d complete %30s\n', splitStr{end-1}, scanIdx, length(job.PATmat), spm('time'));
        out.PATmat{scanIdx} = PATmat;
        cd(spm('Dir'));     % Return to SPM working directory
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % Big loop over scans

% EOF

