function so2 = pat_raw2so2(raw)
% SYNTAX
% so2 = pat_raw2so2(raw)
% INPUT
% raw   Raw data imported from Vevo LAZR (Visualsonics)
% OUTPUT
% so2   Oxygen saturation values (SO2)
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________
maxVal = spm_type('uint16','maxval');
minVal = spm_type('uint16','minval');
maxValSo2 = 100;
minValSo2 = 0;
% y = mx + b
p = polyfit([minVal maxVal], [minValSo2 maxValSo2],1);
% slope
m = p(1);
% intercept
b = p(2);
so2 = m * raw + b;
% EOF
