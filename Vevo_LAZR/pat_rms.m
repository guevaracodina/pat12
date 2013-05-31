function y = pat_rms(x, dim)
% pat_rms    Root mean squared value.
%   For vectors, pat_rms(X) is the root mean squared value in X. For matrices,
%   pat_rms(X) is a row vector containing the pat_rms value from each column. For
%   N-D arrays, pat_rms(X) operates along the first non-singleton dimension.
%
%   Y = pat_rms(X,DIM) operates along the dimension DIM.
%
%   When X is complex, the RMS is computed using the magnitude
%   RMS(ABS(X)). 
%
%   % Example #1: RMS of sinusoid vector 
%   x = cos(2*pi*(1:100)/100);
%   y = pat_rms(x)
%
%   % Example #2: RMS of columns of matrix
%   x = [rand(100000,1) randn(100000,1)]; 
%   y = pat_rms(x, 1)  
%
%   % Example #3: RMS of rows of matrix
%   x = [2 -2 2; 3 3 -3]; 
%   y = pat_rms(x, 2)  
%
%   See also MIN, MAX, MEDIAN, MEAN, STD, PEAK2RMS.

%   Copyright 2011 The MathWorks, Inc.

if nargin==1
  y = sqrt(mean(x .* conj(x)));
else
  y = sqrt(mean(x .* conj(x), dim));
end

% EOF

