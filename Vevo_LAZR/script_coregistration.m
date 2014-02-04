function script_coregistration
clear; clc;
fprintf('Manual coregistration PA-mode to B-mode\n')
% PAT list (56 subjects [21 OS + 28 RS] )
job.PATmat = {  
%                 'F:\Edgar\Data\PAT_Results\2012-11-09-16-18-31_ctl03\PAT.mat'
%                 % Alignment error in 2012-11-09-16-18-31_ctl03 
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-10-40-07_toe10\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-11-04-40_toe04\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-12-10-31_ctl01\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-09-07-14-48-55_ctl02\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-18-31_ctl03\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-20-12_toe03\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-21-53_ctl01\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DD_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DI_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DJ_RS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\RS\DL_RS3\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-16-25_toe04\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-17-27_toe05\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-18-31_ctl03_OS1\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-18-31_ctl03_OS2\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-20-12_toe03\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-21-53_ctl01\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-23-04_toe08\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-23-51_toe09\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\2012-11-09-16-40-09_toe02\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DA_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DB_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DC_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DD_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DE_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DF_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DG_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DH_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DI_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DJ_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DK_OS\PAT.mat'
                'F:\Edgar\Data\PAT_Results_20130517\OxySurge\DL_OS\PAT.mat'
                };
job.IC = struct();
job.IC(1).include_HbT = true;
job.IC(1).include_SO2 = true;
job.IC(1).include_Bmode = false;

% PAT copy/overwrite method
job.PATmatCopyChoice = pat_PATmatCopyChoice_cfg('coreg');
% if tru, chooses PAT image to be centered on B-mode image
job.AUTO = true;
job.frame2display = 1;
job.force_redo = true;

