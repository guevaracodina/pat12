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
            % Read file, if realigned take that one for analysis
            if( isfield(PAT.jobsdone,'realign') & PAT.jobsdone.realign )
                [p,n,e]=fileparts(PAT.nifti_files{iFile});
                aligned_file=fullfile(p,['r',n,e]);
                movement_est=fullfile(p,['r',n,'.mat']);
                vol = spm_vol(aligned_file);
                data = spm_read_vols(vol);
                flims=[1,size(data,4)];
                % Compute bad frames based on movement when realigned
                load(movement_est);
                vec=squeeze(mat(1,4,:));
                badframes=find(abs(vec-mean(vec))>2*std(vec));
                useframes = setdiff((flims(1):flims(2)), badframes);
            else
                vol = spm_vol(PAT.nifti_files{iFile});
                data = spm_read_vols(vol);
                flims=[1,size(data,4)];
                % Assume no bad frames when using all data
                badframes = [];
                useframes = setdiff((flims(1):flims(2)), badframes);
            end
            
            % Due to the realignment process, images may have NaN, need to
            % not look at those.
            
            n_lambda = length(useframes);
            nPCs = min(job.nPCs, n_lambda);
            PAT.PCA.nPCs=nPCs;
            PAT.PCA.useframes=useframes;
            
            pixw=size(data,1);
            pixh=size(data,2);
            
            tmpimg=squeeze(data(:,:,1,1));
            good_pixels=find(~isnan(tmpimg));
            npix = length(good_pixels);
            
            % Create covariance matrix in spectral or spatial coordinates using the
            % lowest dimension space since it is the same both ways
            if n_lambda < npix
                [covmat, mov, movm, movtm] = create_lcov(data, good_pixels, useframes, n_lambda);
                covtrace = trace(covmat) / n_lambda;
            else
                [covmat, mov, movm, movtm] = create_xcov(data, good_pixels, useframes, n_lambda);
                covtrace = trace(covmat) / npix;
            end
            
            % Replace everything int the right place
            tmp = nan(pixw,pixh);
            tmp(good_pixels) = movm;
            movm=tmp;
            
            if n_lambda < npix
                % Perform SVD on spectral covariance
                [mixedsig, CovEvals, percentvar] = spectral_pat_svd(covmat, nPCs, n_lambda, npix);
                
                % Load the other set of principal components
                [mixedfilters] = reload_moviedata(npix, mov, mixedsig, CovEvals);
            else
                % Perform SVD on spatial components
                [mixedfilters, CovEvals, percentvar] = spectral_pat_svd(covmat, nPCs, n_lambda, npix);
                
                % Load the other set of principal components
                [mixedsig] = reload_moviedata(n_lambda, mov', mixedfilters, CovEvals);
            end
            tmp = nan(pixw*pixh,nPCs);
            tmp(good_pixels,:) = mixedfilters;
            mixedfilters = reshape(tmp, pixw,pixh,nPCs);
            
            % Save each spatial PCA in a separate nifti file
            if ~exist([PAT.output_dir,filesep,'pca'],'dir'),mkdir([PAT.output_dir,filesep,'pca']); end
            [p, stripped_filename, e]=fileparts(PAT.nifti_files{iFile});
            for ipca=1:size(mixedfilters,3)
                tmp=squeeze(mixedfilters(:,:,ipca));
                norm_pca=(tmp-min(tmp(:)))/(max(tmp(:))-min(tmp(:)));
                nifti_filename=fullfile([PAT.output_dir,filesep,'pca'],['pca_',num2str(ipca),'_',stripped_filename,'.nii']);
                dim = [size(mixedfilters,1), size(mixedfilters,2), 1];
                dt = [spm_type('float64') spm_platform('bigend')];
                pinfo = ones(3,1);
                % Affine transformation matrix: Scaling
                matScaling = eye(4);
                matScaling(1,1) = PAT.pixel_width;
                matScaling(2,2) = PAT.pixel_height;
                % Affine transformation matrix: Rotation
                matRotation = eye(4);
                matRotation(1,1) = 0;
                matRotation(1,2) = 1;
                matRotation(2,1) = -1;
                matRotation(2,2) = 0;
                % Affine transformation matrix: Translation
                matTranslation = eye(4);
                matTranslation(1,4) = PAT.depth_offset/PAT.pixel_height;
                matTranslation(2,4) = PAT.left_offset/PAT.pixel_width;
                % Final Affine transformation matrix:
                mat = matScaling * matRotation * matTranslation;
                % Save all frames temporally to use lambda as time
                hdr = pat_create_vol(nifti_filename, dim, dt, pinfo, mat,1,norm_pca);
                PAT.PCA.nifti_files{iFile}{ipca}=nifti_filename;
                % Just to check alignement, may be useful later
                h = spm_figure('GetWin', 'Graphics');
                spm_figure('Clear', 'Graphics');
                h=pat_overlay_map(PAT.bmode_nifti_files{iFile}, PAT.PCA.nifti_files{iFile}{ipca}, [0.3 1],['PCA #',num2str(ipca)]);
                
                if job.save_figures
                    % Save as PNG
                    print(h, '-dpng', fullfile([PAT.output_dir,filesep,'pca'],['pca_',num2str(ipca),'_',stripped_filename]), '-r150');
                    % Save as EPS
                    %spm_figure('Print', 'Graphics', fullfile(dir_fisherZfig,newName));
                end
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

function [covmat, mov, movm, movtm] = create_xcov(data, good_pixels, useframes, nl)
%-----------------------
% Load movie data to compute the spatial covariance matrix
tmp=reshape(data,[size(data,1)*size(data,2),size(data,4)]);
mov=tmp(good_pixels,useframes);
% DFoF normalization of each pixel
movm = mean(mov,2); % Average over spectra
movtm = mean(mov,1); % Average over space
c1 = (mov*mov')/nl;
toc
covmat = c1 - movm*movm';
clear c1
end

function [covmat, mov, movm, movtm] = create_lcov(data, good_pixels, useframes, nl)
%-----------------------
% Load movie data to compute the temporal covariance matrix
tmp=reshape(data,[size(data,1)*size(data,2),size(data,4)]);
mov=tmp(good_pixels,useframes);
npix=length(good_pixels);
% DFoF normalization of each pixel
movm = mean(mov,2); % Average over spectra
movtm = mean(mov,1); % Average over space
c1 = (mov'*mov)/npix;
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

