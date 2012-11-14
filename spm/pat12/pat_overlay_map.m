function h = pat_overlay_map(anatomical, positiveMap, mapRange, titleString)
% Creates an overlay image composed of positive & negative functional maps (any
% contrast, correlation, z, p-value, etc.) onto an anatomical image.
% The images must be saved as NIfTI (.nii) files and they can have different
% sizes. This function makes use of slover and paint functions of SPM8.
% The positive map is plotted in hot colormap, the negative map is cold and the
% anatomical is grayscale by default. The image has the following orientation:
% 
%         |
%         |
%         | Left
%         |        
% ________|
% Rostral
% 
% SYNTAX
% h = ioi_overlay_map(anatomical,positiveMap,negativeMap,mapRange,titleString)
% INPUTS
% anatomical    NIfTI (.nii) filename with anatomical image for background.
% positiveMap   NIfTI (.nii) filename with positive functional map on the
%               foreground.
% negativeMap   NIfTI (.nii) filename with negativ functional map on the
%               foreground.
% titleString           String with the title to be displayed.
% mapRange      2-element vector with the data range to be displayed.
% OUTPUT
% h             Handle to the figure
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________


% Necessary to get rid of old overlay objects
clear imagesOverlay
% Make cell with file names
imagesOverlay{1,1}  = anatomical;           % Anatomical image
imagesOverlay{2,1}  = positiveMap;          % Pos. correlation%
%imagesOverlay{3,1}  = negativeMap;          % Neg. correlation

% Handle of current figure;
h = gcf;

% Make mapRange a column vector
if size(mapRange, 1) == 1
    mapRange = mapRange';
end

% Create overlay object
slObj = slover(char(imagesOverlay));

% vol = spm_vol(anatomical);
% im_anat = spm_read_vols(vol);
% vol = spm_vol(positiveMap);
% im_pos = spm_read_vols(vol);
% vol = spm_vol(negativeMap);
% im_neg = spm_read_vols(vol);
% 
% vol1 = slover('matrix2vol', anatomical, vol.mat);

slObj.slices = 1;                           % For PAT images only 1 slice (2D)
                                            % Automatic range for image 1 (anatomy)
slObj.img(2).range = mapRange;              % Range for positive map
%slObj.img(3).range = [0.5 1];    % Same range for negative map
slObj.img(1).type = 'truecolor';            % Anatomical image
slObj.img(2).type = 'split';                % Pos. map
%slObj.img(3).type = 'split';                % Neg. map
slObj.img(1).cmap = gray(256);              % Colormap for anatomy
slObj.img(2).cmap = hot(256);               % Colormap for positive map
%slObj.img(3).cmap = winter(256);            % Colormap for negative map
slObj.cbar = [2];                         % Plot colorbars for images 2 & 3
slObj.area.valign = 'middle';               % Vertical alignment
slObj.area.halign = 'center';               % Horizontal alignment
slObj.img(1).prop = 1;                      % Proportion of intensity for anatomy
slObj.img(2).prop = 1;                      % Proportion of intensity for positive map
%slObj.img(3).prop = 1;                      % Proportion of intensity for negative map
slObj.img(1).outofrange =  {0 255};         % Behavior for image values out of range 
slObj.img(2).outofrange =  {0 255};
%slObj.img(3).outofrange =  {0 255};
slObj.labels = 'none';                      % No labels on this slice
  
% Redraw the object (e.g. after window maximization)
slObj = paint(slObj);

% Display title
title(titleString, 'Color', 'w', 'Interpreter', 'None');
% Change figure name
% set(slObj.figure,'Name',titleString);

% EOF