%% scans loop
for scanIdx = 1: numel(job.PATmat);
    try
        tic
        % Load PAT.mat information
        [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        scanName = splitStr{end-1};
        if ~isfield(PAT.jobsdone,'manualCoregOK') || job.force_redo
            % Get colors to include information
            IC = job.IC;
            colorNames = fieldnames(PAT.color);
            
            % Loop over sessions
            s1 = 1; % Only 1 session for PAT
            % Loop over available colors
            for c1 = 1:length(PAT.nifti_files)
                doColor = pat_doColor(PAT,c1,IC);
                if doColor
                    % skip B-mode only extract PA
                    if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                        % SO2
                        volPAmode = spm_vol(PAT.nifti_files{1,c1});
                        im_PA = spm_read_vols(volPAmode);
                        
                        % B-mode
                        volBmode = spm_vol(PAT.nifti_files{1,3});
                        im_B = spm_read_vols(volBmode);
                        
                        % PaNumLines (512) map to 23.04 mm = 256*90um, valid only if:
                        % "Transducer-Name" value="LZ-250"
                        nLinesOK = round(PAT.PAparam.PaNumLines*(PAT.PAparam.PaWidth/23.04));
                        
                        % Display B-mode image
                        h = figure;
                        set(h,'Name',scanName);
                        subplot(121)
                        imagesc(PAT.bModeParam.WidthAxis, PAT.bModeParam.DepthAxis, squeeze(im_B(:,:,1,job.frame2display)))
                        axis image
                        title('B-mode')
                        
                        % Display PA image
                        subplot(122)
                        imagesc(squeeze(im_PA(:,:,1,job.frame2display)));
                        axis image
                        title(sprintf('PA-mode (%s)',colorNames{c1+1}))
                        if job.AUTO
                            % Assume SO2 image is centered on B-mode image
                            startIdx = round((PAT.PAparam.PaNumLines/2) - (nLinesOK/2));
                        else
                            % Ask user to locate start line; this is necessary because parameter
                            % /Line-Start-Index in xml file does not give any trustworthy information
                            figure(h)
                            subplot(122)
                            title('Choose start A-line')
                            p = impoint(gca,[]);
                            p = wait(p);
                            % Round-up to avoid zero-index
                            startIdx = ceil(p(1));
                        end
                        % Find end A-line
                        endIdx = startIdx + nLinesOK - 1;
                        
                        % Crop image
                        im_PA = im_PA(:,startIdx:endIdx,:,:);
                        
                        % Value used to pad array
                        val2pad = 0;
                        
                        if PAT.PAparam.BmodeWidth >= PAT.PAparam.PaWidth
                            PAnewWidth = PAT.PAparam.PaWidth / nLinesOK;
                            % B-mode images are always wider than PA images
                            nExtraLines = (PAT.PAparam.BmodeWidth - PAT.PAparam.PaWidth) / PAnewWidth;
                            % Find lines to add at left
                            nLinesLeft = floor(nExtraLines/2);
                            % Find lines to add at right
                            nLinesRight = ceil(nExtraLines/2);
                            % Pad image
                            im_PA = padarray(im_PA, [0 nLinesLeft 0 0], val2pad, 'pre');
                            im_PA = padarray(im_PA, [0 nLinesRight 0 0], val2pad, 'post');
                        end
                        
                        if PAT.bModeParam.BmodeDepthOffset <= PAT.PAparam.PaDepthOffset && PAT.bModeParam.BmodeDepth >= PAT.PAparam.PaDepth
                            % B-mode images are always taller than PA images
                            % Find rows to add at top
                            nRowsTop = ceil((PAT.PAparam.PaDepthOffset - PAT.bModeParam.BmodeDepthOffset) / PAT.PAparam.pixDepth);
                            % Find rows to add at bottom
                            nRowsBottom = floor((PAT.bModeParam.BmodeDepth - PAT.PAparam.PaDepth) / PAT.PAparam.pixDepth);
                            % Pad image
                            im_PA = padarray(im_PA, [nRowsTop 0 0 0], val2pad, 'pre');
                            im_PA = padarray(im_PA, [nRowsTop 0 0 0], val2pad, 'post');
                        end
                        
                        % resize SO2 image to B-mode image size
                        im_PA_resized = zeros(size(im_B));
                        
                        if ~(PAT.color.eng(c1)==PAT.color.SO2)
                            
                        end
                        
                        % PA-mode data type
                        PAdt = [spm_type('uint16') spm_platform('bigend')];
                        % Modify data type (B-mode is uint8, while PA is uint16)
                        for iFrames = 1:size(im_PA,4)
                            im_PA_resized(:,:,1,iFrames) = pat_imresize(squeeze(im_PA(:,:,1,iFrames)), size(im_B,1), size(im_B,2));
                            volBmode(iFrames).dt = PAdt;
                        end
                        
                        % Update displayed image
                        imagesc(PAT.bModeParam.WidthAxis, PAT.bModeParam.DepthAxis, squeeze(im_PA_resized(:,:,1,job.frame2display)));
                        title(sprintf('PA-mode (%s)',colorNames{c1+1}))
                        axis image
                        
                        % Backup the original images
                        [backupName, backupMat] = local_backup_nifti(PAT, c1);
                        PAT.fcPAT.nifti_files_notresized{1,c1} = backupName;
                        PAT.fcPAT.nifti_files_notresized_affine{1,c1} = backupMat;
                        
                        % Save NIfTI image
                        hdr = pat_create_vol_4D(PAT.nifti_files{1,c1}, volBmode, im_PA_resized);
                    end
                end
            end % End colors loop
            % Update PAT.PAparam with new dimensions (same as B-mode)
            PAT.fcPAT.oldPAparam = PAT.PAparam; % backup old parameters
            PAT.PAparam.PaNumSamples = size(im_PA_resized,1);
            PAT.PAparam.PaNumLines = size(im_PA_resized,2);
            PAT.PAparam.PaDepthOffset = PAT.PAparam.BmodeDepthOffset;
            PAT.PAparam.PaDepth = PAT.PAparam.BmodeDepth;
            PAT.PAparam.PaWidth = PAT.PAparam.BmodeWidth;
            PAT.PAparam.pixDepth = PAT.bModeParam.pixDepth;
            PAT.PAparam.pixWidth = PAT.bModeParam.pixWidth;
            PAT.PAparam.DepthAxis = PAT.bModeParam.DepthAxis;
            PAT.PAparam.WidthAxis = PAT.bModeParam.WidthAxis;
            % Coregistration succesful!
            PAT.jobsdone(1).manualCoregOK = true;
            % Save PAT matrix
            save(PATmat,'PAT');
        end % GLM OK or redo job
        
        out.PATmat{scanIdx} = PATmat;
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Subject %d of %d complete\n', scanIdx, length(job.PATmat));
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end % End try
end % Scans loop
end % end script_coregistration

function [backupName, backupMat] = local_backup_nifti(PAT, c1)
% Backup NIfTI files, they will be copied with the extension .noresize, and the
% resized data will be overwritten to the original NIfTI files.
[pathName, fileName, fileExt] = fileparts(PAT.nifti_files{1,c1});
backupName = fullfile(pathName, [fileName '.noresize' fileExt]);
copyfile(PAT.nifti_files{1,c1}, backupName);
[pathName, matName, matExt] = fileparts(PAT.nifti_files_affine_matrix{1,c1});
backupMat = fullfile(pathName, [matName '.noresize' matExt]);
copyfile(PAT.nifti_files_affine_matrix{1,c1}, backupMat);
end
% EOF
