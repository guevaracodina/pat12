function [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx)
% Reads PAT matrix info
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________
PAT = [];
PATmat = job.PATmat{scanIdx};
[dir_patmat dummy] = fileparts(job.PATmat{scanIdx});
if isfield(job.PATmatCopyChoice,'PATmatCopy')
    newDir = job.PATmatCopyChoice.PATmatCopy.NewPATdir;
    newDir = fullfile(dir_patmat,newDir);
    if ~exist(newDir,'dir'),mkdir(newDir); end
    PATmat = fullfile(newDir,'PAT.mat');
    dir_patmat = newDir;
end
try
    load(PATmat);
    display([PATmat ' now loaded']);
catch
    % XXX: This is not true, if we create a new dir, then there should be no
    % error... 
    load(job.PATmat{scanIdx});
    display([PATmat ' not found -- ' job.PATmat{scanIdx} ' now loaded']);
end

% EOF
