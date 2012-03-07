function out = pat_ica_run(job)
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
%
% Perform ICA with a standard set of parameters, including skewness as the
% objective function
%
% Inputs:
%   mixedsig - N x T matrix of N temporal signal mixtures sampled at T
%   points.
%   mixedfilters - N x X x Y array of N spatial signal mixtures sampled at
%   X x Y spatial points.
%   CovEvals - eigenvalues of the covariance matrix
%   PCuse - vector of indices of the components to be included. If empty,
%   use all the components
%   mu_tmp - parameter (between 0 and 1) specifying weight of temporal
%   information in spatio-temporal ICA
%   nIC - number of ICs to derive
%   termtol - termination tolerance; fractional change in output at which
%   to end iteration of the fixed point algorithm.
%   maxrounds - maximum number of rounds of iterations
%
% Outputs:
%     ica_sig - nIC x T matrix of ICA temporal signals
%     ica_filters - nIC x X x Y array of ICA spatial filters
%     ica_A - nIC x N orthogonal unmixing matrix to convert the input to output signals
%     numiter - number of rounds of iteration before termination
%
% Routine is based on the fastICA package (Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo
% Hyvärinen, http://www.cis.hut.fi/projects/ica/fastica)
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%

PATmat=job.PATmat;
% Loop over acquisitions

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        PAT.ICA.nICs = job.nICs;
        
        ica_A_guess = randn(length(PAT.PCA.PCuse), PAT.ICA.nICs);
        
        if PAT.ICA.nICs>length(PAT.PCA.PCuse)
            disp('Cannot estimate more ICs than the number of PCs, truncating.')
            PAT.ICA.nICs = PAT.PCA.PCuse;
        end
        PAT.ICA.mu=job.st_param;
        PAT.ICA.max_rounds=job.max_rounds;
        PAT.ICA.term_tol=job.tolerance_factor;
        
        [pixw,pixh] = size(PAT.PCA.mixedfilters(:,:,1));
        npix = pixw*pixh;
        
        % Select PCs
        % Use spatial info
        if PAT.ICA.mu > 0 || ~isempty(PAT.PCA.mixedsig)
            mixedsig = PAT.PCA.mixedsig(PAT.PCA.PCuse,:);
        end
        if PAT.ICA.mu < 1 || ~isempty(PAT.PCA.mixedfilters)
            mixedfilters = reshape(PAT.PCA.mixedfilters(:,:,PAT.PCA.PCuse),npix,length(PAT.PCA.PCuse));
        end
        CovEvals = PAT.PCA.CovEvals(PAT.PCA.PCuse);
        
        % Center the data by removing the mean of each PC
        mixedmean = mean(mixedsig,2);
        mixedsig = mixedsig - mixedmean * ones(1, size(mixedsig,2));
        
        % Create concatenated data for spatio-temporal ICA
        nx = size(mixedfilters,1);
        nt = size(mixedsig,2);
        if PAT.ICA.mu == 1
            % Pure spectral ICA
            sig_use = mixedsig;
        elseif PAT.ICA.mu == 0
            % Pure spatial ICA
            sig_use = mixedfilters';
        else
            % Spatial-spectral ICA
            sig_use = [(1-PAT.ICA.mu)*mixedfilters', PAT.ICA.mu*mixedsig];
            sig_use = sig_use / sqrt(1-2*PAT.ICA.mu+2*PAT.ICA.mu^2); % This normalization ensures that, if both mixedfilters and mixedsig have unit covariance, then so will sig_use
        end
        
        % Perform ICA
        [ica_A, numiter] = fpica_standardica(sig_use, PAT.ICA.nICs, ica_A_guess, PAT.ICA.term_tol, PAT.ICA.max_rounds);
        
        % Sort ICs according to skewness of the spectral component
        ica_W = ica_A';
        
        ica_sig = ica_W * mixedsig;
        ica_filters = reshape((mixedfilters*diag(CovEvals.^(-1/2))*ica_A)', PAT.ICA.nICs, nx);  % This is the matrix of the generators of the ICs
        ica_filters = ica_filters / npix^2;
        
        icskew = skewness(ica_sig');
        [icskew, ICord] = sort(icskew, 'descend');
        
        PAT.ICA.A = ica_A(:,ICord);
        PAT.ICA.sig = ica_sig(ICord,:);
        PAT.ICA.filters = ica_filters(ICord,:);
        PAT.ICA.filters = reshape(ica_filters, PAT.ICA.nICs, pixw, pixh);
        PAT.jobsdone.ica = 1;
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end
end

% Note that with these definitions of ica_filters and ica_sig, we can decompose
% the sphered and original movie data matrices as:
%     mov_sphere ~ mixedfilters * mixedsig = ica_filters * ica_sig = (mixedfilters*ica_A') * (ica_A*mixedsig),
%     mov ~ mixedfilters * pca_D * mixedsig.
% This gives:
%     ica_filters = mixedfilters * ica_A' = mov * mixedsig' * inv(diag(pca_D.^(1/2)) * ica_A'
%     ica_sig = ica_A * mixedsig = ica_A * inv(diag(pca_D.^(1/2))) * mixedfilters' * mov

function [B, iternum] = fpica_standardica(X, nIC, ica_A_guess, termtol, maxrounds)

numSamples = size(X,2);

B = ica_A_guess;
BOld = zeros(size(B));

iternum = 0;
minAbsCos = 0;

errvec = zeros(maxrounds,1);
while (iternum < maxrounds) && ((1 - minAbsCos)>termtol)
    iternum = iternum + 1;
    
    % Symmetric orthogonalization.
    B = (X * ((X' * B) .^ 2)) / numSamples;
    B = B * real(inv(B' * B)^(1/2));
    
    % Test for termination condition.
    minAbsCos = min(abs(diag(B' * BOld)));
    
    BOld = B;
    errvec(iternum) = (1 - minAbsCos);
end

if iternum<maxrounds
    fprintf('Convergence in %d rounds.\n', iternum)
else
    fprintf('Failed to converge; terminating after %d rounds, current change in estimate %3.3g.\n', ...
        iternum, 1-minAbsCos)
end
end


