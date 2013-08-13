%% radius = 0.5mm
clc
job.PATmat = {
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\PAT.mat'
    };
job.PATmatCopyChoice = [];

% ROIs of interest
nROI = 5:2:10;
% Only HbT
c1 = 1;
nSubjects = numel(job.PATmat);
for scanIdx = 1:nSubjects
    [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
    % Load regressed values
    load(PAT.fcPAT.SPM.fnameROIregress)
    % Reset paired seeds index
    iPairedSeeds = 1;
    % Compute paired correlations
    for iROI = nROI,
        % Column-wise correlation
        r50(scanIdx, iPairedSeeds) = corr(ROIregress{iROI}{c1}',ROIregress{iROI+1}{c1}');
        iPairedSeeds = iPairedSeeds + 1;
    end
end
fprintf('radius = 0.5mm, <r> = %0.4f SEM = %0.4f\n',nanmean(r50(:)), nanstd(r50(:)) ./ sqrt(numel(r50(:))));

%% radius = 0.3 mm
job.PATmat = {
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\seedRadius03\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\seedRadius03\PAT.mat'
    };
job.PATmatCopyChoice = [];

% ROIs of interest
nROI = 5:2:10;
% Only HbT
c1 = 1;
nSubjects = numel(job.PATmat);
for scanIdx = 1:nSubjects
    [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
    % Load regressed values
    load(PAT.fcPAT.SPM.fnameROIregress)
    % Reset paired seeds index
    iPairedSeeds = 1;
    % Compute paired correlations
    for iROI = nROI,
        % Column-wise correlation
        r30(scanIdx, iPairedSeeds) = corr(ROIregress{iROI}{c1}',ROIregress{iROI+1}{c1}');
        iPairedSeeds = iPairedSeeds + 1;
    end
end
fprintf('radius = 0.3mm, <r> = %0.4f SEM = %0.4f\n',nanmean(r30(:)), nanstd(r30(:)) ./ sqrt(numel(r30(:))));

%% radius = 0.15 mm
job.PATmat = {
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-16-25_toe04\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-17-27_toe05\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-04_toe08\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\2012-11-09-16-23-51_toe09\GLMfcPAT\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DC_RS1\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DE_RS2\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DH_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E05_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E06_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E07_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E08_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DA_RS2\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DB_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DF_RS\GLMfcPAT\corrMap\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DG_RS\GLMfcPAT\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\DK_RS2\GLMfcPAT\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E01_RS\GLMfcPAT\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E02_RS\GLMfcPAT\seedRadius015\PAT.mat'
    'F:\Edgar\Data\PAT_Results_20130517\RS\E03_RS\GLMfcPAT\seedRadius015\PAT.mat'
    };
job.PATmatCopyChoice = [];

% ROIs of interest
nROI = 5:2:10;
% Only HbT
c1 = 1;
nSubjects = numel(job.PATmat);
for scanIdx = 1:nSubjects
    [PAT PATmat dir_patmat] = pat_get_PATmat(job,scanIdx);
    % Load regressed values
    load(PAT.fcPAT.SPM.fnameROIregress)
    % Reset paired seeds index
    iPairedSeeds = 1;
    % Compute paired correlations
    for iROI = nROI,
        % Column-wise correlation
        r015(scanIdx, iPairedSeeds) = corr(ROIregress{iROI}{c1}',ROIregress{iROI+1}{c1}');
        iPairedSeeds = iPairedSeeds + 1;
    end
end
fprintf('radius = 0.15mm, <r> = %0.4f SEM = %0.4f\n',nanmean(r015(:)), nanstd(r015(:)) ./ sqrt(numel(r015(:))));

%% Display data
figure; set(gcf,'color','w')
% boxplot([r50(:), r30(:) r015(:),]);
seedSize = [0.15; 0.30; 0.50];
avgCorr = [nanmean(r015(:));nanmean(r30(:)); nanmean(r50(:))];
semCorr = [nanstd(r015(:)) ./ sqrt(numel(r015(:))); nanstd(r30(:)) ./ sqrt(numel(r30(:)));...
    nanstd(r50(:)) ./ sqrt(numel(r50(:)))];
errorbar(seedSize, avgCorr, semCorr, 'ko', 'LineWidth', 2);
hold on
h = xlabel('Seed radius (mm)','FontSize',12);
% ylabel('bilateral $\bar{r}$','FontSize',12,'Interpreter', 'latex','FontName','Helvetica');
ylabel('bilateral correlation r','FontSize',12,'FontName','Helvetica');
set(gca,'FontSize',12)
rho2 = corr(seedSize, avgCorr) .^ 2;
xlim([0 0.55]);
ylim([0 0.55]);
set(gcf, 'units', 'inches')
set(gcf, 'Position', [0.1 0.1 3.5 3.25])
set(gcf, 'PaperPosition', [0.1 0.1 3.5 3.25])
text(0.1,0.4,sprintf('r^2=%0.4f',rho2),'FontSize',12)
% Linear fit
nPoints = 100;
p = polyfit(seedSize, avgCorr,1);
f = polyval(p, seedSize);
xinterp = linspace(seedSize(1), seedSize(end), nPoints);
plot(seedSize, f, 'k--', 'LineWidth', 2)
print(gcf, '-dpng', fullfile('D:\Edgar\Documents\Dropbox\Docs\PAT\Figures','seeds_size'), '-r300');
% EOF
