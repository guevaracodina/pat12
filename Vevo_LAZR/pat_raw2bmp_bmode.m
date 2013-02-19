function fileNameTXT = pat_raw2bmp_bmode(rawBmodeFname, dir_patmat, bmp_dir)
% Extraction of B-Mode RAW data. Saves frames as a series of figures (.BMP).
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

fprintf('Extracting B-mode data from %s...\n', rawBmodeFname)
fprintf('VsiBModeRAW Copyright (c) 1999-2011 VisualSonics Inc.\n');
% XML file with B-mode information
fileNameXML     = regexprep(rawBmodeFname,'\.bmode','.xml');
% Output prefix
outputPrefix    = 'B-Mode-RAW';
% text file where the frame data will be saved
fileNameTXT     = fullfile(dir_patmat, 'bModeframeData.txt');
% Finds the full path name of the executable file
fileNameEXE     = which('VsiBModeRAW.exe');
% Saves current folder location
currentFolder   = pwd;
% Goes to the folder where the images will be saved
cd(bmp_dir);

% fprintf('VsiBModeRAW.exe <Data.raw.bmode> <Data.raw.xml> <OutputPrefix>\n');
% Extracts B-Mode RAW data and saves a series of figures (.BMP)
system([fileNameEXE ' ' rawBmodeFname ' ' fileNameXML ' ' outputPrefix ' ' '>' ' ' fileNameTXT]);

% Returns to original folder
cd(currentFolder);
fprintf('B-mode images extracted to %s\n', bmp_dir)
% Compress .BMP images to .PNG
internal_convertBMP2PNG(bmp_dir);
end

function internal_convertBMP2PNG(bmp_dir)
% Converts .BMP files to .PNG files in order to save disk space
% Current path
currPath = pwd;
% Go to .BMP images folder
cd(bmp_dir)
% Get filenames
files = dir(fullfile(bmp_dir,'*.BMP'));
% Initialize progress bar
spm_progress_bar('Init', numel(files), sprintf('Conversion to .PNG files\n'), '.BMP files');
pat_text_waitbar(0, sprintf('Conversion to .PNG files'));
for iFiles = 1:numel(files)
    % Read .BMP file
    rgb = imread(files(iFiles).name, 'bmp');
    % Get name
    [~, fileName, ~] = fileparts(files(iFiles).name);
    % Write as .PNG
    imwrite(rgb, fullfile(bmp_dir,[fileName '.png']), 'png');
    % Delete .BMP file
    % delete(files(iFiles).name)
    % Undocumented MATLAB feature to delete files with Java
    java.io.File(files(iFiles).name).delete();
    % Update progress bar
    spm_progress_bar('Set', iFiles);
    pat_text_waitbar(iFiles/numel(files), sprintf('Processing file %d from %d', iFiles, numel(files)));
end
% Return to current path
cd(currPath)
% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear');
end

% EOF
