%% script_pat_get_so2
clear; close all; clc;
baseDir = 'D:\Edgar\PAT_test_data';
baseFilename{1} = 'Air-750nm'; % Filename at 750nm
baseFilename{2} = 'Air-850nm'; % Filename at 850nm

%% Run function
Combined = pat_get_SO2(baseDir, baseFilename);