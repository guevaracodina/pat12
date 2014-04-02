function colormapOut = pat_get_colormap(map)
% Creates colormaps that are adequate to display images in SS-OCT system. Also
% creates maps adequate for photoacoustic tomography.
% SYNTAX:
% colormapOut = pat_get_colormap(map)
% INPUTS:
% map           String that describes the colormap to retrieve:
%               'octgold'
%               'fdrainbow'
%               'tdrainbow'
%               'wob'
%               'bow'
%               'flow'
%               'rwbdoppler'
%               'bwrdoppler'
%               'robdoppler'
%               'bordoppler'
%               'redmap'
%               'greenmap'
%               'bluemap'
%               'so2'
%               'bipolar'
% OUTPUTS:
% colormapOut   3 columns matrix, which values are in the range from 0 to 1.
%_______________________________________________________________________________
% Copyright (C) 2013 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
% Edgar Guevara
% 2013/05/22

ColorMapSize = 128;

switch lower(map)
    case 'octgold'
        % OCT Gold: typical high contrast, high dynamic OCT map
        x = [0 7 60 108 157 190 224 253 254 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.0352941   0           0;
            0.376471    0.105882    0;
            0.678431    0.337255    0;
            0.992157    0.701961    0.203922;
            0.992157    0.878431    0.341176;
            0.996078    0.996078    0.482353;
            0.94902     0.996078    0.603922;
            0.905882    0.952941    0.607843;
            0.905882    0.952941    0.607843];
    case 'fdrainbow'
        % Fourier-Domain Rainbow: multi-colour, high dynamic range colour map for
        % novel OCT systems
        x = [0 22 53 68 106 141 168 194 245 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.0313725   0.0313725   0.117647;
            0.00392157  0.113725    0.541176;
            0.203922    0.486275    0.207843;
            0.294118    0.780392    0.145098;
            0.847059    0.752941    0.435294;
            1           0.966912    0.0735296;
            0.992157    0.792157    0.411765;
            1           0.3         0.3;
            1           0.984314    0.984314];
    case 'tdrainbow'
        % Time-Domain Rainbow: mimicking the old time domain high dynamic range
        % colour map found in the commercial devices
        x = [32 64 78 138 221 255] + 1;
        rgb = [ ...
            0.00392157  0.00392157  0.0156863;
            0.3         0.3         1;
            0.176471    0.760784    0.254902;
            1           1           0.301961;
            1           0.3         0.3;
            1           0.984314    0.984314];
    case 'wob'
        % grey-scale with transparency for frequency domain OCT data
        x = [0 40 72 136 255] + 1;
        rgb = [...
            0.00392157  0.00392157  0.0156863;
            0           0           0;
            0.301961    0.301961    0.301961;
            0.733333    0.733333    0.733333;
            1           1           1];
    case 'bow'
        % grey-scale with transparency for frequency domain OCT data (not very
        % commonly used by the community, but good for faint signals)
        x = [0 35 96 148 255] + 1;
        rgb = [...
            1           1           1;
            0.890196    0.890196    0.890196;
            0.584314    0.584314    0.584314;
            0.282353    0.282353    0.282353;
            0           0           0];
    case 'flow'
        % High flow velocity contrast 20kHz
        x = [0 69 128 184 255] + 1;
        rgb = [...
            0.133333    0.188235    1;
            0.301961    0.760784    1;
            0.286275    0.913725    0.27451;
            0.972549    1           0.0862745;
            1           0.1         0.1];
    case 'rwbdoppler'
        % Red on blue, with white background for Doppler imaging
        % Also for SO2 contrast in photoacosutics
        minColor    = [0 0 1]; % blue
        medianColor = [1 1 1]; % white   
        maxColor    = [1 0 0]; % red      
       
        int1 = zeros(ColorMapSize,3); 
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bwrdoppler'
        % Blue on red, with white background for Doppler imaging
        minColor    = [1 0 0]; % red
        medianColor = [1 1 1]; % white
        maxColor    = [0 0 1]; % blue
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'robdoppler'
        % Red on blue, with black background for Doppler imaging
        minColor    = [0 0 1]; % blue
        medianColor = [0 0 0]; % white   
        maxColor    = [1 0 0]; % red      

        int1 = zeros(ColorMapSize,3); 
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bordoppler'
        % Blue on red, with black background for Doppler imaging
        minColor    = [1 0 0]; % red
        medianColor = [0 0 0]; % black
        maxColor    = [0 0 1]; % blue
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'so2'
        % Red on blue, sO2 PAT imaging
        minColor    = [0 0 1]; % blue
        medianColor = [0.5 0 0.5]; % ??
        maxColor    = [1 0 0]; % red
        
        int1 = zeros(ColorMapSize,3);
        int2 = zeros(ColorMapSize,3);
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'redmap'
        % Red map for HbT contrast in PAT, from VisualSonics
        minColor    = [0 0 0]; % black
        medianColor = [1 0 0]; % red
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'greenmap'
        % Green map
        minColor    = [0 0 0]; % black
        medianColor = [0 1 0]; % green
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bluemap'
        % Blue map
        minColor    = [0 0 0]; % black
        medianColor = [0 0 1]; % blue
        maxColor    = [1 1 1]; % white
        for k=1:3
            int1(:,k) = linspace(minColor(k), medianColor(k), ColorMapSize);
            int2(:,k) = linspace(medianColor(k), maxColor(k), ColorMapSize);
        end
        colormapOut = [int1(1:end-1,:); int2];
        return
    case 'bipolar'
        colormapOut = bipolar(2*ColorMapSize, 1/3);
        return
    otherwise
        % Inverted linear gray colormap
        colormapOut = flipud(colormap(gray(2*ColorMapSize)));
        return
