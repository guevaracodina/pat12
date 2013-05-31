function out = pat_realign_run(job)
% Realigns and reslices PAT NIfTI files
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
%
% Frederic Lesage
% Email: frederic.lesage@polymtl.ca
%

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

if pat_isVEVOraw(job)
    % Processing for .raw.pamode files (HbT/SO2)
    % Create SPM figure window
    spm_figure('Create','Interactive');
    % Get realignment parameters
    flags = get_flags(job);
    for scanIdx = 1:length(job.PATmat)
        try
            eTime = tic;
            % Load PAT.mat information
            [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
            [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
            scanName = splitStr{end-1};
            if ~isfield(PAT.jobsdone,'realign') || job.force_redo
                % Backup original filenames references
                PAT.fcPAT.nifti_files_unaligned = PAT.nifti_files;
                % Backup original affine matrices references
                PAT.fcPAT.nifti_files_affine_matrix_unaligned = PAT.nifti_files_affine_matrix;
                % Get file indices
                idxBmode = regexp(PAT.color.eng, PAT.color.Bmode);
                idxHbT = regexp(PAT.color.eng, PAT.color.HbT);
                idxSO2 = regexp(PAT.color.eng, PAT.color.SO2);
                
                % Only realign B-mode images
                P = pat_realign(PAT.nifti_files{idxBmode},flags);
                % Save parameters Q(1:3) = x,y,z in mm
                % Q(4:6) = x,y,z in rad (multiply by 180/pi to convert to deg)
                
                [Q, fname] = save_parameters(P);
                Q(:, 4:6) = Q(:, 4:6)*180/pi;
                save(fullfile(dir_patmat,'motion_parameters_1stPass.mat'), 'Q');
                PAT(1).motion_parameters(1).fnameTXT1stPass = fname;
                PAT(1).motion_parameters(1).fnameMAT1stPass = fullfile(dir_patmat,'motion_parameters_1stPass.mat');
                
                % Get file prefix ('r')
                def_flags        = spm_get_defaults('realign.write');
                % Get B-mode affine matrix info
                [matPathName matFileName matExt] = fileparts(PAT.nifti_files_affine_matrix{idxBmode});
                PAT.nifti_files_affine_matrix{idxBmode} = fullfile(matPathName, [def_flags.prefix matFileName matExt]);
                % Get HbT affine matrix info
                [matPathName matFileName matExt] = fileparts(PAT.nifti_files_affine_matrix{idxHbT});
                PAT.nifti_files_affine_matrix{idxHbT} = fullfile(matPathName, [def_flags.prefix matFileName matExt]);
                % Get SO2 affine matrix info
                [matPathName matFileName matExt] = fileparts(PAT.nifti_files_affine_matrix{idxSO2});
                PAT.nifti_files_affine_matrix{idxSO2} = fullfile(matPathName, [def_flags.prefix matFileName matExt]);
                
                % Choose NIfTI files, frame by frame
                [~, SO2FileName, ~] = fileparts(PAT.nifti_files{idxSO2});
                PSO2 = spm_select('ExtList',dir_patmat, [SO2FileName '.nii'],1:numel(P));
                [~, HbTFileName, ~] = fileparts(PAT.nifti_files{idxHbT});
                PHbT = spm_select('ExtList',dir_patmat, [HbTFileName '.nii'],1:numel(P));
                
                % Apply the realignment from B-mode to PA images
                for iFrames=1:size(PHbT,1),   % Loop over selected images
                    % HbT
                    Pi = deblank(fullfile(matPathName, PHbT(iFrames,:)));  % Pick out current image
                    % M = spm_get_space(Pi);  % Read its voxel-to-world info
                    spm_get_space(Pi, P(iFrames).mat); % Apply the realignment
                    % SO2
                    Pi = deblank(fullfile(matPathName, PSO2(iFrames,:)));  % Pick out current image
                    % M = spm_get_space(Pi);  % Read its voxel-to-world info
                    spm_get_space(Pi, P(iFrames).mat); % Apply the realignment
                end
                
                % Update volumes
                volHbTNew = spm_vol(PAT.nifti_files{1,idxHbT});
                volSO2New = spm_vol(PAT.nifti_files{1,idxSO2});
                
                % Reslice B-mode file (voxels are modified with reslicing)
                volBmodeRealigned = pat_reslice(P);
                % Change the reference in PAT matrix to realigned files
                PAT.nifti_files{idxBmode} = volBmodeRealigned(1).fname;
                % Reslice HbT data using the realignment information of B-mode
                volHbTRealigned = pat_reslice(volHbTNew);
                % Change the reference in PAT matrix to realigned files
                PAT.nifti_files{idxHbT} = volHbTRealigned(1).fname;
                % Reslice SO2 data using the realignment information of B-mode
                volSO2Realigned = pat_reslice(volSO2New);
                % Change the reference in PAT matrix to realigned files
                PAT.nifti_files{idxSO2} = volSO2Realigned(1).fname;
                
                % Do a 2nd pass to get the residual movement parameters
                P = pat_realign(PAT.nifti_files{idxBmode},flags);
                % Save parameters Q(1:3) = x,y,z in mm
                % Q(4:6) = x,y,z in rad (multiply by 180/pi to convert to deg)
                [Q, fname] = save_parameters(P);
                Q(:, 4:6) = Q(:, 4:6)*180/pi;
                save(fullfile(dir_patmat,'motion_parameters.mat'), 'Q');
                PAT(1).motion_parameters(1).fnameTXT = fname;
                PAT(1).motion_parameters(1).fnameMAT = fullfile(dir_patmat,'motion_parameters.mat');
                
                % Realignment succesful
                PAT.jobsdone.realign = true;
                % Save PAT matrix
                save(PATmat,'PAT');
            end % correlation OK or redo job
            disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
            fprintf('Scan %s, %d of %d aligned %30s\n', scanName, scanIdx, length(job.PATmat), spm('time'));
            out.PATmat{scanIdx} = PATmat;
        catch exception
            out.PATmat{scanIdx} = PATmat;
            disp(exception.identifier)
            disp(exception.stack(1))
        end
    end % loop over scans
else
    % Original processing when files are not .raw.pamode format from VEVO 2100
    PATmat = job.PATmat;
    % Create SPM figure window
    spm_figure('Create','Interactive')
    % Get realignment parameters
    flags = get_flags(job);
    for scanIdx = 1:size(PATmat,1)
        try
            load(PATmat{scanIdx});
            for iFile=1:length(PAT.nifti_files)
                P = pat_realign(PAT.nifti_files{iFile},flags);
                pat_reslice(P);
            end
            PAT.jobsdone.realign = true;
            save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
            out.PATmat{scanIdx} = PATmat{scanIdx};
        catch exception
            disp(exception.identifier)
            disp(exception.stack(1))
            out.PATmat{scanIdx} = PATmat{scanIdx};
        end
    end
end % isVEVO
end % pat_realign_run

function flags = get_flags(job)
% Get realignment parameters
flags.fwhm      = job.fwhm;
flags.rtm       = job.rtm;
flags.sep       = job.sep;
flags.quality   = job.quality;
% Print parameters
flags.graphics  = true;
end

function [Q, fname] = save_parameters(P)
fname = [spm_str_manip(prepend(P(1).fname,'rp_'),'s') '.txt'];
n = length(P);
Q = zeros(n,6);
for j=1:n,
    qq     = spm_imatrix(P(j).mat/P(1).mat);
    Q(j,:) = qq(1:6);
end;
save(fname,'Q','-ascii');
end

function PO = prepend(PI,pre)
[pth,nm,xt,vr] = spm_fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt vr]);
end

% EOF
