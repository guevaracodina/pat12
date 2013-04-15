%% script_anova
% Example
clear all; clc; close all;
alphaVal = 0.05;
criterionType = 'tukey-kramer';
%% Test HbT one seed pair
% strength = [82 86 79 83 84 85 86 87; 74 82 78 75 76 77 NaN NaN; 79 79 77 78 82 79 NaN NaN]';
load('E:\Edgar\Data\PAT_Results\networks\resultsROI_Condition01_HbT.mat');
z_seed12_tmp = squeeze(Z(1,2,:));
z_seed12 = nan([7, 3]);
z_seed12(1:5, 1) = z_seed12_tmp(1:5);
z_seed12(1:7, 2) = z_seed12_tmp(5+1:5+7);
z_seed12(1:6, 3) = z_seed12_tmp(5+7+1:18);
group = {'Control'; 'LPS'; 'LPS+IL-1Ra'};
[p1,table1,stats1] = anova1(z_seed12, group);
figure;
[comparison, means, h, groupNames] = multcompare(stats1, 'alpha', alphaVal, 'ctype', criterionType);
disp([groupNames num2cell(comparison)]);

% EOF
