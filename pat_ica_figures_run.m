function out = pat_ica_figures_run(job)

%function CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse, spt, spc)
% CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse, spt, spc)
%
% Display the results of ICA analysis in the form of paired spatial filters
% and signal time courses
%
% Inputs:
%     mode - 'series' shows each spatial filter separately; 'contour'
%     displays a single plot with contours for all spatial filters
%     superimposed on the mean fluorescence image
%     ica_filters - nIC x X x Y array of ICA spatial filters
%     ica_sig - nIC x T matrix of ICA temporal signals
%     f0 - mean fluorescence image
%     tlims - 2-element vector specifying the range of times to be displayed
%     dt - time step corresponding to individual movie time frames
%     ratebin - size of time bins for spike rate computation
%     ICuse - vector of indices of cells to be plotted
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu
%

colord=[         0         0    1.0000
    0    0.4000         0
    1.0000         0         0
    0    0.7500    0.7500
    0.7500         0    0.7500
    0.8, 0.5, 0
    0         0    0.5
    0         0.85      0];

PATmat=job.PATmat;
% Loop over acquisitions

for scanIdx=1:size(PATmat,1)
    try
        load(PATmat{scanIdx});
        % Check input arguments
        nIC = PAT.ICA.nICs;
        tlims = linspace(job.spectral_range(1),job.spectral_range(2),size(PAT.ICA.sig,2));
        axes_lims=[job.spectral_range(1),job.spectral_range(2)];
        ICuse = [1:nIC];
        
        % Reshape the filters
        [pixw,pixh] = size(PAT.PCA.movm);
        if size(PAT.ICA.filters,1)==nIC
            ica_filters = reshape(PAT.ICA.filters,nIC,pixw,pixh);
        elseif size(PAT.ICA.ica_filters,2)==nIC
            ica_filters = reshape(PAT.ICA.filters,nIC,pixw,pixh);
        end
        
        figure;
        switch job.mode
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {'series'}
                colmax = 20; % Maximum # of ICs in one column
                ncols = ceil(length(ICuse)/colmax);
                nrows = ceil(length(ICuse)/ncols);
                
                if size(ica_filters(:,:,1))==size(PAT.PCA.movm(:,:,1))
                    ica_filters = permute(ica_filters,[3,1,2]);
                end
                
                subplot(1,3*ncols,[2:3])
                
                clf
                f_pos = get(gcf,'Position');
                f_pos(4) = max([f_pos(4),500,50*nrows]);
                f_pos(3) = max(400*ncols,0.9*f_pos(4));
                
                colormap(hot)
                colord=get(gca,'ColorOrder');
                ll=0;
                filtax = [];
                if ~isempty(ica_filters)
                    for k=0:ncols-1
                        jj=3*k;
                        nrows_curr = min(nrows,length(ICuse)-k*nrows);
                        for j=1:nrows_curr
                            filtax= [filtax,subplot(nrows_curr,3*ncols, jj+1)];
                            jj=jj+3*ncols;
                            ll=ll+1;
                            imagesc(squeeze(ica_filters(ICuse(ll),:,:)))
                            axis image tight off
                        end
                    end
                end
                
                ax = [];
                for j=0:ncols-1
                    ax(j+1)=subplot(1,3*ncols,3*j+[2:3]);
                    ICuseuse = ICuse([1+j*nrows:min(length(ICuse),(j+1)*nrows)]);
                    complot(PAT.ICA.sig, ICuseuse, tlims)
                    formataxes
                    xlabel('Wavelength (nm)')
                    xlim(axes_lims)
                    yl = ylim;
                    drawnow
                end
                set(gcf,'Color','w','PaperPositionMode','auto')
                
                %%%%
                % Resize plots to appropriate size
                if (length(ICuse)>=3)
                    bigpos = get(ax(1),'Position');
                    aheight = 0.9*bigpos(4)/nrows;
                    for k=1:length(filtax)
                        axpos = get(filtax(k),'Position');
                        axpos(3) = aheight;
                        axpos(4) = aheight;
                        set(filtax(k),'Position',axpos)
                    end
                    
                    set(gcf,'Units','normalized')
                    fpos = get(gcf,'Position');
                    for j=1:ncols
                        axpos = get(ax(j),'OuterPosition');
                        filtpos = get(filtax(1+(j-1)*nrows),'Position');
                        axpos(1) = filtpos(1) + filtpos(3)*1.1;
                        set(ax(j),'OuterPosition',axpos,'ActivePositionProperty','outerposition')
                        axpos = get(ax(j),'Position');
                    end
                    set(gcf,'Resize','on','Units','characters')
                end
                
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case {'contour'}
                f_pos = get(gcf,'Position');
                if f_pos(4)>f_pos(3)
                    f_pos(4) = 0.5*f_pos(3);
                    set(gcf,'Position',f_pos);
                end
                set(gcf,'Renderer','zbuffer','RendererMode','manual')
                
                subplot(1,2,2)
                
                clf
                colormap(gray)
                
                set(gcf,'DefaultAxesColorOrder',colord)
                subplot(1,2,1)
                
                crange = [min(min(min(ica_filters(ICuse,:,:)))),max(max(max(ica_filters(ICuse,:,:))))];
                contourlevel = crange(2) - diff(crange)*[1,1]*0.8;
                
                cla
                if ndims(PAT.PCA.movm)==2
                    imagesc(PAT.PCA.movm)
                else
                    image(PAT.PCA.movm)
                end
                cax = caxis;
                sigsm = 1;
                shading flat
                hold on
                for j=1:length(ICuse)
                    ica_filtersuse = gaussblur(squeeze(ica_filters(ICuse(j),:,:)), sigsm);
                    contour(ica_filtersuse, [1,1]*(mean(ica_filtersuse(:))+4*std(ica_filtersuse(:))), ...
                        'Color',colord(mod(j-1,size(colord,1))+1,:),'LineWidth',2)
                end
                for j=1:length(ICuse)
                    ica_filtersuse = gaussblur(squeeze(ica_filters(ICuse(j),:,:)), sigsm);
                    
                    % Write the number at the cell center
                    [ypeak, xpeak] = find(ica_filtersuse == max(max(ica_filtersuse)),1);
                    text(xpeak,ypeak,num2str(j), 'horizontalalignment','c','verticalalignment','m','color','y')
                end
                hold off
                caxis(cax)
                formataxes
                axis image tight off
                title('Avg of movie, with contours of ICs')
                
                ax = subplot(1,2,2);
                complot(PAT.ICA.sig, ICuse, tlims)
                set(gca,'ColorOrder',colord)
                formataxes
                xlim(axes_lims)
                xlabel('Wavelength (s)','FontAngle','i')
                ylabel('IC #','FontAngle','i')
                set(gcf,'Color','w','PaperPositionMode','auto')
                set(gca,'yticklabel',num2str(fliplr([1:length(ICuse)])'))
                box on
                
        end
        save(fullfile(PAT.output_dir, 'PAT.mat'),'PAT');
        out.PATmat{scanIdx} = PATmat{scanIdx};

    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = PATmat{scanIdx};
    end
end
end

%%%%%%%%%%%%%%%%%%%%%
function complot(sig, ICuse, tlims)

% This function first removes the mean and normalizes everything to std
for i = 1:length(ICuse)
    zsig(i, :) = zscore(sig(ICuse(i),:));
end

alpha = mean(max(zsig')-min(zsig'));
if islogical(zsig)
    alpha = 1.5*alpha;
end

% We then plot at different levels the ICA components by faking their y
% coordinates.
zsig2 = zsig;
for i = 1:size(ICuse,2)
    zsig2(i,:) = zsig(i,:) - alpha*(i-1)*ones(size(zsig(1,:)));
end

if islogical(zsig)
    plot(tlims, zsig2','LineWidth',2)
else
    plot(tlims, zsig2','LineWidth',2)
end
axis tight

set(gca,'YTick',(-size(zsig,1)+1)*alpha:alpha:0);
set(gca,'YTicklabel',fliplr(ICuse));
end

function formataxes

set(gca,'FontSize',12,'FontWeight','bold','FontName','Helvetica','LineWidth',2,'TickLength',[1,1]*.02,'tickdir','out')
set(gcf,'Color','w','PaperPositionMode','auto')
end

function fout = gaussblur(fin, smpix)
%
% Blur an image with a Gaussian kernel of s.d. smpix
%

if ndims(fin)==2
    [x,y] = meshgrid([-ceil(3*smpix):ceil(3*smpix)]);
    smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
    smfilt = smfilt/sum(smfilt(:));
    
    fout = imfilter(fin, smfilt, 'replicate', 'same');
else
    [x,y] = meshgrid([-ceil(smpix):ceil(smpix)]);
    smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
    smfilt = smfilt/sum(smfilt(:));
    
    fout = imfilter(fin, smfilt, 'replicate', 'same');
end
end
