function [HbO HbR] = pat_get_hbo_hbr(HbT, SO2)
% Computes oxy- and deoxyhemoglobin from total hemoglobin & oxygen saturation.
% SYNTAX
% [HbO HbR] = pat_get_hbo_hbr(HbT, SO2)
% INPUTS
% HbT       Total hemoglobin
% SO2       Oxygen saturation
% OUTPUTS
% HbO       Oxyhemoglobin
% HbR       Deoxyhemoglobin
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% Check dimensions
if size(HbT) == size(SO2)
    if any((abs(SO2) > 1))
        % SO2 is in raw format, it has to be converte to fractional SO2
        SO2 = pat_raw2so2(SO2);
    end
    % Oxyhemoglobin
    HbO = SO2 .* HbT;
    % Deoxyhemoglobin
    HbR = (1 - SO2) .* HbT;
else
    error('pat12:pat_get_hbo_hbr', 'HbT & SO2 must have the same dimension')
end
end % pat_get_hbo_hbr
% EOF
