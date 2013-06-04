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
    % Cell with names of files to be deleted (up to 20 regressors)
    files2Delete = {
        'beta_0001.hdr'
        'beta_0001.img'
        'beta_0002.hdr'
        'beta_0002.img'
        'beta_0003.hdr'
        'beta_0003.img'
        'beta_0004.hdr'
        'beta_0004.img'
        'beta_0005.hdr'
        'beta_0005.img'
        'beta_0006.hdr'
        'beta_0006.img'
        'beta_0007.hdr'
        'beta_0007.img'
        'beta_0008.hdr'
        'beta_0008.img'
        'beta_0009.hdr'
        'beta_0009.img'
        'beta_0010.hdr'
        'beta_0010.img'
        'beta_0011.hdr'
        'beta_0011.img'
        'beta_0012.hdr'
        'beta_0012.img'
        'beta_0013.hdr'
        'beta_0013.img'
        'beta_0014.hdr'
        'beta_0014.img'
        'beta_0015.hdr'
        'beta_0015.img'
        'beta_0016.hdr'
        'beta_0016.img'
        'beta_0017.hdr'
        'beta_0017.img'
        'beta_0018.hdr'
        'beta_0018.img'
        'beta_0019.hdr'
        'beta_0019.img'
        'beta_0020.hdr'
        'beta_0020.img'
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
