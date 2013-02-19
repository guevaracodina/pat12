function cleanupOK = pat_fc_GLM_on_ROI_cleanup(PAT, job)
% Cleanup SPM generated files during the GLM regression. Keeps only the .nii
% files of the regressed ROI/whole image time course.
% SYNTAX
% cleanupOK = pat_fc_GLM_on_ROI_cleanup(PAT, job)
% INPUT
% PAT       PAT structure
% OUTPUT
% cleanupOK True if cleanup was succesful.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

cleanupOK = false;
try
    eTime = tic;
    % Get colors to include information
    IC = job.IC;
    [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
    scanName = splitStr{end-1};
    % Cell with names of files to be deleted
    files2Delete = {
        'beta_0001.hdr'
        'beta_0001.img'
        'mask.hdr'
        'mask.img'
        'ResMS.hdr'
        'ResMS.img'
        'RPV.hdr'
        'RPV.img'
        'SPM.mat'
        };
    iSessions = 1; % Only 1 session per scan in PAT
    if job.wholeImage
        % ----------------------------------------------------------------------
        % Clean-up files from whole image regression
        % ----------------------------------------------------------------------
        % Loop over available colors
        for iColors = 1:length(PAT.nifti_files)
            doColor = pat_doColor(PAT, iColors, IC);
            if doColor
                % Only remove SPM files if regression was succesful
                if PAT.fcPAT.SPM.wholeImageRegressOK{iSessions, iColors}
                    % Loop over files to delete
                    for iFiles = 1:numel(files2Delete)
                        fName = fullfile(PAT.fcPAT.SPM.fnameSPM{iSessions, iColors},...
                            files2Delete{iFiles});
                        % Undocumented MATLAB feature to delete files with Java
                        java.io.File(fName).delete();
                    end
                end
            end
        end
        % ----------------------------------------------------------------------
    end
    
    % --------------------------------------------------------------------------
    % Clean-up files from ROIs regression
    % --------------------------------------------------------------------------
    % Loop over ROIs
    for iROI = 1:numel(PAT.fcPAT.SPM.fnameROISPM)
        % Loop over colors
        for iColors = 1:size(PAT.fcPAT.SPM.fnameROISPM{iROI}, 2)
            doColor = pat_doColor(PAT, iColors, IC);
            if doColor
                % Only remove SPM files if regression was succesful
                if PAT.fcPAT.SPM.ROIregressOK{iROI}{iSessions, iColors}
                    % Loop over files to delete
                    for iFiles = 1:numel(files2Delete)
                        fName = fullfile(PAT.fcPAT.SPM.fnameROISPM{iROI}{iSessions, iColors},...
                            files2Delete{iFiles});
                        % Undocumented MATLAB feature to delete files with Java
                        java.io.File(fName).delete();
                    end
                end
            end
        end
    end
    % --------------------------------------------------------------------------
    
    % Clean up succesful
    cleanupOK = true;
    fprintf('Cleanup GLM files for %s done! Elapsed time: %s\n',...
        scanName, datestr(datenum(0,0,0,0,0,toc(eTime)),'HH:MM:SS'));
catch exception
    cleanupOK = false;
    disp(exception.identifier)
    disp(exception.stack(1))
end

% EOF
