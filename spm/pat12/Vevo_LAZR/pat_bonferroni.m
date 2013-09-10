function q = pat_bonferroni(p)
% The Bonferroni procedure gives a corrected p-value for the number of
% comparisons, controlling family-wise error
% SYNTAX
% q = pat_bonferroni(p)
% INPUT
% p     Raw p-value
% OUTPUT
% q     Corrected p-value
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
q = p .* numel(p);
if q > 1
    q = 1;
end
% EOF
