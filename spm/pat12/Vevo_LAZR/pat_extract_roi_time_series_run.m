function out = pat_extract_roi_time_series_run(job)
% Extract the time series for the ROIs (seeds), loops along scans, colors and
% files. Needs pat_extract_core. The time course is made up of the means of
% all the voxel values in the ROI/seed.
% Added brain mask extraction if needed
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________

% ------------------------------------------------------------------------------
% REMOVE AFTER FINISHING THE FUNCTION //EGC
% ------------------------------------------------------------------------------
% fprintf('Work in progress...\nEGC\n')
% out.PATmat = job.PATmat;
% return
% ------------------------------------------------------------------------------

% if isfield(job, 'save_figures') % NOT CODED UP YET
%     % save_figures
%     save_figures      = job.save_figures;
%     generate_figures  = job.generate_figures;
% else
%     save_figures      = false;
%     generate_figures  = true;
% end

for scanIdx=1:length(job.PATmat)
    try
        tic
        clear ROI
        % Load PAT.mat information
        [PAT PATmat dir_patmat]= pat_get_PATmat(job,scanIdx);
        
        if ~isfield(PAT.jobsdone,'ROIOK')
            disp(['No ROI available for subject ' int2str(scanIdx) ' ... skipping series extraction']);
        else
            if ~isfield(PAT.jobsdone,'seriesOK') || job.force_redo
                % Get mask for each ROI
                [PAT mask] = pat_get_roimask(PAT,job);
                Amask = []; % Initialize activation mask                
                if isfield(job.activMask_choice,'activMask')
                    try
                        mask_image = job.activMask_choice.activMask.mask_image{1};
                        threshold = job.activMask_choice.activMask.threshold;
                        two_sided = job.activMask_choice.activMask.two_sided;
                        h = hgload(mask_image);
                        ch = get(h,'Children');
                        l = get(ch,'Children');
                        z = get(l{3},'cdata');
                        if two_sided
                            Amask = z > abs(threshold) | z < -abs(threshold);
                        else
                            if z > 0
                                Amask = z > threshold;
                            else
                                Amask =  z < threshold;
                            end
                        end
                        close(h);
                        clear z l ch threshold two_sided mask_image
                    catch
                        disp('Could not mask by specified mask -- no masking by activation will be done')
                        Amask = [];
                    end
                end
                % We are not extracting brain mask here
                job.extractingBrainMask = false;
                % Extract ROI
                [ROI PAT] = pat_extract_core(PAT,job,mask,Amask);
                % ROI time course extraction succesful!
                PAT.jobsdone(1).seriesOK = true;
                % .mat file with ROIs/seeds time course data
                ROIfname = fullfile(dir_patmat,'ROI.mat');
                save(ROIfname,'ROI');
                PAT.ROI.ROIfname = ROIfname;
                save(PATmat,'PAT');
            end
        end
        if job.extractBrainMask
            [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
            if ~isfield(PAT.jobsdone, 'maskOK')
                fprintf('No brain mask available for scan %s, %d of %d complete\n',...
                    splitStr{end-1}, scanIdx, length(job.PATmat));
            elseif job.extractBrainMask
                % ---------------- Extract brain mask here ---------------------
                if ~isfield(PAT.jobsdone,'maskSeriesOK') || job.force_redo
                    fprintf('Extracting time series of global brain signal for scan %s, %d of %d complete\n',...
                        splitStr{end-1}, scanIdx, length(job.PATmat));
                    % It means we will extract only 1 ROI
                    job.extractingBrainMask = true;
                    % Get brain mask
                    [PAT mask] = pat_get_brain_mask(PAT);
                    % Extract brain mask here
                    [brainMaskSeries PAT] = pat_extract_core(PAT,job,mask,Amask);
                    % Reset flag
                    job.extractingBrainMask = false;
                    % Brain mask time series extraction succesful!
                    PAT.jobsdone(1).maskSeriesOK = true;
                    fnameSeries = fullfile(dir_patmat,'brainMaskSeries.mat');
                    save(fnameSeries, 'brainMaskSeries');
                    % identify in PAT the file name of the time series
                    PAT.fcPAT.mask.fnameSeries = fnameSeries;
                    save(PATmat,'PAT');
                end
            end
        end
%         if generate_figures || save_figures % NOT CODED UP YET
%             pat_plot_roi_time_series(PAT,ROI,generate_figures,save_figures);
%         end
        disp(['Elapsed time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')]);
        [~, ~, ~, ~, ~, ~, splitStr] = regexp(PAT.input_dir,'\\');
        fprintf('Scan %s, %d of %d complete\n', splitStr{end-1}, scanIdx, length(job.PATmat));
        out.PATmat{scanIdx} = PATmat;
    catch exception
        disp(exception.identifier)
        disp(exception.stack(1))
        out.PATmat{scanIdx} = job.PATmat{scanIdx};
    end
end % Loop over scans

% EOF
