function out = pat_rename_roi_run(job)
% Rename existing ROIs
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

%Big loop over scans
for scanIdx = 1:length(job.PATmat)
    try
        eTime = tic;
        % Rename ROIs
        [PATmat scanName] = internal_rename_roi(job, scanIdx);
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS')]);
        fprintf('Scan %s, %d of %d complete %30s\n', scanName, scanIdx, length(job.PATmat), spm('time'));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        out.PATmat{scanIdx} = PATmat;
        disp(exception.identifier)
        disp(exception.stack(1))
    end
end % loop over scans
end % pat_rename_roi_run

function [PATmat scanName] = internal_rename_roi(job, scanIdx)
% Load PAT.mat information
[PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
[~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
scanName = splitStr{end-1};
if ~isfield(PAT.jobsdone, 'ROIOK') % ROI OK
    fprintf('No ROIs available for %s. Scan %d of %d ... skipping ROI renaming\n',scanName, scanIdx, length(job.PATmat));
else
    if ~isfield(PAT.jobsdone,'ROIrenameOK') || job.force_redo
        if numel(PAT.ROI.ROIname) == numel(job.ROInames)
            % Rename ROIs
            for iROI = 1:numel(PAT.ROI.ROIname)
                PAT.ROI.ROIname{iROI} = job.ROInames{iROI};
                PAT.res.ROI{iROI}.name = job.ROInames{iROI};
            end
            % Rename succesful!
            PAT.jobsdone.ROIrenameOK = true;
            % Save PAT matrix
            save(PATmat,'PAT');
        else
            fprintf('Mismatch in ROIs number for %s. Scan %d of %d ... skipping scrubbing\n',scanName, scanIdx, length(job.PATmat));
        end
    end % ROIrenameOK OK or redo job
end % ROI OK
end % internal_rename_roi

% EOF

