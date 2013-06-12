function out = pat_spatial_LPF_run(job)
% Low-pass filtering of 2-D images with a rotationally symmetric gaussian kernel
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

%Big loop over subjects
for scanIdx=1:length(job.PATmat)
    try
        tic
        %Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        if ~isfield(PAT.jobsdone,'extract_rawPAmode') % PA mode extracted OK
            disp(['No PA data available for subject ' int2str(scanIdx) ' ... skipping low-pass filtering']);
        else
            if ~isfield(PAT.jobsdone,'LPFOK') || job.force_redo
                % Get colors to include information
                IC = job.IC;
                colorNames = fieldnames(PAT.color);
                % Radius of the gaussian kernel in pixels
                K.radius = round(job.spatial_LPF.spatial_LPF_On.spatial_LPF_radius/PAT.PAparam.pixDepth);
                % Save LPF settings in pixels
                PAT.fcPAT.LPF(1).radius = K.radius;
                PAT.fcPAT.LPF(1).sigma = K.radius/2;
                PAT.fcPAT.LPF(1).radius_mm = job.spatial_LPF.spatial_LPF_On.spatial_LPF_radius;

                % Loop over available colors
                for c1=1:length(PAT.nifti_files)
                    doColor = pat_doColor(PAT,c1,IC);
                    if doColor
                        colorOK = true;
                        %skip B-mode only extract PA
                        if ~(PAT.color.eng(c1)==PAT.color.Bmode)
                            % HbT/SO2 filenames
                            fname_list = PAT.nifti_files(:,c1);
                            % Color names
                            colorNames = fieldnames(PAT.color);
                            
                            % Loop over files
                            for f1 = 1:size(fname_list,1)
                                try
                                    fname = fname_list{f1};
                                    vol = spm_vol(fname);
                                    imagesTimeCourse = spm_read_vols(vol);
                                    % Time dimension is always the 4th when
                                    % volumes are created with pat_create_vol
                                    [K.k1 K.k2 d3 nT] = size(imagesTimeCourse);
                                    imagesTimeCourseLPF = zeros([K.k1 K.k2 d3 nT]);
                                    if K.k1 <= 1 || K.k2 <= 1
                                        colorOK = false;
                                    end
                                catch
                                    colorOK = false;
                                end
                            end % Loop over files
                            
                            % Low-pass filtering
                            K = pat_spatial_LPF('set', K);
                            % Initialize progress bar
                            spm_progress_bar('Init', nT, sprintf('Spatial LPF, color %d (%s)\n',c1,colorNames{1+c1}), 'Frames');
                            pat_text_waitbar(0, sprintf('Spatial LPF, color %d (%s)\n',c1,colorNames{1+c1}));
                            for iT = 1:nT,
                                imagesTimeCourseLPF(:,:,1,iT) = pat_spatial_LPF('lpf', K, squeeze(imagesTimeCourse(:,:,1,iT)));
                                % Update progress bar
                                spm_progress_bar('Set', iT);
                                pat_text_waitbar(iT/nT, sprintf('Low pass filtering slice %d from %d', iT, nT));
                            end
                            % Clear progress bar
                            spm_progress_bar('Clear');
                            pat_text_waitbar('Clear');
                            
                            % Backup the original images
                            local_backup_nifti(PAT, f1, c1);
                            fprintf('Creating NIfTI volume from %s...\n',PAT.nifti_files{f1,c1});
                            
                            % Initialize progress bar
                            spm_progress_bar('Init', nT, sprintf('Saving NIfTI, color %d (%s)\n',c1,colorNames{1+c1}), 'Frames');
                            pat_text_waitbar(0, sprintf('Saving NIfTI, color %d (%s)\n',c1,colorNames{1+c1}));
                            % Creates NIfTI volume frame by frame
                            for iT = 1:nT,
                                pat_create_vol(fname, vol(iT).dim, vol(iT).dt, vol(iT).pinfo,...
                                    vol(iT).mat, iT,...
                                    squeeze(imagesTimeCourseLPF(:,:,1,iT)));
                                % Update progress bar
                                spm_progress_bar('Set', iT);
                                pat_text_waitbar(iT/nT, sprintf('Saving slice %d from %d', iT, nT));
                            end
                            % Clear progress bar
                            spm_progress_bar('Clear');
                            pat_text_waitbar('Clear');
                            fprintf('%d frames saved to NIfTI volume: %s\n',nT,PAT.nifti_files{f1,c1});
                            
                        end % Skip B-mode
                        if colorOK
                            fprintf('Spatial low-pass filtering for color %d (%s) completed\n',c1,colorNames{1+c1})
                        end
                    end
                end % colors loop
            end
            % LPF succesful!
            PAT.jobsdone(1).LPFOK = true;
            save(PATmat,'PAT');
        end % LPF OK or redo job
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        fprintf('Scan %d of %d complete\n', scanIdx, length(job.PATmat));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end % End try
end % Scans loop
end % End function

function local_backup_nifti(PAT, f1, c1)
% Backup NIfTI files, they will be copied with the extension .nolpf, and the
% low-pass filtered data will be overwritten to the original NIfTI files.
[pathName, fileName, fileExt] = fileparts(PAT.nifti_files{f1,c1});
backupName = fullfile(pathName, [fileName '.nolpf' fileExt]);
copyfile(PAT.nifti_files{f1,c1}, backupName);
end

% EOF
