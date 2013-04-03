%% script_anova
% Example
strength = [82 86 79 83 84 85 86 87; 74 82 78 75 76 77 NaN NaN; 79 79 77 78 82 79 NaN NaN]';
group = {'Steel'; 'Alloy1'; 'Alloy2'};
[p1,a1,s1] = anova1(strength,group);
[c,m,h,nms] = multcompare(s1);
disp([nms num2cell(c)]);

% EOF
