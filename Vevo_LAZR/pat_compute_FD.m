function FD = pat_compute_FD(Q, radius)
% Computes framewise displacement (FD) calculation from motion parameters Q
% SYNTAX
% FD = pat_compute_FD(Q, radius)
% INPUT
% Q         6 Motion parameters (XYZ translation, pitch, roll, yaw)
% radius    Approximate mean distance from the cerebral cortex to the center of
%           the head in P3 rat pups
% OUTPUT 
% FD        Framewise displacement
% Reference
% [1] J. D. Power, K. A. Barnes, A. Z. Snyder, B. L. Schlaggar, and S. E.
% Petersen, “Spurious but systematic correlations in functional connectivity MRI
% networks arise from subject motion,” Neuroimage, vol. 59, no. 3, pp.
% 2142–2154, Feb. 2012.
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moleculaire
%                    Ecole Polytechnique de Montreal
%_______________________________________________________________________________

% Rotational displacements Q(:,4:6) were converted from degrees to millimeters
% by calculating displacement on the surface of a sphere of radius 4 mm, which
% is approximately the mean distance from the cerebral cortex to the center of
% the head in P3 rat pups
Q(:,4:6) = pi * radius * Q(:,4:6) / 180;
% To express instantaneous head motion as a scalar quantity we used the
% empirical formula, FDi=|Ddix|+|Ddiy|+|Ddiz|+|Dai|+ |Dbi|+|Dci|, where
% Ddix=d(i-1)x-dix, and similarly for the other rigid body parameters [dix diy
% diz ai bi ci]
FD = sum(abs(diff(Q)),2);
% We add a zero at the beginning all subsequent images are aligned to the 1st.
FD = [0; FD];
end

% EOF
