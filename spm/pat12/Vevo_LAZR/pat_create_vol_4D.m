function hdr = pat_create_vol_4D(fname, vol, data)
% Create a 4-D NIfTI volume,
% SYNTAX
% hdr = pat_create_vol_4D(fname, vol, data)
% INPUTS
% fname     - the filename of the image.
% vol       - Header structure with image volume information in the following
%               fields:
%     dim       - the x, y and z dimensions of the volume
%     dt        - A 1x2 array.  First element is datatype (see spm_type).
%                   The second is 1 or 0 depending on the endian-ness.
%     pinfo     - plane info for each plane of the volume.
%                 pinfo(1,:) - scale for each plane
%                   pinfo(2,:) - offset for each plane
%                     The true voxel intensities of the jth image are given
%                       by: val*pinfo(1,j) + pinfo(2,j)
%                   pinfo(3,:) - offset into image (in bytes).
%                     If the size of pinfo is 3x1, then the volume is assumed
%                       to be contiguous and each plane has the same scalefactor
%                       and offset.
%     mat       - a 4x4 affine transformation matrix mapping from
%                 voxel coordinates to real world coordinates.
% data      - A 4-D matrix with volume time-series data
% OUTPUT
% hdr       - Header with image volume information.
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Get total number of frames (slices)
nFrames = size(data,4);

% Initialize progress bar
spm_progress_bar('Init', nFrames, sprintf('Writing frames to 4-D NIfTI'), 'Frames');
pat_text_waitbar(0, sprintf('Writing frames to 4-D NIfTI'))      % ascii progress bar

% Creates NIfTI volume frame by frame
for iFrames = 1:nFrames
    if numel(vol) == nFrames
    hdr = pat_create_vol(fname, vol(iFrames).dim, vol(iFrames).dt, ...
        vol(iFrames).pinfo, vol(iFrames).mat, iFrames,...
        squeeze(data(:,:,1,iFrames)));
    else
        % User chose the same parameters for all slices
        hdr = pat_create_vol(fname, vol(1).dim, vol(1).dt, ...
        vol(1).pinfo, vol(1).mat, iFrames,...
        squeeze(data(:,:,1,iFrames)));
    end
    % Update progress bar
    spm_progress_bar('Set', iFrames);
    pat_text_waitbar(iFrames/nFrames, sprintf('Frame %d of %d', iFrames, nFrames)); 
end

% Clear progress bar
spm_progress_bar('Clear');
pat_text_waitbar('Clear')

% EOF
