%% 
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________


% Place optional args in memorable variable names
dataFolder = 'D:\Edgar\Data\PAT_Data\';

% Check if dataFolder is a valid directory, else get current working dir
if ~exist(dataFolder,'dir')
    dataFolder = pwd;
end

% Separate subdirectories and files:
d = dir(dataFolder);
isub = [d(:).isdir];            % Returns logical vector
folderList = {d(isub).name}';
% Remove . and ..
folderList(ismember(folderList,{'.','..'})) = [];

%% Choose the subjects folders
[subjectList, sts] = cfg_getfile(Inf,'dir','Select subject folders',folderList, dataFolder, '.*'); %dataFolder

%% Arrange scans for every subject folder
if sts
    for iFolders = 1:numel(subjectList)
        d = dir(fullfile(subjectList{iFolders},'*.pamode'));
        if ~isempty(d)
            for iFiles = 1:numel(d)
                fileName = fullfile(subjectList{iFolders},d(iFiles).name);
                pat_raw2nifti(fileName);
            end
        else
            fprintf('No .pamode files in %s\n',subjectList{iFolders})
        end
    end
else
    disp('User cancelled input')
end
%%
fileName = fullfile('D:\Edgar\Data\PAT_Data\2012-09-07-10-40-07\','2012-09-07-10-40-07.raw.pamode');
pat_raw2nifti(fileName);
fileName = fullfile('D:\Edgar\Data\PAT_Data\2012-09-07-11-04-40\','2012-09-07-11-04-40.raw.pamode');
pat_raw2nifti(fileName);
