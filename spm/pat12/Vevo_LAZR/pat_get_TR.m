function TR = pat_get_TR(PAT)
% Gets sampling period of current scan.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

if isfield(PAT.jobsdone, 'extract_rawBmode') && isfield(PAT.bModeParam, 'bmode_frameData_fname')
    fname = PAT.bModeParam.bmode_frameData_fname{1};
    fid = fopen(fname);    
    data = textscan(fid, '%s %d: %s %d, %s = %f, %s %d', 'HeaderLines', 8, 'CollectOutput', true);
    TR = median(diff(data{1,6})) / 1000;    % TR in seconds, data{1,6} in ms
    fclose(fid);
else
    TR = [];
    fprintf('B-mode images not extracted. Impossible to retrieve sampling period TR.\n');
end

% EOF
