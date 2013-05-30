function hdr = pat_create_vol(fname, dim, dt, pinfo, mat, n, data, varargin)
% Create a NIfTI volume slice by slice.
% SYNTAX
% hdr = pat_create_vol(fname, dim, dt, pinfo, mat, n, data)
% INPUTS
% fname     - the filename of the image.
% dim       - the x, y and z dimensions of the volume
% dt        - A 1x2 array.  First element is datatype (see spm_type).
%               The second is 1 or 0 depending on the endian-ness.
% pinfo     - plane info for each plane of the volume.
%           	pinfo(1,:) - scale for each plane
%               pinfo(2,:) - offset for each plane
%               	The true voxel intensities of the jth image are given
%                   by: val*pinfo(1,j) + pinfo(2,j)
%               pinfo(3,:) - offset into image (in bytes).
%               	If the size of pinfo is 3x1, then the volume is assumed
%                   to be contiguous and each plane has the same scalefactor
%                   and offset.
% mat       - a 4x4 affine transformation matrix mapping from
%           	voxel coordinates to real world coordinates.
% n         - Slice position
% data      - A 4-D matrix with volume time-series data
% descrip   - Descriptive text
% OUTPUT
% hdr       - Header with image volume information.
%_______________________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% Optional inputs handling
% ------------------------------------------------------------------------------
% only want true optional input at most
numvarargs              = length(varargin);
if numvarargs > 1
    error('pat12:pat_create_vol:TooManyInputs', ...
        'Requires at most 1 optional inputs');
end
% set defaults for optional inputs
optargs                 = {'Created with pat12'};
% now put these defaults into the optargs cell array, and overwrite the ones
% specified in varargin.
optargs(1:numvarargs)   = varargin;
% Place optional args in memorable variable names
[descrip]               = optargs{:};
% ------------------------------------------------------------------------------

hdr = struct(   'fname',    fname,...
                'dim',      dim,...
                'dt',       dt,...
                'pinfo',    pinfo,...
                'mat',      mat,...
                'n',        n, ...
                'descrip',  descrip);
hdr = spm_create_vol(hdr);
spm_write_vol(hdr, data);
end
