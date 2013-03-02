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

if isVEVO(job)
    % Do stuff 
    % Create SPM figure window
    spm_figure('Create','Interactive')
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
                idxHbT = regexp(PAT.color.eng, PAT.color.HbT);
                % Only realign and reslice HbT images
                P = pat_realign(PAT.nifti_files{idxHbT},flags);
                volHbtRealigned = pat_reslice(P);
                % Backup original filenames references
                PAT.fcPAT.nifti_files_unaligned = PAT.nifti_files;
                % Change the reference in PAT matrix to realigned files
                PAT.nifti_files{idxHbT} = volHbtRealigned(1).fname;
                % Then take the aligned affine matrix to save the SO2 files
                idxSO2 = regexp(PAT.color.eng, PAT.color.SO2);
                volSO2 = spm_vol(PAT.nifti_files{1,idxSO2});
                % Save information of HbT realigned files onto the SO2 files
                for iFrames = 1:numel(volHbtRealigned)
                    volSO2(iFrames).mat                     = volHbtRealigned(iFrames).mat;
                    volSO2(iFrames).pinfo                   = volHbtRealigned(iFrames).pinfo;
                    volSO2(iFrames).descrip                 = volHbtRealigned(iFrames).descrip;
                    volSO2(iFrames).private.dat.offset      = volHbtRealigned(iFrames).private.dat.offset;
                    volSO2(iFrames).private.dat.scl_slope   = volHbtRealigned(iFrames).private.dat.offset;
                    volSO2(iFrames).private.dat.scl_inter   = volHbtRealigned(iFrames).private.dat.offset;
                    volSO2(iFrames).private.mat             = volHbtRealigned(iFrames).private.mat;
                    volSO2(iFrames).private.mat_intent      = volHbtRealigned(iFrames).private.mat_intent;
                    volSO2(iFrames).private.mat0            = volHbtRealigned(iFrames).private.mat0;
                    volSO2(iFrames).private.mat0_intent     = volHbtRealigned(iFrames).private.mat0_intent;
                    volSO2(iFrames).private.descrip         = volHbtRealigned(iFrames).private.descrip;
                end
                % Reslice SO2 data using the realignment information of HbT
                volSO2Realigned = pat_reslice(volSO2);
                % Change the reference in PAT matrix to realigned files
                PAT.nifti_files{idxSO2} = volSO2Realigned(1).fname;
                % Backup original affine matrices references
                PAT.fcPAT.nifti_files_affine_matrix_unaligned = PAT.nifti_files_affine_matrix;
                def_flags        = spm_get_defaults('realign.write');
                % Update references
                [matPathName matFileName matExt] = fileparts(PAT.nifti_files_affine_matrix{idxHbT});
                PAT.nifti_files_affine_matrix{idxHbT} = fullfile(matPathName, [def_flags.prefix matFileName matExt]);
                [matPathName matFileName matExt] = fileparts(PAT.nifti_files_affine_matrix{idxSO2});
                PAT.nifti_files_affine_matrix{idxSO2} = fullfile(matPathName, [def_flags.prefix matFileName matExt]);
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
    % Original processing when files are not from VEVO 2100
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

function out = isVEVO(job)
% Determines if data was acquired from VEVO 2100 LAZR platform
out = false;
try
    % Load first PAT.mat information
    [PAT , ~, ~]= pat_get_PATmat(job,1);
    out = isfield(PAT.jobsdone,'extract_rawPAmode') || isfield(PAT.jobsdone,'extract_rawBmode') || isfield (PAT,'fcPAT');
end
end % isVEVO

function flags = get_flags(job)
% Get realignment parameters
flags.fwhm      = job.fwhm;
flags.rtm       = job.rtm;
flags.sep       = job.sep;
flags.quality   = job.quality;
end
% EOF
