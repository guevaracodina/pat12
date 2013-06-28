function doColor = pat_doColor(PAT, c1, IC)
% Determines if color c1 is to be processed for this batch if selected in
% pat_include_colors_cfg options.
% SYNTAX
% doColor = pat_doColor(PAT, c1, IC)
% INPUTS
% PAT       PAT structure
% c1        Color index
% IC        Include color job structure
% OUTPUT
% doColor   True if color is to be processed
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

doColor = true;
% potentially exclude various colors, to save time

try
    if ~IC.include_HbT
        if PAT.color.eng(c1) == PAT.color.HbT
            doColor = false;
        end
    end
end

try
    if ~IC.include_SO2
        if PAT.color.eng(c1) == PAT.color.SO2
            doColor = false;
        end
    end
end

try
    if ~IC.include_Bmode
        if PAT.color.eng(c1) == PAT.color.Bmode
            doColor = false;
        end
    end
end

try
    if ~IC.include_HbO
        if PAT.color.eng(c1) == PAT.color.HbO
            doColor = false;
        end
    end
end

try
    if ~IC.include_HbR
        if PAT.color.eng(c1) == PAT.color.HbR
            doColor = false;
        end
    end
end

% EOF
