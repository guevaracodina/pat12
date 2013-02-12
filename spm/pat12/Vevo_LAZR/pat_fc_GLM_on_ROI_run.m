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
fprintf('Work in progress...\nEGC\n')
out.PATmat = job.PATmat;
return
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
        
        if ~isfield(PAT.jobsdone,'ROIOK')
            disp(['No ROI available for subject ' int2str(scanIdx) ' of ' int2str(length(job.PATmat)) ' ... skipping series extraction']);
        else
            if ~isfield(PAT.jobsdone,'seriesOK') || ~isfield(PAT.jobsdone,'PAT.jobsdone.maskSeriesOK')
                disp(['Extracted series not available for scan ' int2str(scanIdx) ' of ' int2str(length(job.PATmat)) ' ... skipping GLM']);
            else
                % NEED TO COMPLETE FILTERING MODULE //EGC
                if ~isfield(IOI.fcIOS.filtNdown,'filtNdownOK')
                    disp(['Filtered/downsampled time-courses not available for scan ' int2str(scanIdx) ' of ' int2str(length(job.PATmat)) ' ... skipping GLM']);
                else
                    if ~isfield(IOI.fcIOS,'SPM')
                        % It is the first time to run SPM
                        IOI.fcIOS.SPM = struct([]);
                    end
                    if ~isfield(IOI.fcIOS.SPM,'GLMOK') || job.force_redo
                        % Get colors to include information
                        IC = job.IC;
                        colorNames = fieldnames(IOI.color);
                        % Load filtered downsampled signals
                        filtNdownData = load(IOI.fcIOS.filtNdown.fname);
                        fnameROIregress = fullfile(dir_ioimat,'ROIregress.mat');
                        % Loop over sessions
                        for s1=1:length(IOI.sess_res)
                            if all_sessions || sum(s1==selected_sessions)
                                sessionDir = [dir_ioimat filesep 'S' sprintf('%02d',s1)];
                                if ~exist(sessionDir,'dir'),mkdir(sessionDir); end
                                % Loop over available colors
                                for c1=1:length(IOI.sess_res{s1}.fname)
                                    doColor = ioi_doColor(IOI,c1,IC);
                                    if doColor
                                        %skip laser - only extract for flow
                                        if ~(IOI.color.eng(c1)==IOI.color.laser)
                                            colorDir = [sessionDir filesep 'C' sprintf('%d',c1)];
                                            if ~exist(colorDir,'dir'),mkdir(colorDir); end
                                            % Get filtered downsampled signals
                                            brainSignal = filtNdownData.filtNdownBrain{1}{s1, c1};
                                            % Initialize single voxel 4-D series
                                            brainSignalRep = zeros([1 1 1 numel(brainSignal)]);
                                            dim = [1 1 1/IOI.fcIOS.filtNdown.downFreq];
                                            if job.wholeImage
                                                %% GLM on images here!
                                                % y = ioi_get_images(IOI,1:IOI.sess_res{s1}.n_frames,c1,s1,dir_ioimat,shrinkage_choice);
                                                
                                                % Constructing inputs required for
                                                % GLM analysis within the SPM
                                                % framework
                                                clear SPM
                                                SPM.xY.VY = spm_vol(IOI.fcIOS.filtNdown.fnameWholeImage{s1, c1});
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
                                                fprintf('\nPerforming GLM on %s whole images, Session %d Color %d (%s)...\n',IOI.subj_name,s1,c1,colorNames{1+c1})
                                                try
                                                    % GLM is performed here
                                                    SPM = spm_spm(SPM);
                                                    
                                                    if job.regressBrainSignal == 1,
                                                        % Subtract global brain signal
                                                        % from every pixel time course
                                                        betaVol = spm_vol(fullfile(SPM.swd,SPM.Vbeta.fname));
                                                        beta = spm_read_vols(betaVol);
                                                        % Create a single voxel 4-D
                                                        % series
                                                        brainSignalRep(1,1,1,:) = brainSignal;
                                                        yRegress = y - repmat(beta,[1 1 1 size(y,4)]) .* repmat(brainSignalRep,[size(beta,1) size(beta,2) 1 1]);
                                                        
                                                        filtNdownfnameRegress = fullfile(sessionDir,[IOI.subj_name '_OD_' IOI.color.eng(c1) '_regress_' sprintf('%05d',1) 'to' sprintf('%05d',IOI.sess_res{s1}.n_frames) '.nii']);
                                                        % Save NIFTI file
                                                        ioi_save_nifti(yRegress, filtNdownfnameRegress, dim);
                                                        % Brain signal regression succesful!
                                                        IOI.fcIOS.SPM(1).wholeImageRegressOK{s1, c1} = true;
                                                        fprintf('\nGlobal brain signal regressed from %s whole images in Session %d Color %d (%s) done!\n',IOI.subj_name,s1,c1,colorNames{1+c1})
                                                    end
                                                    
                                                    % Update SPM matrix info
                                                    IOI.fcIOS.SPM(1).fnameSPM{s1, c1} = SPM.swd;
                                                    IOI.fcIOS.SPM(1).fname{s1, c1} = filtNdownfnameRegress;
                                                catch exception
                                                    % Brain signal regression failed!
                                                    IOI.fcIOS.SPM(1).wholeImageRegressOK{s1, c1} = false;
                                                    fprintf('\nGlobal brain signal regressed from %s whole images in Session %d Color %d (%s) failed!\n',IOI.subj_name,s1,c1,colorNames{1+c1})
                                                    disp(exception.identifier)
                                                    disp(exception.stack(1))
                                                end
                                            end % end on GLM on images
                                            
                                            % Loop over ROIs
                                            for r1=1:length(IOI.res.ROI)
                                                if all_ROIs || sum(r1==selected_ROIs)
                                                    ROIdir = [colorDir filesep 'ROI' sprintf('%02d',r1)];
                                                    if ~exist(ROIdir,'dir'),mkdir(ROIdir); end
                                                    % Initialize y tilde (ROIregress)
                                                    ROIregress{r1}{s1,c1} = [];
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
                                                        title(sprintf('Seed %d time-course, S%d, C%d (%s)',r1,s1,c1,colorNames{1+c1}),'FontSize',14);
                                                        subplot(312); plot(brainSignal);
                                                        title(sprintf('Mean global signal time-course, S%d, C%d (%s)',s1,c1,colorNames{1+c1}),'FontSize',14);
                                                    end
                                                    
                                                    % Creating nifti files to be able to use SPM later
                                                    % --------------------------
                                                    fnameNIFTI = fullfile(ROIdir,['ROI' sprintf('%02d',r1) '_S' sprintf('%02d',s1) '_C' num2str(c1),'.nii']);
                                                    dim = [1 1 1];
                                                    % Create a single voxel 4-D
                                                    % series
                                                    y2(1,1,1,:) = y;
                                                    ioi_save_nifti(y2, fnameNIFTI, dim);
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
                                                    
                                                    % Directory to save SPM and
                                                    % img/hdr files
                                                    SPM.swd = ROIdir;
                                                    if ~exist(SPM.swd,'dir'),mkdir(SPM.swd); end
                                                    fprintf('\nPerforming GLM for %s ROI %d Session %d Color %d (%s)...\n',IOI.subj_name,r1,s1,c1,colorNames{1+c1})
                                                    try
                                                        % GLM is performed here
                                                        SPM = spm_spm(SPM);
                                                        
                                                        if job.regressBrainSignal == 1,
                                                            % Subtract global brain
                                                            % signal from ROI time
                                                            % courses
                                                            betaVol = spm_vol(fullfile(SPM.swd,SPM.Vbeta.fname));
                                                            beta = spm_read_vols(betaVol);
                                                            ROIregress{r1}{s1, c1} = y - beta * brainSignal;
                                                            
                                                            % Brain signal regression succesful!
                                                            IOI.fcIOS.SPM(1).ROIregressOK{r1}{s1, c1} = true;
                                                            
                                                            % Identify in IOI the file name of the time series
                                                            IOI.fcIOS.SPM(1).fnameROIregress = fnameROIregress;
                                                            fprintf('\nGlobal brain signal regressed from %s ROI %d (%s) Session %d Color %d (%s) done!\n',IOI.subj_name,r1,IOI.ROIname{r1},s1,c1,colorNames{1+c1})
                                                            if job.generate_figures
                                                                spm_figure('GetWin', 'Graphics');
                                                                subplot(313); plot(ROIregress{r1}{s1, c1});
                                                                title(sprintf('Global signal regressed from ROI time-course %d, S%d, C%d (%s)',r1,s1,c1,colorNames{1+c1}),'FontSize',14);
                                                            end
                                                        end
                                                        
                                                        % Update SPM matrix info
                                                        IOI.fcIOS.SPM(1).fnameROISPM{r1}{s1, c1} = SPM.swd;
                                                        IOI.fcIOS.SPM(1).fnameROInifti{r1}{s1, c1} = fnameNIFTI;
                                                        % Contrasts
                                                        % --------------------------
                                                        % [Ic, xCon] = spm_conman(SPM, 'T|F', Inf, 'Select contrasts...', 'Contrasts amongst spectral regressors', 1);
                                                        % SPM.xCon = xCon;
                                                        % [SPM,xSPM]=spm_getSPM(SPM,[]);
                                                        % --------------------------
                                                        fprintf('\nGLM for %s ROI %d Session %d Color %d (%s) done!\n',IOI.subj_name,r1,s1,c1,colorNames{1+c1})
                                                    catch exception
                                                        % Brain signal regression on ROI failed!
                                                        IOI.fcIOS.SPM(1).ROIregressOK{r1}{s1, c1} = false;
                                                        fprintf('\nGLM for %s ROI %d Session %d Color %d (%s) failed!\n',IOI.subj_name,r1,s1,c1,colorNames{1+c1})
                                                        disp(exception.identifier)
                                                        disp(exception.stack(1))
                                                    end
                                                end
                                            end % ROI loop
                                        end
                                    end 
                                end % colors loop
                            end
                        end % sessions loop
                        % GLM regression succesful!
                        IOI.fcIOS.SPM(1).GLMOK = true;
                        if job.regressBrainSignal == 1,
                            save(fnameROIregress,'ROIregress');
                        end
                        if job.cleanupGLM
                            % Keeps only NIfTI files of succesfully regressed ROIs
                            IOI.fcIOS.SPM.cleanupOK = ioi_fc_GLM_on_ROI_cleanup(IOI, job);
                        end
                        % Save IOI matrix
                        save(PATmat,'IOI');
                    end % GLM OK or redo job
                end % Filtering&Downsampling OK
            end % Time-series OK
        end % ROI OK
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        disp(['Subject ' int2str(scanIdx) ' (' IOI.subj_name ')' ' complete']);
        out.PATmat{scanIdx} = PATmat;
        cd(spm('Dir'));     % Return to SPM working directory
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % Big loop over scans

% EOF

