function out = pat_pca_run(job)
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________

%function [mixedsig, mixedfilters, CovEvals, covtrace, movm, ...
%    movtm] = PAT_PCA(fn, flims, nPCs, dsamp, outputdir, badframes)
% [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = PAT_PCA(fn, flims, nPCs, dsamp, outputdir, badframes)
%
% Modified from CellSort:
% Read TIFF movie data and perform singular-value decomposition (SVD)
% dimensional reduction.
%
% Inputs:
%   fn - PAT hypervolume.
%   flims - 2-element vector specifying the endpoints of the spectral range of
%   frames to be analyzed. If empty, default is to analyze all spectral
%   frames.
%   nPCs - number of principal components to be returned
%   dsamp - optional downsampling factor. If scalar, specifies spectral
%   downsampling factor. If two-element vector, entries specify spectral
%   and spatial downsampling, respectively.
%   outputdir - directory in which to store output .mat files
%   badframes - optional list of indices of movie frames to be excluded
%   from analysis
%
% Outputs:
%   mixedsig - nPCs x Nlambda matrix of Nlambda spectral signal mixtures
%   sampled at Nlambda
%   points.
%   mixedfilters - nPCs x X x Y array of nPCs spatial signal mixtures sampled at
%   X x Y spatial points.
%   CovEvals - nPCs largest eigenvalues of the covariance matrix
%   covtrace - trace of covariance matrix, corresponding to the sum of all
%   eigenvalues (not just the largest few)
%   movm - average of all movie spectral frames at each pixel
%   movtm - average of all movie pixels at each spectral frame
%
% Frederic Lesage
% Email: frederic.lesage@polymtl.ca
%
PATmat=job.PATmat;
% Loop over acquisitions

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        for iFile=1:length(PAT.nifti_files)
            % Read file
            vol = spm_vol(PAT.nifti_files{iFile});
            data = spm_read_vols(vol);
            
            % Data is filled with zeros, find where they are
            start_index =1;
            end_index=size(data,1);
            left_index=1;
            right_index=size(data,2);
            for itop=1:size(data,1)
                if( sum(data(itop,:,1)) > 0)
                    start_index=itop;
                    break;
                end
            end
            for ibot=size(data,1):-1:1
                if( sum(data(ibot,:,1)) > 0)
                    end_index=ibot;
                    break;
                end
            end
            for ileft=1:size(data,2)
                if( sum(data(:,ileft,1),1) > 0)
                    left_index=ileft;
                    break;
                end
                        end
            for iright=size(data,2):-1:1
                if( sum(data(:,iright,1),1) > 0)
                    right_index=iright;
                    break;
                end
            end
            data=log(abs(data(start_index:end_index,left_index:right_index,:)));
            flims=[1,size(data,3)];
            PAT.PCA.downsampling_factor=job.downsampling_factor;
            % A corriger, voir comment identifier
            badframes = [];
            useframes = setdiff((flims(1):flims(2)), badframes);
            n_lambda = length(useframes);
            nPCs = min(job.nPCs, n_lambda);
            PAT.PCA.nPCs=nPCs;
            PAT.PCA.useframes=useframes;
            
            pixw=size(data,1);
            pixh=size(data,2);
            npix = pixw*pixh;
            
            % Create covariance matrix in spectral or spatial coordinates using the
            % lowest dimension space since it is the same both ways
            if n_lambda < npix
                [covmat, mov, movm, movtm] = create_lcov(data, pixw, pixh, useframes, n_lambda, PAT.PCA.downsampling_factor);
                covtrace = trace(covmat) / n_lambda;
            else
                [covmat, mov, movm, movtm] = create_xcov(data, pixw, pixh, useframes, n_lambda, PAT.PCA.downsampling_factor);
                covtrace = trace(covmat) / npix;
            end
            
            movm = reshape(movm, pixw, pixh);
            
            if n_lambda < npix
                % Perform SVD on spectral covariance
                [mixedsig, CovEvals, percentvar] = spectral_pat_svd(covmat, nPCs, n_lambda, npix);
                
                % Load the other set of principal components
                [mixedfilters] = reload_moviedata(pixw*pixh, mov, mixedsig, CovEvals);
            else
                % Perform SVD on spatial components
                [mixedfilters, CovEvals, percentvar] = spectral_pat_svd(covmat, nPCs, n_lambda, npix);
                
                % Load the other set of principal components
                [mixedsig] = reload_moviedata(n_lambda, mov', mixedfilters, CovEvals);
            end
            mixedfilters = reshape(mixedfilters, pixw,pixh,nPCs);
            
            firstframe_full = squeeze(data(:,:,1));
            firstframe = firstframe_full;
            if PAT.PCA.downsampling_factor(1)>1
                firstframe = imresize(firstframe, size(mov(:,:,1)),'bilinear');
            end
            
            %------------
            % Save the output data
            PAT.PCA.mixedfilters=mixedfilters;
            PAT.PCA.CovEvals=CovEvals;
            PAT.PCA.mixedsig=mixedsig;
            PAT.PCA.movm = movm;
            PAT.PCA.movtm=movtm;
            PAT.PCA.covtrace=covtrace;
        end
        PAT.jobsdone.pca = 1;
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end

function [covmat, mov, movm, movtm] = create_xcov(data, pixw, pixh, useframes, nl, dsamp)
%-----------------------
% Load movie data to compute the spatial covariance matrix

npix = pixw*pixh;

% Downsampling
if length(dsamp)==1
    dsamp_lambda = dsamp(1);
    dsamp_space = 1;
else
    dsamp_lambda = dsamp(1);
    dsamp_space = dsamp(2); % Spatial downsample
end

if (dsamp_space==1)
    mov = zeros(pixw, pixh, nl);
    mov=data(:,:,useframes);
else
    [pixw_dsamp,pixh_dsamp] = size(imresize( squeeze(data(:,:,1)), 1/dsamp_space, 'bilinear' ));
    mov = zeros(pixw_dsamp, pixh_dsamp, nl);
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imresize( squeeze(data(:,:,jj)), 1/dsamp_space, 'bilinear' );
    end
end

mov = reshape(mov, npix, nl);

% DFoF normalization of each pixel
movm = mean(mov,2); % Average over spectra

if dsamp_lambda>1
    mov = filter(ones(dsamp,1)/dsamp, 1, mov, [], 2);
    mov = downsample(mov', dsamp)';
end

movtm = mean(mov,2); % Average over space

c1 = (mov*mov')/size(mov,2);
toc
covmat = c1 - movtm*movtm';
clear c1
end

function [covmat, mov, movm, movtm] = create_lcov(data, pixw, pixh, useframes, nl, dsamp)
%-----------------------
% Load movie data to compute the temporal covariance matrix
npix = pixw*pixh;

% Downsampling
if length(dsamp)==1
    dsamp_lambda = dsamp(1);
    dsamp_space = 1;
else
    dsamp_lambda = dsamp(1);
    dsamp_space = dsamp(2); % Spatial downsample
end

if (dsamp_space==1)
    mov=data(:,:,useframes);
else
    [pixw_dsamp,pixh_dsamp] = size(imresize( squeeze(data(:,:,1)), 1/dsamp_space, 'bilinear' ));
    mov = zeros(pixw_dsamp, pixh_dsamp, nl);
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imresize( squeeze(data(:,:,jj)), 1/dsamp_space, 'bilinear' );
    end
end

mov = reshape(mov, npix, nl);

% DFoF normalization of each pixel
movm = mean(mov,2); % Average over spectra

if dsamp_lambda>1
    mov = filter(ones(dsamp,1)/dsamp, 1, mov, [], 2);
    mov = downsample(mov', dsamp)';
end

c1 = (mov'*mov)/npix;
movtm = mean(mov,1); % Average over space
covmat = c1 - movtm'*movtm;
clear c1
end

function [mixedsig, CovEvals, percentvar] = spectral_pat_svd(covmat, nPCs, nl, npix)
%-----------------------
% Perform SVD

covtrace = trace(covmat) / npix;

opts.disp = 0;
opts.issym = 'true';
if nPCs<size(covmat,1)
    [mixedsig, CovEvals] = eigs(covmat, nPCs, 'LM', opts);  % pca_mixedsig are the temporal signals, mixedsig
else
    [mixedsig, CovEvals] = eig(covmat);
    CovEvals = diag( sort(diag(CovEvals), 'descend'));
    nPCs = size(CovEvals,1);
end
CovEvals = diag(CovEvals);
if nnz(CovEvals<=0)
    nPCs = nPCs - nnz(CovEvals<=0);
    fprintf(['Throwing out ',num2str(nnz(CovEvals<0)),' negative eigenvalues; new # of PCs = ',num2str(nPCs),'. \n']);
    mixedsig = mixedsig(:,CovEvals>0);
    CovEvals = CovEvals(CovEvals>0);
end

mixedsig = mixedsig' * nl;
CovEvals = CovEvals / npix;

percentvar = 100*sum(CovEvals)/covtrace;
fprintf([' First ',num2str(nPCs),' PCs contain ',num2str(percentvar,3),'%% of the variance.\n'])
end

function [mixedfilters] = reload_moviedata(npix, mov, mixedsig, CovEvals)
%-----------------------
% Re-load movie data
nPCs = size(mixedsig,1);

Sinv = inv(diag(CovEvals.^(1/2)));

movtm = mean(mov,1); % Average over space
movuse = mov - ones(npix,1) * movtm;
mixedfilters = reshape(movuse * mixedsig' * Sinv, npix, nPCs);
end

