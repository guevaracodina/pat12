%% Process previous data
clear
script_pat_partial_correlations_noregress;
script_pat_partial_correlations;

%% Display figure
h = figure; set(gcf,'color','w')
figure(h);
Ndata = numel([ctrlNoRegress(:); lpsNoRegress(:)]);
% Freedman-Diaconis 
FDh = 2*iqr([ctrlNoRegress(:); lpsNoRegress(:)])*Ndata^(-1/3);
nBins = ceil(diff(minmax([ctrlNoRegress(:); lpsNoRegress(:)]'))/FDh);
[n,xout] = hist([ctrlNoRegress(:); lpsNoRegress(:)], nBins);
subplot(121); bar(xout,n/sum(n)); xlim([-1 1]); ylim([0 0.3]);
xlabel('Correlation Values')
title('Without global signal regression')

% Freedman-Diaconis 
FDh = 2*iqr([ctrl(:); lps(:)])*Ndata^(-1/3);
nBins = ceil(diff(minmax([ctrl(:); lps(:)]'))/FDh);
[n,xout] = hist([ctrl(:); lps(:)], nBins);
subplot(122); bar(xout,n/sum(n)); xlim([-1 1]); ylim([0 0.3]);
xlabel('Correlation Values')
title('With global signal regression')

colormap([0.5 0.5 0.5])

%% Print figure
figSize = [0.1 0.1 10 5];
set(h, 'units', 'inches')
set(h, 'Position', figSize); set(h, 'PaperPosition', figSize);
dirName = 'F:\Edgar\Data\PAT_Results\PAS2013\regressionTest';
newName = 'PAS2013_bilateral_correlation_hist';
set(h,'Name',newName);
print(h, '-dpng', fullfile(dirName,newName), sprintf('-r%d',300));
% Save as a figure
saveas(h, fullfile(dirName,newName), 'fig');
close(h);

% EOF
