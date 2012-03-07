function out = pat_reg_run(job)
%_______________________________________________________________________
% Copyright (C) 2011 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%______________________________________________________________________
%
PATmat=job.PATmat;
% Loop over acquisitions

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        nt_full = tiff_frames(PAT.tif_stack);
        flims = [1,nt_full];
        PAT.REG.nReg=job.nReg;
        % A corriger, voir comment identifier
        badframes = [];
        useframes = setdiff((flims(1):flims(2)), badframes);
        n_lambda = length(useframes);
        
        first_image=imread(PAT.tif_stack,4);
        [pixw,pixh] = size(first_image);
        npix = pixw*pixh;
        
        figure;
        imagesc(first_image);
        
        intensities=[];
        for iroi=1:PAT.REG.nReg
            
            h = imrect;
            p = round(wait(h));
            intensities(iroi)=sum(sum(first_image(p(2):p(2)+p(4),p(1):p(1)+p(3)),1),2)
 %           for i_img=1:nt_full
 %               current_image=imread(PAT.tif_stack,i_img);
 %               regressor(iroi,i_img)=sum(sum(current_image(p(2):p(2)+p(4),p(1):p(1)+p(3)),1),2);
 %           end
            
        end
        figure;
        plot([1:4],intensities);
        
%        figure;
%        subplot(1,2,1)
%        plot(regressor(1,:));
%        subplot(1,2,2)
%        plot(regressor(2,:));
                
        % Now want to regress this in images to form a unique image
        
        %------------
        % Save the output data
        PAT.jobsdone.reg = 1;
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end

end

function [covmat, mov, movm, movtm] = create_xcov(fn, pixw, pixh, useframes, nl, dsamp)
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
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imread(fn,jj);
        if mod(jjind,500)==1
            fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
            toc
        end
    end
else
    [pixw_dsamp,pixh_dsamp] = size(imresize( imread(fn,1), 1/dsamp_space, 'bilinear' ));
    mov = zeros(pixw_dsamp, pixh_dsamp, nl);
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imresize( imread(fn,jj), 1/dsamp_space, 'bilinear' );
        if mod(jjind,500)==1
            fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
            toc
        end
    end
end

fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
toc
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

function [covmat, mov, movm, movtm] = create_lcov(fn, pixw, pixh, useframes, nl, dsamp)
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
    mov = zeros(pixw, pixh, nl);
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imread(fn,jj);
        if mod(jjind,500)==1
            fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
        end
    end
else
    [pixw_dsamp,pixh_dsamp] = size(imresize( imread(fn,1), 1/dsamp_space, 'bilinear' ));
    mov = zeros(pixw_dsamp, pixh_dsamp, nl);
    for jjind=1:length(useframes)
        jj = useframes(jjind);
        mov(:,:,jjind) = imresize( imread(fn,jj), 1/dsamp_space, 'bilinear' );
        if mod(jjind,500)==1
            fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
            toc
        end
    end
end

fprintf(' Read frame %4.0f out of %4.0f; ', jjind, nl)
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