end

%% Calculate colormap
% ----------------------- Piecewise linear interpolation -----------------------
nSegments           = numel(x) - 1;
samplesPerSegment   = diff(x);
colormapOut         = zeros([sum(samplesPerSegment) 3]);

for iSegments = 1:nSegments,
    for iColors = 1:3,
    colormapOut(x(iSegments):x(iSegments+1),iColors) = linspace(rgb(iSegments,iColors),...
        rgb(iSegments+1,iColors),...
        samplesPerSegment(iSegments)+1);
    end
end

% --------------- uint8 array to export colormaps to LabView -------------------
% colormapOut = uint8(round(colormapOut*255));
% figure; plot(colormapOut)

% ---------------------------- Spline interpolation ----------------------------
% colormapOut(:,1) = spline(x, rgb(:,1), (x(1):x(end))');
% colormapOut(:,2) = spline(x, rgb(:,2), (x(1):x(end))');
% colormapOut(:,3) = spline(x, rgb(:,3), (x(1):x(end))');
% colormapOut(colormapOut<0) = 0;         % Get rid of negative numbers
% colormapOut(colormapOut>1) = 1;         % Truncate to 1
% figure; plot(colormapOut)

%% OCT Gold Alpha channel
% x                   = [0; 22; 70; 123; 251] + 1;
% alphaValues         = [0; 0; 0.0543478; 0.717391; 1];
% nPoints             = numel(x);
% nSegments           = nPoints - 1;
% samplesPerSegment   = diff(x);
% OCTgoldAlphaMap     = zeros([sum(samplesPerSegment) 1]);
% 
% for iSegments = 1:nSegments,
%     OCTgoldAlphaMap(x(iSegments):x(iSegments+1)) = linspace(alphaValues(iSegments),...
%         alphaValues(iSegments+1),...
%         samplesPerSegment(iSegments)+1);
% end

% ==============================================================================

function cm = bipolar(m, n, interp)
%bipolar: symmetric/diverging/bipolar colormap, with neutral central color.
%
% Usage: cm = bipolar(m, neutral, interp)
%  neutral is the gray value for the middle of the colormap, default 1/3.
%  m is the number of rows in the colormap, defaulting to copy the current
%    colormap, or the colormap that MATLAB defaults for new figures.
%  interp is the method used to interpolate the colors, see interp1.
%
% The colormap goes from cyan-blue-neutral-red-yellow if neutral is < 0.5
% (the default) and from blue-cyan-neutral-yellow-red if neutral > 0.5.
%
% If neutral is exactly 0.5, then a map which yields a linear increase in
% intensity when converted to grayscale is produced (as derived in
% colormap_investigation.m). This colormap should also be reasonably good
% for colorblind viewers, as it avoids green and is predominantly based on
% the purple-yellow pairing which is easily discriminated by the two common
% types of colorblindness. For more details on this, see Brewer (1996):
% http://www.ingentaconnect.com/content/maney/caj/1996/00000033/00000002/art00002
% 
% Examples:
%  surf(peaks)
%  cmx = max(abs(get(gca, 'CLim')));
%  set(gca, 'CLim', [-cmx cmx]);
%  colormap(bipolar)
%
%  imagesc(linspace(-1, 1,201)) % symmetric data, if not set symmetric CLim
%  colormap(bipolar(201, 0.1)) % dark gray as neutral
%  axis off; colorbar
%  pause(2)
%  colormap(bipolar(201, 0.9)) % light gray as neutral
%  pause(2)
%  colormap(bipolar(201, 0.5)) % grayscale-friendly colormap
%
% See also: colormap, jet, interp1, colormap_investigation, dusk
% dusk is a colormap like bipolar(m, 0.5), in Oliver Woodford's real2rgb:
%  http://www.mathworks.com/matlabcentral/fileexchange/23342
%
% Copyright 2009 Ged Ridgway at gmail com
% Based on Manja Lehmann's hand-crafted colormap for cortical visualisation

if ~exist('interp', 'var')
    interp = [];
end

if ~exist('n', 'var') || isempty(n)
    n = 1/3;
end

if ~exist('m', 'var') || isempty(m)
    if isempty(get(0, 'CurrentFigure'))
        m = get(0, 'DefaultFigureColormap');
    else
        m = get(gcf, 'Colormap');
    end
    m = size(m, 1);
end

if n < 0
    % undocumented rainbow-variant colormap, not recommended, as explained 
    % by Borland & Taylor (2007) in IEEE Computer Graphics & Applications,
    % http://doi.ieeecomputersociety.org/10.1109/10.1109/MCG.2007.46
    if isempty(interp)
        interp = 'cubic'; % linear produces bands at pure green and yellow
    end
    n = abs(n);
    cm = [
        0 0 1
        0 1 0
        n n n
        1 1 0
        1 0 0
        ];
elseif n < 0.5
    if isempty(interp)
        interp = 'linear'; % seems to work well with dark neutral colors
    end
    cm = [
        0 1 1
        0 0 1
        n n n
        1 0 0
        1 1 0
        ];
elseif n > 0.5
    if isempty(interp)
        interp = 'cubic'; % seems to work better with bright neutral colors
    end
    cm = [
        0 0 1
        0 1 1
        n n n
        1 1 0
        1 0 0
        ];
else % exactly 0.5, use the brew2 scheme from colormap_investigation
    if isempty(interp)
        interp = 'linear';
    end
    if ~strcmp(interp, 'linear')
        warning('bipolar:nonlinearluminance', ...
            'Nonlinear interpolation will not preserve linear luminance!')
    end
    cm = [
        0.2157         0    0.3207
        0.0291    0.3072    1.0000
        0.5000    0.5000    0.5000
        1.0000    0.6035    0.3992
        0.9944    0.9891    0.1647
        ];
end

if m ~= size(cm, 1)
    xi = linspace(1, size(cm, 1), m);
    cm = interp1(cm, xi, interp);
end
% [EOF]
