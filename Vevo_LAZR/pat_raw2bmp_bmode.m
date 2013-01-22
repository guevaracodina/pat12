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

% EOF
